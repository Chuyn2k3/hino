import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class Iso15693LicensePage extends StatefulWidget {
  const Iso15693LicensePage({super.key});

  @override
  State<Iso15693LicensePage> createState() => _Iso15693LicensePageState();
}

class _Iso15693LicensePageState extends State<Iso15693LicensePage> {
  bool _available = false;
  String _status = 'Idle';

  final _licenseCtrl =
      TextEditingController(text: '012345678912345'); // 15 k.tự
  final _nameCtrl = TextEditingController(text: 'NGUYEN VAN A');
  final _extraDataCtrl = TextEditingController(
      text: 'EXTRA_DATA'); // Thêm trường cho dữ liệu mở rộng

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final ok = await NfcManager.instance.isAvailable();
    setState(() => _available = ok);
  }

  // ----- QCVN encoding -----
  Uint8List buildPayload(
      {required String license,
      required String name,
      required String extraData}) {
    final bytes = Uint8List(255);
    for (int i = 0; i < 255; i++) {
      bytes[i] = 0x30; // '0'
    }

    // 1) GPLX 15 bytes
    final lic = ascii.encode(license);
    for (int i = 0; i < 15; i++) {
      bytes[i] = i < lic.length ? (lic[i] & 0x7F) : 0x30;
    }
    // checksum byte 16 (index 15)
    bytes[15] = _checksum(bytes.sublist(0, 15));

    // 2) NAME 43 bytes (index 16..58)
    final nm = ascii.encode(name.toUpperCase());
    for (int i = 0; i < 43; i++) {
      bytes[16 + i] = i < nm.length ? (nm[i] & 0x7F) : 0x30;
    }
    // checksum byte 60 (index 59)
    bytes[59] = _checksum(bytes.sublist(16, 16 + 43));

    // 3) Dữ liệu mở rộng (index 60..254), tối đa 195 byte
    final extra = ascii.encode(extraData.toUpperCase());
    for (int i = 0; i < 195; i++) {
      bytes[60 + i] = i < extra.length ? (extra[i] & 0x7F) : 0x30;
    }
    // checksum byte 255 (index 254)
    bytes[254] = _checksum(bytes.sublist(60, 60 + 195));

    // 4) Byte 255 giữ mặc định '0' (dự phòng)
    return bytes;
  }

  int _checksum(List<int> data) {
    var sum = 0;
    for (final b in data) {
      sum = (sum + (b & 0xFF)) & 0xFF;
    }
    return sum;
  }

  // ----- ISO15693 helpers -----
  Future<void> _writeISO15693(Uint8List allBytes) async {
    if (!_available) {
      setState(() => _status = 'NFC không sẵn sàng');
      return;
    }
    setState(() => _status = 'Hãy chạm thẻ ISO15693 để GHI...');
    await NfcManager.instance.startSession(
      alertMessage: 'Giữ thẻ gần điện thoại để ghi',
      onDiscovered: (tag) async {
        try {
          final iso = Iso15693.from(tag);
          if (iso == null) throw 'Thẻ không phải ISO15693 (NfcV).';

          // Thử lấy block size từ system info
          int? blockSize = await _getBlockSize(iso);
          if (blockSize == null) {
            // Nếu không lấy được, thử 4 rồi 8
            await _tryWriteByBlockSize(iso, allBytes, 4).onError((_, __) async {
              return _tryWriteByBlockSize(iso, allBytes, 8);
            });
          } else {
            await _tryWriteByBlockSize(iso, allBytes, blockSize);
          }

          setState(() => _status = 'Ghi thành công ${allBytes.length} byte.');
          await NfcManager.instance.stopSession();
        } catch (e) {
          setState(() => _status = 'Ghi lỗi: $e');
          await NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  Future<void> _tryWriteByBlockSize(
      Iso15693 iso, Uint8List data, int blockSize) async {
    final blocks = (data.length / blockSize).ceil();
    for (int i = 0; i < blocks; i++) {
      final start = i * blockSize;
      final end = (start + blockSize > data.length)
          ? data.length
          : start + blockSize;
      final chunk = Uint8List(blockSize)..setAll(0, data.sublist(start, end));
      await iso.writeSingleBlock(
        blockNumber: i,
        dataBlock: chunk,
        requestFlags: {
          Iso15693RequestFlag.address,
          Iso15693RequestFlag.highDataRate,
        },
      );
    }
  }

  Future<void> _readISO15693() async {
    if (!_available) {
      setState(() => _status = 'NFC không sẵn sàng');
      return;
    }
    setState(() => _status = 'Hãy chạm thẻ ISO15693 để ĐỌC...');
    await NfcManager.instance.startSession(
      alertMessage: 'Giữ thẻ gần điện thoại để đọc',
      onDiscovered: (tag) async {
        try {
          final iso = Iso15693.from(tag);
          if (iso == null) throw 'Thẻ không phải ISO15693 (NfcV).';

          // Thử lấy block size từ system info
          int? blockSize = await _getBlockSize(iso);
          if (blockSize == null) {
            // Nếu không lấy được, thử 4 rồi 8
            Uint8List all = await _tryReadByBlockSize(iso, 4).onError((_, __) {
              return _tryReadByBlockSize(iso, 8);
            });
            _processPayload(all);
          } else {
            final all = await _tryReadByBlockSize(iso, blockSize);
            _processPayload(all);
          }
          await NfcManager.instance.stopSession();
        } catch (e) {
          setState(() => _status = 'Đọc lỗi: $e');
          await NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  Future<Uint8List> _tryReadByBlockSize(Iso15693 iso, int blockSize) async {
    final totalBlocks = (255 / blockSize).ceil();
    final out = BytesBuilder();
    for (int i = 0; i < totalBlocks; i++) {
      final data = await iso.readSingleBlock(
        blockNumber: i,
        requestFlags: {
          Iso15693RequestFlag.address,
          Iso15693RequestFlag.highDataRate,
        },
      );
      out.add(data);
    }
    final all = out.toBytes();
    return all.length >= 255 ? all.sublist(0, 255) : all;
  }

  Future<int?> _getBlockSize(Iso15693 iso) async {
    try {
      final info = await iso.getSystemInfo(
          requestFlags: {Iso15693RequestFlag.address});
      return info.blockSize; // Giả sử nfc_manager hỗ trợ
    } catch (e) {
      return null;
    }
  }

  void _processPayload(Uint8List payload) {
    if (payload.length < 64) {
      setState(() => _status = 'Thẻ không đủ 64 byte (đọc được ${payload.length}).');
      return;
    }
    if (payload.length >= 255) {
      payload = payload.sublist(0, 255); // Cắt về 255 byte nếu vượt
    }

    final lic = ascii.decode(payload.sublist(0, 15));
    final licCk = payload[15];
    final licCkCalc = _checksum(payload.sublist(0, 15));

    final nameBytes = payload.sublist(16, 16 + 43);
    final name = ascii.decode(nameBytes);
    final nameCk = payload[59];
    final nameCkCalc = _checksum(nameBytes);

    final extraBytes = payload.sublist(60, 60 + 195);
    final extraData = ascii.decode(extraBytes.where((b) => b != 0x30).toList());
    final extraCk = payload[254];
    final extraCkCalc = _checksum(payload.sublist(60, 60 + 195));

    setState(() {
      _status = 'Đọc thành công:\n'
          '- GPLX: $lic (CK: $licCk / $licCkCalc)\n'
          '- Họ tên: $name (CK: $nameCk / $nameCkCalc)\n'
          '- Dữ liệu mở rộng: $extraData (CK: $extraCk / $extraCkCalc)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ISO15693 – Ghi/đọc thẻ lái xe (demo)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NFC: ${_available ? "Sẵn sàng" : "Không khả dụng"}'),
            const SizedBox(height: 12),
            TextField(
              controller: _licenseCtrl,
              decoration: const InputDecoration(
                labelText: 'Số GPLX (15 ký tự ASCII)',
                border: OutlineInputBorder(),
              ),
              maxLength: 15,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Họ tên (ASCII, tối đa 43 ký tự)',
                border: OutlineInputBorder(),
              ),
              maxLength: 43,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _extraDataCtrl,
              decoration: const InputDecoration(
                labelText: 'Dữ liệu mở rộng (tối đa 195 ký tự ASCII)',
                border: OutlineInputBorder(),
              ),
              maxLength: 195,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final licenseError =
                        DriverLicenseValidator.validateLicenseNumber(
                            _licenseCtrl.text.trim());
                    final nameError = DriverLicenseValidator.validateName(
                        _nameCtrl.text.trim());

                    if (licenseError != null || nameError != null) {
                      final errorMsg = [licenseError, nameError]
                          .where((e) => e != null)
                          .join("\n");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMsg)),
                      );
                      return;
                    }
                    final payload = buildPayload(
                      license: _licenseCtrl.text.trim(),
                      name: _nameCtrl.text.trim(),
                      extraData: _extraDataCtrl.text.trim(),
                    );
                    _writeISO15693(payload);
                  },
                  child: const Text('GHI 255 BYTE'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _readISO15693,
                  child: const Text('ĐỌC & KIỂM TRA'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_status),
              ),
            ),
            const Divider(),
            const Text(
              'Lưu ý: Mỗi loại thẻ ISO15693 có kích thước block (4/8 byte) khác nhau. '
              'Mã đã tự thử 4 rồi 8 hoặc lấy từ system info nếu có.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverLicenseValidator {
  static String? validateLicenseNumber(String value) {
    if (value.isEmpty) return "Số GPLX không được để trống";
    if (!RegExp(r'^\d{15}$').hasMatch(value)) {
      return "GPLX phải có đúng 15 ký tự số";
    }
    return null;
  }

  static String? validateName(String value) {
    if (value.isEmpty) return "Tên không được để trống";
    if (!RegExp(r'^[A-Z ]+$').hasMatch(value)) {
      return "Tên chỉ được chứa ký tự in hoa ASCII và khoảng trắng";
    }
    return null;
  }
}
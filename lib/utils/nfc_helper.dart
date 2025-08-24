import 'dart:typed_data';
import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class NfcHelper {
  /// Kiểm tra thiết bị có NFC và đang bật hay không
  static Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  // build 255 bytes payload theo QCVN
  static Uint8List buildPayload({
    required String license,
    required String name,
    required String extraData,
  }) {
    final bytes = Uint8List(255);
    for (int i = 0; i < 255; i++) {
      bytes[i] = 0x30;
    }

    // GPLX
    final lic = ascii.encode(license);
    for (int i = 0; i < 15; i++) {
      bytes[i] = i < lic.length ? (lic[i] & 0x7F) : 0x30;
    }
    bytes[15] = _checksum(bytes.sublist(0, 15));

    // NAME
    final nm = ascii.encode(name.toUpperCase());
    for (int i = 0; i < 43; i++) {
      bytes[16 + i] = i < nm.length ? (nm[i] & 0x7F) : 0x30;
    }
    bytes[59] = _checksum(bytes.sublist(16, 59));

    // Extra
    final extra = ascii.encode(extraData.toUpperCase());
    for (int i = 0; i < 195; i++) {
      bytes[60 + i] = i < extra.length ? (extra[i] & 0x7F) : 0x30;
    }
    bytes[254] = _checksum(bytes.sublist(60, 255));

    return bytes;
  }

  static int _checksum(List<int> data) {
    var sum = 0;
    for (final b in data) {
      sum = (sum + (b & 0xFF)) & 0xFF;
    }
    return sum;
  }

  /// Ghi dữ liệu vào thẻ ISO15693
  static Future<void> writeIso15693(Uint8List allBytes) async {
    final available = await isAvailable();
    if (!available) throw "NFC không khả dụng hoặc chưa bật";

    await NfcManager.instance.startSession(
      alertMessage: 'Giữ thẻ gần điện thoại để ghi',
      onDiscovered: (tag) async {
        try {
          final iso = Iso15693.from(tag);
          if (iso == null) throw 'Không phải thẻ ISO15693';

          int blockSize = 4; // default
          try {
            final info = await iso.getSystemInfo(
              requestFlags: {Iso15693RequestFlag.address},
            );
            if (info.blockSize != null) blockSize = info.blockSize!;
          } catch (_) {}

          final blocks = (allBytes.length / blockSize).ceil();
          for (int i = 0; i < blocks; i++) {
            final start = i * blockSize;
            final end = (start + blockSize > allBytes.length)
                ? allBytes.length
                : start + blockSize;
            final chunk = Uint8List(blockSize)
              ..setAll(0, allBytes.sublist(start, end));

            await iso.writeSingleBlock(
              blockNumber: i,
              dataBlock: chunk,
              requestFlags: {
                Iso15693RequestFlag.address,
                Iso15693RequestFlag.highDataRate,
              },
            );
          }

          await NfcManager.instance.stopSession();
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  /// Đọc dữ liệu từ thẻ ISO15693
  static Future<Uint8List?> readIso15693(int blockCount) async {
    final available = await isAvailable();
    if (!available) throw "NFC không khả dụng hoặc chưa bật";

    Uint8List? result;

    await NfcManager.instance.startSession(
      alertMessage: 'Giữ thẻ gần điện thoại để đọc',
      onDiscovered: (tag) async {
        try {
          final iso = Iso15693.from(tag);
          if (iso == null) throw 'Không phải thẻ ISO15693';

          final buffer = BytesBuilder();

          for (int i = 0; i < blockCount; i++) {
            final block = await iso.readSingleBlock(
              blockNumber: i,
              requestFlags: {
                Iso15693RequestFlag.address,
                Iso15693RequestFlag.highDataRate,
              },
            );
            buffer.add(block);
          }

          result = buffer.toBytes();
          await NfcManager.instance.stopSession();
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );

    return result;
  }
}

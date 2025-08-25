// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:nfc_manager/nfc_manager.dart';
// import 'package:nfc_manager/platform_tags.dart';
// import 'dart:convert';
//
// class DriverCardData {
//   String licenseNumber;
//   String driverName;
//
//   DriverCardData({
//     this.licenseNumber = '',
//     this.driverName = '',
//   });
// }
//
// class NFCDriverCardScreen extends StatefulWidget {
//   @override
//   _NFCDriverCardScreenState createState() => _NFCDriverCardScreenState();
// }
//
// class _NFCDriverCardScreenState extends State<NFCDriverCardScreen> {
//   bool _isNFCAvailable = false;
//   bool _isScanning = false;
//   bool _isEditing = false;
//   DriverCardData? _cardData;
//   String _statusMessage = '';
//   Color _statusColor = Colors.grey;
//
//   // Controllers cho form chỉnh sửa
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _licenseController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _checkNFCAvailability();
//   }
//
//   Future<void> _checkNFCAvailability() async {
//     bool isAvailable = await NfcManager.instance.isAvailable();
//     setState(() {
//       _isNFCAvailable = isAvailable;
//       _statusMessage = isAvailable ? 'NFC sẵn sàng' : 'NFC không khả dụng';
//       _statusColor = isAvailable ? Colors.green : Colors.red;
//     });
//   }
//
// // Kiểm tra dung lượng thẻ
//   Future<int> _getCardCapacity(NfcV nfcV) async {
//     try {
//       final command = Uint8List.fromList([
//         0x22, // Flags: addressed + high data rate
//         0x2B, // Get System Info
//         ...nfcV.identifier,
//       ]);
//
//       final response = await nfcV.transceive(data: command);
//       debugPrint('Get System Info response: $response');
//
//       if (response.length >= 15) {
//         int blockSize = response[12] + 1; // byte 12: block size (0-based)
//         int numberOfBlocks = response[13] + 1; // byte 13: số block (0-based)
//         int capacity = blockSize * numberOfBlocks;
//         debugPrint(
//             'Card blockSize: $blockSize, numberOfBlocks: $numberOfBlocks, capacity: $capacity bytes');
//         return capacity;
//       } else {
//         debugPrint(
//             'Không nhận được thông tin block đầy đủ, sử dụng mặc định 64 byte');
//         return 64;
//       }
//     } catch (e) {
//       debugPrint('Lỗi khi kiểm tra dung lượng thẻ: $e');
//       return 64; // fallback
//     }
//   }
//
//   // Parse dữ liệu 64 byte từ thẻ
//   // DriverCardData _parseCardData(Uint8List rawData) {
//   //   try {
//   //     // Kiểm tra độ dài dữ liệu
//   //     if (rawData.length < 64) {
//   //       throw Exception('Dữ liệu thẻ không đủ 64 byte');
//   //     }
//   //
//   //     // Đọc số GPLX (15 bytes)
//   //     String licenseNumber =
//   //         utf8.decode(rawData.sublist(0, 15), allowMalformed: true).trim();
//   //
//   //     // Kiểm tra mã kiểm tra GPLX (byte 16)
//   //     int licenseChecksum = 0;
//   //     for (int i = 0; i < 15; i++) {
//   //       licenseChecksum ^= rawData[i];
//   //     }
//   //     if (licenseChecksum != rawData[15]) {
//   //       print('Cảnh báo: Mã kiểm tra GPLX không khớp');
//   //     }
//   //
//   //     // Đọc họ tên (43 bytes)
//   //     String driverName =
//   //         utf8.decode(rawData.sublist(16, 59), allowMalformed: true).trim();
//   //
//   //     // Kiểm tra mã kiểm tra họ tên (byte 44)
//   //     int nameChecksum = 0;
//   //     for (int i = 16; i < 59; i++) {
//   //       nameChecksum ^= rawData[i];
//   //     }
//   //     if (nameChecksum != rawData[59]) {
//   //       print('Cảnh báo: Mã kiểm tra họ tên không khớp');
//   //     }
//   //
//   //     return DriverCardData(
//   //       licenseNumber: licenseNumber,
//   //       driverName: driverName,
//   //     );
//   //   } catch (e) {
//   //     print('Error parsing card data: $e');
//   //     return DriverCardData(licenseNumber: 'Unknown', driverName: 'Unknown');
//   //   }
//   // }
//   DriverCardData _parseCardData(Uint8List rawData) {
//     try {
//       if (rawData.length < 60) {
//         throw Exception('Dữ liệu thẻ không đủ 60 byte cố định');
//       }
//
//       // Đọc số GPLX (15 bytes)
//       String licenseNumber =
//           utf8.decode(rawData.sublist(0, 15), allowMalformed: true).trim();
//
//       // Mã kiểm tra GPLX (byte 16)
//       int licenseChecksum = 0;
//       for (int i = 0; i < 15; i++) {
//         licenseChecksum ^= rawData[i];
//       }
//       if (licenseChecksum != rawData[15]) {
//         print('Cảnh báo: Mã kiểm tra GPLX không khớp');
//       }
//
//       // Đọc họ tên (43 bytes)
//       String driverName =
//           utf8.decode(rawData.sublist(16, 59), allowMalformed: true).trim();
//
//       // Mã kiểm tra họ tên (byte 44)
//       int nameChecksum = 0;
//       for (int i = 16; i < 59; i++) {
//         nameChecksum ^= rawData[i];
//       }
//       if (nameChecksum != rawData[59]) {
//         print('Cảnh báo: Mã kiểm tra họ tên không khớp');
//       }
//
//       return DriverCardData(
//         licenseNumber: licenseNumber,
//         driverName: driverName,
//       );
//     } catch (e) {
//       print('Error parsing card data: $e');
//       return DriverCardData(licenseNumber: 'Unknown', driverName: 'Unknown');
//     }
//   }
//
//   // Chuyển đổi dữ liệu thành format 64 byte
//   Uint8List _encodeCardData(DriverCardData data) {
//     // Buffer 64 byte
//     Uint8List buffer = Uint8List(64);
//     buffer.fillRange(0, 64, 0); // Điền toàn bộ bằng 0 trước
//
//     try {
//       // Ghi số GPLX (15 bytes)
//       String license = data.licenseNumber.padRight(15, ' ').substring(0, 15);
//       List<int> licenseBytes = utf8.encode(license);
//       for (int i = 0; i < 15 && i < licenseBytes.length; i++) {
//         buffer[i] = licenseBytes[i];
//       }
//
//       // Tính mã kiểm tra cho GPLX (byte 16)
//       int licenseChecksum = 0;
//       for (int i = 0; i < 15; i++) {
//         licenseChecksum ^= buffer[i];
//       }
//       buffer[15] = licenseChecksum;
//
//       // Ghi họ tên (43 bytes)
//       String name = data.driverName.padRight(43, ' ').substring(0, 43);
//       List<int> nameBytes = utf8.encode(name);
//       for (int i = 0; i < 43 && i < nameBytes.length; i++) {
//         buffer[16 + i] = nameBytes[i];
//       }
//
//       // Tính mã kiểm tra cho họ tên (byte 44)
//       int nameChecksum = 0;
//       for (int i = 16; i < 59; i++) {
//         nameChecksum ^= buffer[i];
//       }
//       buffer[59] = nameChecksum;
//
//       // Các byte còn lại (60-63) để là 0 theo mặc định
//     } catch (e) {
//       print('Error encoding card data: $e');
//     }
//
//     return buffer;
//   }
//
//   // Future<void> _startScanning() async {
//   //   if (!_isNFCAvailable) {
//   //     _showSnackBar('NFC không khả dụng', Colors.red);
//   //     return;
//   //   }
//   //
//   //   setState(() {
//   //     _isScanning = true;
//   //     _statusMessage = 'Đang quét thẻ...';
//   //     _statusColor = Colors.orange;
//   //   });
//   //
//   //   debugPrint('--- Bắt đầu quét NFC ---');
//   //
//   //   try {
//   //     NfcManager.instance.startSession(
//   //       onDiscovered: (NfcTag tag) async {
//   //         debugPrint('Tag detected: ${tag.data}');
//   //         NfcV? nfcV;
//   //
//   //         // Thử dùng NfcV.from(tag) trước
//   //         nfcV = NfcV.from(tag);
//   //         debugPrint('NfcV.from(tag) returned: $nfcV');
//   //
//   //         // Nếu null, tạo thủ công
//   //         if (nfcV == null && tag.data['nfcv'] != null) {
//   //           try {
//   //             final nfcvData = tag.data['nfcv'];
//   //             nfcV = NfcV(
//   //               tag: tag,
//   //               identifier:
//   //                   Uint8List.fromList(List<int>.from(nfcvData['identifier'])),
//   //               dsfId: nfcvData['dsfId'] ?? 0,
//   //               responseFlags: nfcvData['responseFlags'] ?? 0,
//   //               maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
//   //             );
//   //             debugPrint('NfcV manually created: $nfcV');
//   //           } catch (e) {
//   //             debugPrint('Failed to create NfcV manually: $e');
//   //           }
//   //         }
//   //
//   //         if (nfcV == null) {
//   //           debugPrint('Không nhận diện được NfcV');
//   //           setState(() {
//   //             _statusMessage = 'Thẻ không phải loại ISO15693';
//   //             _statusColor = Colors.red;
//   //             _isScanning = false;
//   //           });
//   //           NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
//   //           return;
//   //         }
//   //
//   //         try {
//   //           // Kiểm tra dung lượng thẻ
//   //           int capacity = await _getCardCapacity(nfcV);
//   //           if (capacity < 64) {
//   //             setState(() {
//   //               _statusMessage = 'Thẻ có dung lượng quá nhỏ: $capacity bytes';
//   //               _statusColor = Colors.red;
//   //               _isScanning = false;
//   //             });
//   //             NfcManager.instance.stopSession(errorMessage: 'Thẻ quá nhỏ');
//   //             return;
//   //           }
//   //           debugPrint('Dung lượng thẻ: $capacity bytes, tiếp tục đọc...');
//   //           List<int> allData = [];
//   //           debugPrint('Bắt đầu đọc 16 block');
//   //
//   //           for (int i = 0; i < 16; i++) {
//   //             final command = Uint8List.fromList([
//   //               0x22, // Flags: addressed + high data rate
//   //               0x20, // Read single block
//   //               ...nfcV.identifier,
//   //               i,
//   //             ]);
//   //
//   //             debugPrint('Gửi lệnh đọc block $i: $command');
//   //
//   //             final blockData = await nfcV.transceive(data: command);
//   //
//   //             debugPrint('Block $i nhận: $blockData');
//   //
//   //             if (blockData.length > 1) {
//   //               allData.addAll(blockData.skip(1));
//   //             } else {
//   //               debugPrint('Block $i không đọc được dữ liệu hợp lệ');
//   //               throw Exception('Block $i không đọc được');
//   //             }
//   //           }
//   //
//   //           debugPrint('Tất cả dữ liệu đọc được: $allData');
//   //
//   //           if (allData.length >= 64) {
//   //             final cardData =
//   //                 _parseCardData(Uint8List.fromList(allData.take(64).toList()));
//   //
//   //             setState(() {
//   //               _cardData = cardData;
//   //               _statusMessage = 'Đọc thẻ thành công!';
//   //               _statusColor = Colors.green;
//   //               _isScanning = false;
//   //             });
//   //
//   //             _populateEditForm(cardData);
//   //           } else {
//   //             throw Exception('Không đủ dữ liệu từ thẻ');
//   //           }
//   //
//   //           debugPrint('Đọc thẻ hoàn tất, dừng session');
//   //           NfcManager.instance.stopSession();
//   //         } catch (e) {
//   //           debugPrint('Error reading NFC: $e');
//   //           setState(() {
//   //             _statusMessage = 'Lỗi đọc thẻ: $e';
//   //             _statusColor = Colors.red;
//   //             _isScanning = false;
//   //           });
//   //           NfcManager.instance.stopSession(errorMessage: 'Lỗi đọc thẻ');
//   //         }
//   //       },
//   //     );
//   //
//   //     // Timeout sau 10 giây
//   //     Future.delayed(Duration(seconds: 10), () {
//   //       if (_isScanning) {
//   //         debugPrint('Timeout 10s, dừng session');
//   //         NfcManager.instance.stopSession();
//   //         setState(() {
//   //           _isScanning = false;
//   //           _statusMessage = 'Timeout - Vui lòng thử lại';
//   //           _statusColor = Colors.orange;
//   //         });
//   //       }
//   //     });
//   //   } catch (e) {
//   //     debugPrint('Lỗi khi bắt đầu session NFC: $e');
//   //     setState(() {
//   //       _isScanning = false;
//   //       _statusMessage = 'Lỗi: $e';
//   //       _statusColor = Colors.red;
//   //     });
//   //   }
//   // }
//   //
//   // Future<void> _writeToCard() async {
//   //   if (_cardData == null) {
//   //     _showSnackBar('Chưa có dữ liệu thẻ', Colors.red);
//   //     return;
//   //   }
//   //
//   //   _cardData = DriverCardData(
//   //     driverName: _nameController.text,
//   //     licenseNumber: _licenseController.text,
//   //   );
//   //
//   //   setState(() {
//   //     _isScanning = true;
//   //     _statusMessage = 'Đặt thẻ gần thiết bị...';
//   //     _statusColor = Colors.orange;
//   //   });
//   //
//   //   debugPrint('--- Bắt đầu ghi thẻ ---');
//   //
//   //   try {
//   //     NfcManager.instance.startSession(
//   //       onDiscovered: (NfcTag tag) async {
//   //         NfcV? nfcV = NfcV.from(tag);
//   //
//   //         if (nfcV == null && tag.data['nfcv'] != null) {
//   //           final nfcvData = tag.data['nfcv'];
//   //           nfcV = NfcV(
//   //             tag: tag,
//   //             identifier:
//   //                 Uint8List.fromList(List<int>.from(nfcvData['identifier'])),
//   //             dsfId: nfcvData['dsfId'] ?? 0,
//   //             responseFlags: nfcvData['responseFlags'] ?? 0,
//   //             maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
//   //           );
//   //         }
//   //
//   //         if (nfcV == null) {
//   //           setState(() {
//   //             _statusMessage = 'Thẻ không phải loại ISO15693';
//   //             _statusColor = Colors.red;
//   //             _isScanning = false;
//   //           });
//   //           NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
//   //           return;
//   //         }
//   //
//   //         try {
//   //           final dataToWrite = _encodeCardData(_cardData!);
//   //
//   //           int successfulBlocks = 0;
//   //           List<int> failedBlocks = [];
//   //
//   //           for (int i = 0; i < 16; i++) {
//   //             int retry = 0;
//   //             bool success = false;
//   //
//   //             while (retry < 2 && !success) {
//   //               try {
//   //                 final blockData = dataToWrite.sublist(i * 4, (i + 1) * 4);
//   //                 final writeCommand = Uint8List.fromList([
//   //                   0x22, // Flags
//   //                   0x21, // Write single block
//   //                   ...nfcV.identifier, // UID nguyên bản
//   //                   i,
//   //                   ...blockData,
//   //                 ]);
//   //
//   //                 final response = await nfcV.transceive(data: writeCommand);
//   //                 debugPrint('Block $i response: $response');
//   //
//   //                 if (response.isNotEmpty && response[0] == 0x00) {
//   //                   success = true;
//   //                   successfulBlocks++;
//   //                   debugPrint('Block $i ghi thành công');
//   //                 } else {
//   //                   retry++;
//   //                   debugPrint('Block $i thất bại, retry $retry');
//   //                   await Future.delayed(Duration(milliseconds: 50));
//   //                 }
//   //               } catch (e) {
//   //                 retry++;
//   //                 debugPrint('Block $i lỗi: $e, retry $retry');
//   //                 await Future.delayed(Duration(milliseconds: 50));
//   //               }
//   //             }
//   //
//   //             if (!success) failedBlocks.add(i);
//   //
//   //             setState(() {
//   //               _statusMessage =
//   //                   'Đang ghi... ${successfulBlocks}/16 blocks (${failedBlocks.length} lỗi)';
//   //             });
//   //
//   //             await Future.delayed(Duration(milliseconds: 50));
//   //           }
//   //
//   //           setState(() {
//   //             if (successfulBlocks == 16) {
//   //               _statusMessage = 'Ghi thẻ hoàn toàn thành công!';
//   //               _statusColor = Colors.green;
//   //             } else {
//   //               _statusMessage =
//   //                   'Ghi một phần thành công: $successfulBlocks/16 blocks';
//   //               _statusColor = Colors.orange;
//   //             }
//   //             _isScanning = false;
//   //             _isEditing = false;
//   //           });
//   //
//   //           NfcManager.instance.stopSession();
//   //         } catch (e) {
//   //           debugPrint('Write error: $e');
//   //           setState(() {
//   //             _statusMessage = 'Lỗi ghi thẻ: $e';
//   //             _statusColor = Colors.red;
//   //             _isScanning = false;
//   //           });
//   //           NfcManager.instance.stopSession();
//   //         }
//   //       },
//   //       alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển trong khi ghi',
//   //     );
//   //
//   //     Future.delayed(Duration(seconds: 45), () {
//   //       if (_isScanning) {
//   //         NfcManager.instance.stopSession();
//   //         setState(() {
//   //           _isScanning = false;
//   //           _statusMessage = 'Timeout - Thẻ có thể không hỗ trợ ghi';
//   //           _statusColor = Colors.orange;
//   //         });
//   //       }
//   //     });
//   //   } catch (e) {
//   //     debugPrint('Lỗi khởi tạo ghi thẻ: $e');
//   //     setState(() {
//   //       _isScanning = false;
//   //       _statusMessage = 'Lỗi khởi tạo: $e';
//   //       _statusColor = Colors.red;
//   //     });
//   //   }
//   // }
//   Future<void> _startScanning() async {
//     if (!_isNFCAvailable) {
//       _showSnackBar('NFC không khả dụng', Colors.red);
//       return;
//     }
//
//     setState(() {
//       _isScanning = true;
//       _statusMessage = 'Đang quét thẻ...';
//       _statusColor = Colors.orange;
//     });
//
//     try {
//       NfcManager.instance.startSession(
//         onDiscovered: (NfcTag tag) async {
//           NfcV? nfcV = NfcV.from(tag);
//
//           // Nếu NfcV null, thử tạo thủ công
//           if (nfcV == null && tag.data['nfcv'] != null) {
//             final nfcvData = tag.data['nfcv'];
//             nfcV = NfcV(
//               tag: tag,
//               identifier:
//                   Uint8List.fromList(List<int>.from(nfcvData['identifier'])),
//               dsfId: nfcvData['dsfId'] ?? 0,
//               responseFlags: nfcvData['responseFlags'] ?? 0,
//               maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
//             );
//           }
//
//           if (nfcV == null) {
//             setState(() {
//               _statusMessage = 'Thẻ không phải ISO15693';
//               _statusColor = Colors.red;
//               _isScanning = false;
//             });
//             NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
//             return;
//           }
//
//           try {
//             // Lấy dung lượng thẻ
//             int capacity = await _getCardCapacity(nfcV);
//             int blockSize = 4; // chuẩn ISO15693, tùy thẻ có thể khác
//             int numberOfBlocks = (capacity / blockSize).ceil();
//
//             debugPrint(
//                 'Thẻ dung lượng $capacity bytes, số block $numberOfBlocks');
//
//             List<int> allData = [];
//
//             for (int i = 0; i < numberOfBlocks; i++) {
//               final command =
//                   Uint8List.fromList([0x22, 0x20, ...nfcV.identifier, i]);
//               final blockData = await nfcV.transceive(data: command);
//               if (blockData.length > 1) allData.addAll(blockData.skip(1));
//             }
//
//             debugPrint('Đọc thẻ xong, tổng bytes: ${allData.length}');
//             debugPrint('Đọc thẻ xong, tổng bytes: ${allData}');
//             // Lấy 60 byte đầu cố định
//             Uint8List fixedData = Uint8List.fromList(allData.take(60).toList());
//             // Phần dư động
//             Uint8List dynamicData =
//                 Uint8List.fromList(allData.skip(60).toList());
//
//             final cardData =
//                 _parseCardData(fixedData); // chỉ parse 60 byte cố định
//
//             setState(() {
//               _cardData = cardData;
//               _statusMessage = 'Đọc thẻ thành công!';
//               _statusColor = Colors.green;
//               _isScanning = false;
//             });
//
//             _populateEditForm(cardData);
//             NfcManager.instance.stopSession();
//           } catch (e) {
//             debugPrint('Lỗi đọc NFC: $e');
//             setState(() {
//               _statusMessage = 'Lỗi đọc thẻ: $e';
//               _statusColor = Colors.red;
//               _isScanning = false;
//             });
//             NfcManager.instance.stopSession(errorMessage: 'Lỗi đọc thẻ');
//           }
//         },
//       );
//     } catch (e) {
//       debugPrint('Lỗi khi quét NFC: $e');
//       setState(() {
//         _isScanning = false;
//         _statusMessage = 'Lỗi: $e';
//         _statusColor = Colors.red;
//       });
//     }
//   }
//
//   Future<void> _writeToCard() async {
//     if (_cardData == null) {
//       _showSnackBar('Chưa có dữ liệu thẻ', Colors.red);
//       return;
//     }
//
//     _cardData = DriverCardData(
//       driverName: _nameController.text,
//       licenseNumber: _licenseController.text,
//     );
//
//     setState(() {
//       _isScanning = true;
//       _statusMessage = 'Đặt thẻ gần thiết bị...';
//       _statusColor = Colors.orange;
//     });
//
//     try {
//       NfcManager.instance.startSession(
//         onDiscovered: (NfcTag tag) async {
//           NfcV? nfcV = NfcV.from(tag);
//
//           if (nfcV == null && tag.data['nfcv'] != null) {
//             final nfcvData = tag.data['nfcv'];
//             nfcV = NfcV(
//               tag: tag,
//               identifier:
//                   Uint8List.fromList(List<int>.from(nfcvData['identifier'])),
//               dsfId: nfcvData['dsfId'] ?? 0,
//               responseFlags: nfcvData['responseFlags'] ?? 0,
//               maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
//             );
//           }
//
//           if (nfcV == null) {
//             setState(() {
//               _statusMessage = 'Thẻ không phải ISO15693';
//               _statusColor = Colors.red;
//               _isScanning = false;
//             });
//             NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
//             return;
//           }
//
//           try {
//             int capacity = await _getCardCapacity(nfcV);
//             int blockSize = 4;
//             int numberOfBlocks = (capacity / blockSize).ceil();
//
//             // Chuẩn bị dữ liệu ghi: 60 byte cố định + phần dư động nếu có
//             Uint8List fixedData =
//                 _encodeCardData(_cardData!); // 60 byte cố định
//             Uint8List dynamicData =
//                 Uint8List(capacity - 60); // dữ liệu sau có thể để 0
//             Uint8List dataToWrite =
//                 Uint8List.fromList([...fixedData, ...dynamicData]);
//
//             int successfulBlocks = 0;
//
//             for (int i = 0; i < numberOfBlocks; i++) {
//               int start = i * blockSize;
//               int end = (start + blockSize > dataToWrite.length)
//                   ? dataToWrite.length
//                   : start + blockSize;
//               Uint8List blockData = dataToWrite.sublist(start, end);
//
//               final writeCommand = Uint8List.fromList(
//                   [0x22, 0x21, ...nfcV.identifier, i, ...blockData]);
//               final response = await nfcV.transceive(data: writeCommand);
//               if (response.isNotEmpty && response[0] == 0x00) {
//                 successfulBlocks++;
//               }
//             }
//
//             setState(() {
//               _statusMessage =
//                   'Ghi xong $successfulBlocks/$numberOfBlocks blocks';
//               _statusColor = (successfulBlocks == numberOfBlocks)
//                   ? Colors.green
//                   : Colors.orange;
//               _isScanning = false;
//               _isEditing = false;
//             });
//
//             NfcManager.instance.stopSession();
//           } catch (e) {
//             debugPrint('Lỗi ghi NFC: $e');
//             setState(() {
//               _statusMessage = 'Lỗi ghi thẻ: $e';
//               _statusColor = Colors.red;
//               _isScanning = false;
//             });
//             NfcManager.instance.stopSession();
//           }
//         },
//         alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển',
//       );
//     } catch (e) {
//       debugPrint('Lỗi khởi tạo ghi thẻ: $e');
//       setState(() {
//         _isScanning = false;
//         _statusMessage = 'Lỗi: $e';
//         _statusColor = Colors.red;
//       });
//     }
//   }
//
//   void _populateEditForm(DriverCardData data) {
//     _nameController.text = data.driverName;
//     _licenseController.text = data.licenseNumber;
//   }
//
//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Đọc/Ghi Thẻ Lái Xe NFC'),
//         backgroundColor: Colors.blue[700],
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue[700]!, Colors.blue[50]!],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Status Card
//                 Card(
//                   elevation: 4,
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Trạng thái NFC',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Icon(
//                               _isNFCAvailable ? Icons.wifi : Icons.wifi_off,
//                               color: _statusColor,
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           _statusMessage,
//                           style: TextStyle(
//                             color: _statusColor,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             ElevatedButton.icon(
//                               onPressed: _isScanning ? null : _startScanning,
//                               icon: _isScanning
//                                   ? SizedBox(
//                                       width: 16,
//                                       height: 16,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor:
//                                             AlwaysStoppedAnimation<Color>(
//                                                 Colors.white),
//                                       ),
//                                     )
//                                   : Icon(Icons.nfc),
//                               label:
//                                   Text(_isScanning ? 'Đang đọc...' : 'Đọc Thẻ'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.blue[600],
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                             if (_cardData != null)
//                               ElevatedButton.icon(
//                                 onPressed: () =>
//                                     setState(() => _isEditing = !_isEditing),
//                                 icon:
//                                     Icon(_isEditing ? Icons.close : Icons.edit),
//                                 label: Text(_isEditing ? 'Hủy' : 'Chỉnh sửa'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.green[600],
//                                   foregroundColor: Colors.white,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 SizedBox(height: 16),
//
//                 // Card Data Display
//                 Expanded(
//                   child: _cardData == null
//                       ? _buildInstructionsCard()
//                       : _isEditing
//                           ? _buildEditForm()
//                           : _buildCardDataDisplay(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInstructionsCard() {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.credit_card,
//               size: 80,
//               color: Colors.blue[300],
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Hướng dẫn sử dụng',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               '• Đưa thẻ lái xe gần thiết bị\n'
//               '• Nhấn nút "Đọc Thẻ"\n'
//               '• Thẻ sử dụng công nghệ RFID 13.56MHz\n'
//               '• Chuẩn ISO/IEC 15693 (NFC Type V)',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEditForm() {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Chỉnh sửa thông tin',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     TextField(
//                       controller: _nameController,
//                       decoration: InputDecoration(
//                         labelText: 'Họ và tên',
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLength: 43,
//                     ),
//                     SizedBox(height: 12),
//                     TextField(
//                       controller: _licenseController,
//                       decoration: InputDecoration(
//                         labelText: 'Số GPLX',
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLength: 15,
//                     ),
//                     SizedBox(height: 20),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: _isScanning ? null : _writeToCard,
//                         icon: _isScanning
//                             ? SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                       Colors.white),
//                                 ),
//                               )
//                             : Icon(Icons.save),
//                         label:
//                             Text(_isScanning ? 'Đang ghi...' : 'Ghi vào Thẻ'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange[600],
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCardDataDisplay() {
//     return SingleChildScrollView(
//       child: Card(
//         elevation: 4,
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Icon(Icons.person, color: Colors.green[600]),
//                   SizedBox(width: 8),
//                   Text(
//                     'Thông tin Lái xe',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12),
//               _buildInfoRow('Họ tên', _cardData!.driverName),
//               _buildInfoRow('Số GPLX', _cardData!.licenseNumber),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isNotEmpty ? value : 'Chưa có dữ liệu',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: value.isNotEmpty ? Colors.black87 : Colors.grey,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _licenseController.dispose();
//     super.dispose();
//   }
// }
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'dart:convert';

class DriverCardData {
  String licenseNumber;
  String driverName;

  DriverCardData({
    this.licenseNumber = '',
    this.driverName = '',
  });
}

class NFCDriverCardScreen extends StatefulWidget {
  @override
  _NFCDriverCardScreenState createState() => _NFCDriverCardScreenState();
}

class _NFCDriverCardScreenState extends State<NFCDriverCardScreen> {
  bool _isNFCAvailable = false;
  bool _isScanning = false;
  bool _isEditing = false;
  DriverCardData? _cardData;
  String _statusMessage = '';
  Color _statusColor = Colors.grey;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkNFCAvailability();
  }

  Future<void> _checkNFCAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    setState(() {
      _isNFCAvailable = isAvailable;
      _statusMessage = isAvailable ? 'NFC sẵn sàng' : 'NFC không khả dụng';
      _statusColor = isAvailable ? Colors.green : Colors.red;
    });
  }

  Future<int> _getCardCapacity(NfcV nfcV) async {
    try {
      final command = Uint8List.fromList([
        0x22, // Flags
        0x2B, // Get System Info
        ...nfcV.identifier,
      ]);
      final response = await nfcV.transceive(data: command);
      debugPrint('Get System Info response: $response');
      if (response.length >= 15) {
        int blockSize = response[12] + 1;
        int numberOfBlocks = response[13] + 1;
        int capacity = blockSize * numberOfBlocks;
        debugPrint('Card capacity: $capacity bytes');
        return capacity;
      } else {
        return 64;
      }
    } catch (e) {
      debugPrint('Error getting card capacity: $e');
      return 64;
    }
  }

  DriverCardData _parseCardData(Uint8List rawData) {
    try {
      if (rawData.length < 60) {
        throw Exception('Dữ liệu thẻ không đủ 60 byte cố định');
      }
      String licenseNumber =
          utf8.decode(rawData.sublist(0, 15), allowMalformed: true).trim();

      int licenseChecksum = 0;
      for (int i = 0; i < 15; i++) licenseChecksum ^= rawData[i];
      if (licenseChecksum != rawData[15]) {
        print('Cảnh báo: Mã kiểm tra GPLX không khớp');
      }

      String driverName =
          utf8.decode(rawData.sublist(16, 59), allowMalformed: true).trim();

      int nameChecksum = 0;
      for (int i = 16; i < 59; i++) nameChecksum ^= rawData[i];
      if (nameChecksum != rawData[59]) {
        print('Cảnh báo: Mã kiểm tra họ tên không khớp');
      }

      return DriverCardData(
        licenseNumber: licenseNumber,
        driverName: driverName,
      );
    } catch (e) {
      print('Error parsing card data: $e');
      return DriverCardData(licenseNumber: 'Unknown', driverName: 'Unknown');
    }
  }

  Uint8List _encodeCardData(DriverCardData data) {
    Uint8List buffer = Uint8List(64);
    buffer.fillRange(0, 64, 0);

    try {
      String license = data.licenseNumber.padRight(15, ' ').substring(0, 15);
      List<int> licenseBytes = utf8.encode(license);
      for (int i = 0; i < 15 && i < licenseBytes.length; i++)
        buffer[i] = licenseBytes[i];

      int licenseChecksum = 0;
      for (int i = 0; i < 15; i++) licenseChecksum ^= buffer[i];
      buffer[15] = licenseChecksum;

      String name = data.driverName.padRight(43, ' ').substring(0, 43);
      List<int> nameBytes = utf8.encode(name);
      for (int i = 0; i < 43 && i < nameBytes.length; i++)
        buffer[16 + i] = nameBytes[i];

      int nameChecksum = 0;
      for (int i = 16; i < 59; i++) nameChecksum ^= buffer[i];
      buffer[59] = nameChecksum;
    } catch (e) {
      print('Error encoding card data: $e');
    }

    return buffer;
  }

  Future<void> _startScanning() async {
    if (!_isNFCAvailable) {
      _showSnackBar('NFC không khả dụng', Colors.red);
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Đang quét thẻ...';
      _statusColor = Colors.orange;
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          NfcV? nfcV = NfcV.from(tag);

          if (nfcV == null && tag.data['nfcv'] != null) {
            final nfcvData = tag.data['nfcv'];
            nfcV = NfcV(
              tag: tag,
              identifier:
                  Uint8List.fromList(List<int>.from(nfcvData['identifier'])),
              dsfId: nfcvData['dsfId'] ?? 0,
              responseFlags: nfcvData['responseFlags'] ?? 0,
              maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
            );
          }

          if (nfcV == null) {
            setState(() {
              _statusMessage = 'Thẻ không phải ISO15693';
              _statusColor = Colors.red;
              _isScanning = false;
            });
            NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
            return;
          }

          try {
            int capacity = await _getCardCapacity(nfcV);
            int blockSize = 4;
            int numberOfBlocks = (capacity / blockSize).ceil();

            List<int> allData = [];
            for (int i = 0; i < numberOfBlocks; i++) {
              final command =
                  Uint8List.fromList([0x22, 0x20, ...nfcV.identifier, i]);
              final blockData = await nfcV.transceive(data: command);
              if (blockData.length > 1) allData.addAll(blockData.skip(1));
            }
            debugPrint("data: ${allData.toString()}");
            debugPrint("data length: ${allData.length}");
            Uint8List fixedData = Uint8List.fromList(allData.take(60).toList());
            final cardData = _parseCardData(fixedData);

            setState(() {
              _cardData = cardData;
              _statusMessage = 'Đọc thẻ thành công!';
              _statusColor = Colors.green;
              _isScanning = false;
            });

            _populateEditForm(cardData);
            NfcManager.instance.stopSession();
          } catch (e) {
            debugPrint('Lỗi đọc NFC: $e');
            setState(() {
              _statusMessage = 'Lỗi đọc thẻ: $e';
              _statusColor = Colors.red;
              _isScanning = false;
            });
            NfcManager.instance.stopSession(errorMessage: 'Lỗi đọc thẻ');
          }
        },
      );
    } catch (e) {
      debugPrint('Lỗi khi quét NFC: $e');
      setState(() {
        _isScanning = false;
        _statusMessage = 'Lỗi: $e';
        _statusColor = Colors.red;
      });
    }
  }

  Future<void> _writeToCard() async {
    if (_cardData == null) {
      _showSnackBar('Chưa có dữ liệu thẻ', Colors.red);
      return;
    }

    _cardData = DriverCardData(
      driverName: _nameController.text,
      licenseNumber: _licenseController.text,
    );

    setState(() {
      _isScanning = true;
      _statusMessage = 'Đặt thẻ gần thiết bị...';
      _statusColor = Colors.orange;
    });

    try {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          NfcV? nfcV = NfcV.from(tag);

          if (nfcV == null && tag.data['nfcv'] != null) {
            final nfcvData = tag.data['nfcv'];
            nfcV = NfcV(
              tag: tag,
              identifier:
                  Uint8List.fromList(List<int>.from(nfcvData['identifier'])),
              dsfId: nfcvData['dsfId'] ?? 0,
              responseFlags: nfcvData['responseFlags'] ?? 0,
              maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
            );
          }

          if (nfcV == null) {
            setState(() {
              _statusMessage = 'Thẻ không phải ISO15693';
              _statusColor = Colors.red;
              _isScanning = false;
            });
            NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
            return;
          }

          try {
            int capacity = await _getCardCapacity(nfcV);
            int blockSize = 4;
            int numberOfBlocks = (capacity / blockSize).ceil();

            Uint8List fixedData = _encodeCardData(_cardData!);
            Uint8List dynamicData = Uint8List(capacity - 60);
            Uint8List dataToWrite =
                Uint8List.fromList([...fixedData, ...dynamicData]);

            int successfulBlocks = 0;
            for (int i = 0; i < numberOfBlocks; i++) {
              int start = i * blockSize;
              int end = (start + blockSize > dataToWrite.length)
                  ? dataToWrite.length
                  : start + blockSize;
              Uint8List blockData = dataToWrite.sublist(start, end);

              final writeCommand = Uint8List.fromList(
                  [0x22, 0x21, ...nfcV.identifier, i, ...blockData]);
              final response = await nfcV.transceive(data: writeCommand);
              if (response.isNotEmpty && response[0] == 0x00)
                successfulBlocks++;
            }

            setState(() {
              _statusMessage =
                  'Ghi xong $successfulBlocks/$numberOfBlocks blocks';
              _statusColor = (successfulBlocks == numberOfBlocks)
                  ? Colors.green
                  : Colors.orange;
              _isScanning = false;
              _isEditing = false;
            });

            NfcManager.instance.stopSession();
          } catch (e) {
            debugPrint('Lỗi ghi NFC: $e');
            setState(() {
              _statusMessage = 'Lỗi ghi thẻ: $e';
              _statusColor = Colors.red;
              _isScanning = false;
            });
            NfcManager.instance.stopSession();
          }
        },
        alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển',
      );
    } catch (e) {
      debugPrint('Lỗi khởi tạo ghi thẻ: $e');
      setState(() {
        _isScanning = false;
        _statusMessage = 'Lỗi: $e';
        _statusColor = Colors.red;
      });
    }
  }

  void _populateEditForm(DriverCardData data) {
    _nameController.text = data.driverName;
    _licenseController.text = data.licenseNumber;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đọc/Ghi Thẻ Lái Xe NFC'),
        backgroundColor: Colors.blue[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[50]!],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Trạng thái NFC',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Icon(_isNFCAvailable ? Icons.wifi : Icons.wifi_off,
                                color: _statusColor),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(_statusMessage,
                            style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isScanning ? null : _startScanning,
                              icon: _isScanning
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white)))
                                  : Icon(Icons.nfc),
                              label:
                                  Text(_isScanning ? 'Đang đọc...' : 'Đọc Thẻ'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white),
                            ),
                            if (_cardData != null)
                              ElevatedButton.icon(
                                onPressed: () =>
                                    setState(() => _isEditing = !_isEditing),
                                icon:
                                    Icon(_isEditing ? Icons.close : Icons.edit),
                                label: Text(_isEditing ? 'Hủy' : 'Chỉnh sửa'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: _cardData == null
                      ? _buildInstructionsCard()
                      : _isEditing
                          ? _buildEditForm()
                          : _buildCardDataDisplay(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 80, color: Colors.blue[300]),
            SizedBox(height: 20),
            Text('Hướng dẫn sử dụng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              '• Đưa thẻ lái xe gần thiết bị\n• Nhấn nút "Đọc Thẻ"\n• Thẻ sử dụng công nghệ RFID 13.56MHz\n• Chuẩn ISO/IEC 15693 (NFC Type V)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chỉnh sửa thông tin',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            labelText: 'Họ và tên',
                            border: OutlineInputBorder()),
                        maxLength: 43),
                    SizedBox(height: 12),
                    TextField(
                        controller: _licenseController,
                        decoration: InputDecoration(
                            labelText: 'Số GPLX', border: OutlineInputBorder()),
                        maxLength: 15),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isScanning ? null : _writeToCard,
                        icon: _isScanning
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white)))
                            : Icon(Icons.save),
                        label:
                            Text(_isScanning ? 'Đang ghi...' : 'Ghi vào Thẻ'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDataDisplay() {
    return SingleChildScrollView(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.green[600]),
                SizedBox(width: 8),
                Text('Thông tin Lái xe',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            _buildInfoRow('Họ tên', _cardData!.driverName),
            _buildInfoRow('Số GPLX', _cardData!.licenseNumber),
          ]),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text('$label:',
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.w500))),
          Expanded(
              child: Text(value.isNotEmpty ? value : 'Chưa có dữ liệu',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: value.isNotEmpty ? Colors.black87 : Colors.grey))),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    super.dispose();
  }
}

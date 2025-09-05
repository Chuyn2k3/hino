// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:hino/utils/iso15693_channel.dart';
// import 'package:nfc_manager/nfc_manager.dart';
// import 'package:nfc_manager/platform_tags.dart';
//
// class DriverCardData {
//   String licenseNumber;
//   String driverName;
//   String userId;
//
//   DriverCardData({
//     this.licenseNumber = '',
//     this.driverName = '',
//     this.userId = '',
//   });
// }
//
// typedef OnCardRead = void Function(DriverCardData data);
// typedef OnError = void Function(String error);
// typedef OnStatus = void Function(String message);
//
// class NfcHelper {
//   /// Kiểm tra NFC có khả dụng hay không
//   static Future<bool> isNfcAvailable() async {
//     bool available = await NfcManager.instance.isAvailable();
//     if (Platform.isIOS && available) {
//       print('NFC available on iOS');
//     }
//     return available;
//   }
//
//   static DriverCardData parseCardData(BuildContext context, Uint8List rawData) {
//     try {
//       if (rawData.length < 60) {
//         // DebugHelper.show(context, "❌ Dữ liệu không đủ 60 byte");
//         throw Exception(rawData.length);
//       }
//
//       //DebugHelper.show(context, "RawData: ${rawData.take(20).toList()}...");
//
//       // --- GPLX ---
//       // --- GPLX ---
//       String licenseNumber =
//           utf8.decode(rawData.sublist(0, 15), allowMalformed: true).trim();
//       // DebugHelper.show(context, "GPLX: $licenseNumber");
//
//       int licenseChecksum = calcChecksum(rawData, 0, 14);
//       // DebugHelper.show(
//       //   context,
//       //   "GPLX checksum = $licenseChecksum (trên thẻ: ${rawData[15]})",
//       // );
//
// // --- Tên ---
//       String driverName =
//           utf8.decode(rawData.sublist(16, 59), allowMalformed: true).trim();
//       //    DebugHelper.show(context, "Tên: $driverName");
//
//       int nameChecksum = calcChecksum(rawData, 16, 58);
//       // DebugHelper.show(
//       //   context,
//       //   "Tên checksum = $nameChecksum (trên thẻ: ${rawData[59]})",
//       // );
//       String userId = "";
//       if (rawData.length > 60) {
//         userId = utf8.decode(rawData.sublist(60), allowMalformed: true).trim();
//       }
//       return DriverCardData(
//         licenseNumber: licenseNumber,
//         driverName: driverName,
//         userId: userId,
//       );
//     } catch (e) {
//       //  DebugHelper.show(context, "❌ Parse error: $e");
//       return DriverCardData(licenseNumber: 'Unknown', driverName: 'Unknown');
//     }
//   }
//
//   /// Chuyển DriverCardData thành Uint8List để ghi thẻ
//   // static Uint8List encodeCardData(DriverCardData data, {int fixedSize = 64}) {
//   //   Uint8List buffer = Uint8List(fixedSize);
//   //   buffer.fillRange(0, fixedSize, 0);
//
//   //   try {
//   //     List<int> licenseBytes = utf8.encode(data.licenseNumber);
//   //     int licenseLength = licenseBytes.length > 15 ? 15 : licenseBytes.length;
//   //     for (int i = 0; i < licenseLength; i++) {
//   //       buffer[i] = licenseBytes[i];
//   //     }
//
//   //     int licenseChecksum = 0;
//   //     for (int i = 0; i < 15; i++) {
//   //       licenseChecksum ^= buffer[i];
//   //     }
//   //     buffer[15] = licenseChecksum;
//
//   //     List<int> nameBytes = utf8.encode(data.driverName);
//   //     int nameLength = nameBytes.length > 43 ? 43 : nameBytes.length;
//   //     for (int i = 0; i < nameLength; i++) {
//   //       buffer[16 + i] = nameBytes[i];
//   //     }
//
//   //     int nameChecksum = 0;
//   //     for (int i = 16; i < 59; i++) {
//   //       nameChecksum ^= buffer[i];
//   //     }
//   //     buffer[59] = nameChecksum;
//   //   } catch (e) {
//   //     print('Lỗi khi mã hóa dữ liệu thẻ: $e');
//   //   }
//
//   //   return buffer;
//   // }
//   static Uint8List encodeCardData(
//     DriverCardData data, {
//     int fixedSize = 64,
//     Uint8List? manufacturerId,
//   }) {
//     Uint8List buffer = Uint8List(fixedSize);
//     buffer.fillRange(0, fixedSize, 0);
//
//     try {
//       // --- GPLX (15 byte + checksum) ---
//       List<int> licenseBytes = utf8.encode(data.licenseNumber);
//       for (int i = 0; i < 15; i++) {
//         if (i < licenseBytes.length) {
//           buffer[i] = licenseBytes[i];
//         } else {
//           buffer[i] = 0x00; // pad bằng null byte
//         }
//       }
//       buffer[15] = calcChecksum(buffer, 0, 14);
//
//       // --- Họ tên (43 byte + checksum) ---
//       List<int> nameBytes = utf8.encode(data.driverName);
//       for (int i = 0; i < 43; i++) {
//         if (i < nameBytes.length) {
//           buffer[16 + i] = nameBytes[i];
//         } else {
//           buffer[16 + i] = 0x00; // pad bằng null byte
//         }
//       }
//       buffer[59] = calcChecksum(buffer, 16, 58);
//       print("userId10 ${data.userId} ${buffer.length}");
//       // --- 4 byte cuối (manufacturerId) ---
//       if (data.userId.isNotEmpty) {
//         String userIdStr = "HMV_${data.userId}";
//         List<int> userIdBytes = utf8.encode(userIdStr);
//         for (int i = 0;
//             i < userIdBytes.length && (60 + i) < buffer.length;
//             i++) {
//           buffer[60 + i] = userIdBytes[i];
//         }
//       }
//     } catch (e) {
//       print('Lỗi khi mã hóa dữ liệu thẻ: $e');
//     }
//
//     return buffer;
//   }
//
//   /// Hàm tính checksum (tổng modulo 256)
//   static int calcChecksum(Uint8List buffer, int start, int end) {
//     int sum = 0;
//     for (int i = start; i <= end; i++) {
//       sum += buffer[i];
//     }
//     return sum & 0xFF; // chỉ lấy 1 byte thấp
//   }
//
//   /// Lấy dung lượng thẻ ISO15693
//   static Future<int> getCardCapacity(dynamic tag) async {
//     try {
//       Uint8List identifier;
//       if (Platform.isAndroid) {
//         final nfcV = tag as NfcV;
//         identifier = nfcV.identifier;
//       } else {
//         identifier = Uint8List.fromList(
//             List<int>.from(tag.data['iso15693']['identifier']));
//       }
//       final command = Uint8List.fromList([0x22, 0x2B, ...identifier]);
//       final response = await tag.transceive(data: command);
//       if (response.length >= 15) {
//         int blockSize = response[12] + 1;
//         int numberOfBlocks = response[13] + 1;
//         return blockSize * numberOfBlocks;
//       }
//       return 64; // Giá trị dự phòng
//     } catch (e) {
//       print('Error getting card capacity: $e');
//       return 64;
//     }
//   }
//
//   static Future<void> readCard({
//     required BuildContext context,
//     required OnCardRead onCardRead,
//     OnError? onError,
//     OnStatus? onStatus,
//   }) async {
//     try {
//       await NfcManager.instance.startSession(
//         pollingOptions: {NfcPollingOption.iso15693},
//         onDiscovered: (NfcTag tag) async {
//           try {
//             List<int> allData = [];
//
//             if (Platform.isAndroid) {
//               final nfcV = NfcV.from(tag);
//               if (nfcV == null) {
//                 onError?.call('Thẻ không phải ISO15693');
//                 await NfcManager.instance
//                     .stopSession(errorMessage: 'Thẻ không hợp lệ');
//                 return;
//               }
//
//               int blockSize = 4;
//               int capacity = await getCardCapacity(nfcV);
//               int numberOfBlocks = (capacity / blockSize).ceil();
//
//               for (int i = 0; i < numberOfBlocks; i++) {
//                 final command =
//                     Uint8List.fromList([0x22, 0x20, ...nfcV.identifier, i]);
//                 final blockData = await nfcV.transceive(data: command);
//                 if (blockData.length > 1) allData.addAll(blockData.skip(1));
//                 onStatus?.call('Đang đọc khối ${i + 1}/$numberOfBlocks');
//               }
//             } else if (Platform.isIOS) {
//               //  DebugHelper.show(context, tag.toString());
//               final isoTag = Iso15693.from(tag);
//               if (isoTag == null) {
//                 onError?.call('Thẻ không phải ISO15693');
//                 await NfcManager.instance
//                     .stopSession(errorMessage: 'Thẻ không hợp lệ');
//                 return;
//               }
//
//               int numberOfBlocks = 15; // 60 byte cố định / 4 byte
//               for (int i = 0; i < numberOfBlocks; i++) {
//                 final blockData = await isoTag.readSingleBlock(
//                     requestFlags: {Iso15693RequestFlag.highDataRate},
//                     blockNumber: i);
//                 allData.addAll(blockData);
//                 onStatus?.call('Đang đọc khối ${i + 1}/$numberOfBlocks');
//               }
//             }
//
//             Uint8List fixedData = Uint8List.fromList(allData.take(60).toList());
//             final cardData = parseCardData(context, fixedData);
//
//             onCardRead(cardData);
//             await NfcManager.instance.stopSession();
//           } catch (e, stackTrace) {
//             print('Lỗi đọc thẻ: $e\n$stackTrace');
//             onError?.call('Chưa đọc được thẻ, vui lòng thử lại');
//             await NfcManager.instance.stopSession(errorMessage: 'Lỗi đọc thẻ');
//           }
//         },
//         alertMessage: 'Đặt thẻ gần thiết bị để đọc',
//       );
//     } catch (e, stackTrace) {
//       print('Lỗi khởi động NFC: $e\n$stackTrace');
//       onError?.call('Chưa đọc được thẻ');
//     }
//   }
//
//   /// Ghi dữ liệu ra thẻ NFC
//   // static Future<void> writeCard({
//   //   required DriverCardData data,
//   //   OnError? onError,
//   //   OnStatus? onStatus,
//   // }) async {
//   //   try {
//   //     await NfcManager.instance.startSession(
//   //       pollingOptions: {NfcPollingOption.iso15693},
//   //       onDiscovered: (NfcTag tag) async {
//   //         try {
//   //           print('Tag detected: ${tag.data}');
//
//   //           dynamic nfcTag;
//   //           Uint8List identifier;
//   //           if (Platform.isAndroid) {
//   //             nfcTag = NfcV.from(tag);
//   //             if (nfcTag == null && tag.data['nfcv'] != null) {
//   //               final nfcvData = tag.data['nfcv'];
//   //               nfcTag = NfcV(
//   //                 tag: tag,
//   //                 identifier: Uint8List.fromList(
//   //                     List<int>.from(nfcvData['identifier'])),
//   //                 dsfId: nfcvData['dsfId'] ?? 0,
//   //                 responseFlags: nfcvData['responseFlags'] ?? 0,
//   //                 maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
//   //               );
//   //             }
//   //             if (nfcTag == null) {
//   //               final message = 'Thẻ không phải ISO15693';
//   //               print(message);
//   //               onError?.call(message);
//   //               NfcManager.instance
//   //                   .stopSession(errorMessage: 'Thẻ không hợp lệ');
//   //               return;
//   //             }
//   //             identifier = nfcTag.identifier;
//   //           } else {
//   //             if (!tag.data.containsKey('iso15693')) {
//   //               final message = 'Thẻ không phải ISO15693';
//   //               print(message);
//   //               onError?.call(message);
//   //               NfcManager.instance
//   //                   .stopSession(errorMessage: 'Thẻ không hợp lệ');
//   //               return;
//   //             }
//   //             nfcTag = tag;
//   //             identifier = Uint8List.fromList(
//   //                 List<int>.from(tag.data['iso15693']['identifier']));
//   //           }
//
//   //           int capacity = await getCardCapacity(nfcTag);
//   //           int blockSize = 4;
//   //           int numberOfBlocks = (capacity / blockSize).ceil();
//
//   //           Uint8List fixedData = encodeCardData(data);
//   //           Uint8List dynamicData = Uint8List(capacity - 60);
//   //           Uint8List dataToWrite =
//   //               Uint8List.fromList([...fixedData, ...dynamicData]);
//
//   //           int successfulBlocks = 0;
//   //           for (int i = 0; i < numberOfBlocks; i++) {
//   //             int start = i * blockSize;
//   //             int end = (start + blockSize > dataToWrite.length)
//   //                 ? dataToWrite.length
//   //                 : start + blockSize;
//   //             Uint8List blockData = dataToWrite.sublist(start, end);
//
//   //             try {
//   //               final writeCommand = Uint8List.fromList(
//   //                   [0x22, 0x21, ...identifier, i, ...blockData]);
//   //               final response = await nfcTag.transceive(data: writeCommand);
//   //               if (response.isNotEmpty && response[0] == 0x00) {
//   //                 successfulBlocks++;
//   //               }
//   //               onStatus?.call('Đang ghi khối ${i + 1}/$numberOfBlocks');
//   //             } catch (e) {
//   //               print('Lỗi ghi khối $i: $e');
//   //               continue; // Tiếp tục với khối tiếp theo nếu có lỗi
//   //             }
//   //           }
//
//   //           final message = 'Ghi xong $successfulBlocks/$numberOfBlocks khối';
//   //           print(message);
//   //           onStatus?.call(message);
//   //           NfcManager.instance.stopSession();
//   //         } catch (e, stackTrace) {
//   //           final message = 'Lỗi ghi thẻ: $e\n$stackTrace';
//   //           print(message);
//   //           onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ: $e');
//   //           NfcManager.instance.stopSession(errorMessage: 'Lỗi ghi thẻ: $e');
//   //         }
//   //       },
//   //       alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển',
//   //     );
//   //   } catch (e, stackTrace) {
//   //     final message = 'Lỗi khởi động phiên NFC: $e\n$stackTrace';
//   //     print(message);
//   //     onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ: $e');
//   //   }
//   // }
//   static Future<void> writeCard({
//     required DriverCardData data,
//     OnError? onError,
//     OnStatus? onStatus,
//   }) async {
//     try {
//       await NfcManager.instance.startSession(
//         pollingOptions: {NfcPollingOption.iso15693},
//         onDiscovered: (NfcTag tag) async {
//           try {
//             print('Tag detected: ${tag.data}');
//
//             dynamic nfcTag;
//             Uint8List identifier;
//
//             if (Platform.isAndroid) {
//               // Android: vẫn dùng NfcV + transceive
//               nfcTag = NfcV.from(tag);
//               if (nfcTag == null && tag.data['nfcv'] != null) {
//                 final nfcvData = tag.data['nfcv'];
//                 nfcTag = NfcV(
//                   tag: tag,
//                   identifier: Uint8List.fromList(
//                       List<int>.from(nfcvData['identifier'])),
//                   dsfId: nfcvData['dsfId'] ?? 0,
//                   responseFlags: nfcvData['responseFlags'] ?? 0,
//                   maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
//                 );
//               }
//               if (nfcTag == null) {
//                 final message = 'Thẻ không phải ISO15693';
//                 print(message);
//                 onError?.call(message);
//                 NfcManager.instance
//                     .stopSession(errorMessage: 'Thẻ không hợp lệ');
//                 return;
//               }
//               identifier = nfcTag.identifier;
//             } else {
//               // iOS: dùng Iso15693 wrapper
//               final isoTag = Iso15693.from(tag);
//               if (isoTag == null) {
//                 final message = 'Thẻ không phải ISO15693';
//                 print(message);
//                 onError?.call(message);
//                 await NfcManager.instance
//                     .stopSession(errorMessage: 'Thẻ không hợp lệ');
//                 return;
//               }
//               nfcTag = isoTag;
//               identifier = Uint8List.fromList(
//                   List<int>.from(tag.data['iso15693']['identifier']));
//             }
//
//             int capacity = await getCardCapacity(nfcTag);
//             int blockSize = 4;
//             int numberOfBlocks = (capacity / blockSize).ceil();
//
//             Uint8List fixedData = encodeCardData(data, fixedSize: capacity);
//             Uint8List dynamicData = Uint8List(capacity - 60);
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
//               try {
//                 if (Platform.isAndroid) {
//                   // Android: raw transceive
//                   final writeCommand = Uint8List.fromList(
//                       [0x22, 0x21, ...identifier, i, ...blockData]);
//                   final response = await nfcTag.transceive(data: writeCommand);
//                   if (response.isNotEmpty && response[0] == 0x00) {
//                     successfulBlocks++;
//                   }
//                 } else {
//                   // iOS: dùng writeSingleBlock
//                   await nfcTag.writeSingleBlock(
//                     requestFlags: {Iso15693RequestFlag.highDataRate},
//                     blockNumber: i,
//                     dataBlock: blockData,
//                   );
//                   successfulBlocks++;
//                 }
//                 onStatus?.call('Đang ghi khối ${i + 1}/$numberOfBlocks');
//               } catch (e) {
//                 print('Lỗi ghi khối $i: $e');
//               }
//             }
//
//             final message = 'Ghi xong $successfulBlocks/$numberOfBlocks khối';
//             print(message);
//             onStatus?.call(message);
//             NfcManager.instance.stopSession();
//           } catch (e, stackTrace) {
//             final message = 'Lỗi ghi thẻ: $e\n$stackTrace';
//             print(message);
//             onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ');
//             NfcManager.instance.stopSession(errorMessage: 'Lỗi ghi thẻ');
//           }
//         },
//         alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển',
//       );
//     } catch (e, stackTrace) {
//       final message = 'Lỗi khởi động phiên NFC: $e\n$stackTrace';
//       print(message);
//       onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ');
//     }
//   }
// }
//
// class DebugHelper {
//   static void show(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: Duration(seconds: 3)),
//     );
//   }
// }
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class DriverCardData {
  String licenseNumber;
  String driverName;
  String userId;

  DriverCardData({
    this.licenseNumber = '',
    this.driverName = '',
    this.userId = '',
  });
}

typedef OnCardRead = void Function(DriverCardData data);
typedef OnError = void Function(String error);
typedef OnStatus = void Function(String message);

class NfcHelper {
  /// Kiểm tra NFC có khả dụng hay không
  static Future<bool> isNfcAvailable() async {
    bool available = await NfcManager.instance.isAvailable();
    if (Platform.isIOS && available) {
      print('NFC available on iOS');
    }
    return available;
  }

  /// Phân tích dữ liệu từ thẻ
  static DriverCardData parseCardData(BuildContext context, Uint8List rawData) {
    try {
      if (rawData.length < 60) {
        DebugHelper.show(
            context, '❌ Dữ liệu không đủ 60 byte: ${rawData.length}');
        throw Exception('Dữ liệu không đủ 60 byte: ${rawData.length}');
      }

      // --- GPLX ---
      String licenseNumber =
          utf8.decode(rawData.sublist(0, 15), allowMalformed: true).trim();
      int licenseChecksum = calcChecksum(rawData, 0, 14);
      if (licenseChecksum != rawData[15]) {
        DebugHelper.show(context,
            '❌ Checksum GPLX không khớp: tính toán $licenseChecksum, trên thẻ ${rawData[15]}');
        throw Exception('Checksum GPLX không khớp');
      }
      print('Parsed GPLX: $licenseNumber, Checksum: $licenseChecksum');

      // --- Tên ---
      String driverName =
          utf8.decode(rawData.sublist(16, 59), allowMalformed: true).trim();
      int nameChecksum = calcChecksum(rawData, 16, 58);
      if (nameChecksum != rawData[59]) {
        DebugHelper.show(context,
            '❌ Checksum Tên không khớp: tính toán $nameChecksum, trên thẻ ${rawData[59]}');
        throw Exception('Checksum Tên không khớp');
      }
      print('Parsed Name: $driverName, Checksum: $nameChecksum');

      // --- HMV_userId ---
      String userId = "";
      if (rawData.length > 60) {
        userId = utf8.decode(rawData.sublist(60), allowMalformed: true).trim();
        // if (!userId.startsWith('HMV_')) {
        //   DebugHelper.show(context, '❌ HMV_userId không đúng định dạng');
        //   throw Exception('HMV_userId không đúng định dạng');
        // }
        // userId = userId.replaceFirst('HMV_', '');
        print('Parsed HMV_userId: $userId');
      }

      return DriverCardData(
        licenseNumber: licenseNumber,
        driverName: driverName,
        userId: userId,
      );
    } catch (e) {
      DebugHelper.show(context, '❌ Lỗi phân tích dữ liệu: $e');
      throw Exception('Lỗi phân tích dữ liệu: $e');
    }
  }

  /// Mã hóa dữ liệu thành Uint8List để ghi thẻ
  static Uint8List encodeCardData(
    DriverCardData data, {
    required int capacity,
  }) {
    if (capacity < 60) {
      throw Exception('Dung lượng thẻ phải tối thiểu 60 byte');
    }

    Uint8List buffer = Uint8List(capacity);
    buffer.fillRange(0, capacity, 0);

    try {
      // --- GPLX (15 byte + checksum) ---
      List<int> licenseBytes = utf8.encode(data.licenseNumber);
      if (licenseBytes.length > 15) {
        print('Cảnh báo: licenseNumber vượt quá 15 byte');
        licenseBytes = licenseBytes.sublist(0, 15);
      }
      for (int i = 0; i < 15; i++) {
        buffer[i] = i < licenseBytes.length ? licenseBytes[i] : 0x00;
      }
      buffer[15] = calcChecksum(buffer, 0, 14);
      print(
          'Encoded GPLX: ${utf8.decode(buffer.sublist(0, 15), allowMalformed: true)}, Checksum: ${buffer[15]}');

      // --- Họ tên (43 byte + checksum) ---
      List<int> nameBytes = utf8.encode(data.driverName);
      if (nameBytes.length > 43) {
        print('Cảnh báo: driverName vượt quá 43 byte');
        nameBytes = nameBytes.sublist(0, 43);
      }
      for (int i = 0; i < 43; i++) {
        buffer[16 + i] = i < nameBytes.length ? nameBytes[i] : 0x00;
      }
      buffer[59] = calcChecksum(buffer, 16, 58);
      print(
          'Encoded Name: ${utf8.decode(buffer.sublist(16, 59), allowMalformed: true)}, Checksum: ${buffer[59]}');

      // --- HMV_userId ---
      if (data.userId.isNotEmpty) {
        String userIdStr = "HMV_${data.userId}";
        List<int> userIdBytes = utf8.encode(userIdStr);
        if (userIdBytes.length > (capacity - 60)) {
          print(
              'Cảnh báo: HMV_userId vượt quá dung lượng còn lại (${capacity - 60} byte)');
          userIdBytes = userIdBytes.sublist(0, capacity - 60);
        }
        for (int i = 0; i < userIdBytes.length && (60 + i) < capacity; i++) {
          buffer[60 + i] = userIdBytes[i];
        }
        print(
            'Encoded HMV_userId: ${utf8.decode(buffer.sublist(60), allowMalformed: true)}');
      }
    } catch (e) {
      print('Lỗi khi mã hóa dữ liệu thẻ: $e');
      throw Exception('Lỗi mã hóa dữ liệu: $e');
    }

    return buffer;
  }

  /// Tính checksum (tổng modulo 256)
  static int calcChecksum(Uint8List buffer, int start, int end) {
    int sum = 0;
    for (int i = start; i <= end; i++) {
      sum += buffer[i];
    }
    return sum & 0xFF;
  }

  /// Lấy dung lượng thẻ ISO15693
  static Future<int> getCardCapacity(dynamic tag) async {
    try {
      Uint8List identifier;
      if (Platform.isAndroid) {
        final nfcV = tag as NfcV;
        identifier = nfcV.identifier;
      } else {
        identifier = Uint8List.fromList(
            List<int>.from(tag.data['iso15693']['identifier']));
      }
      final command = Uint8List.fromList([0x22, 0x2B, ...identifier]);
      final response = await tag.transceive(data: command);
      if (response.length >= 15) {
        int blockSize = response[12] + 1;
        int numberOfBlocks = response[13] + 1;
        return blockSize * numberOfBlocks;
      }
      return 64; // Giá trị dự phòng
    } catch (e) {
      print('Error getting card capacity: $e');
      return 64;
    }
  }

  /// Đọc dữ liệu từ thẻ NFC
  static Future<void> readCard({
    required BuildContext context,
    required OnCardRead onCardRead,
    OnError? onError,
    OnStatus? onStatus,
  }) async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            dynamic nfcTag;
            Uint8List identifier;

            if (Platform.isAndroid) {
              nfcTag = NfcV.from(tag);
              if (nfcTag == null && tag.data['nfcv'] != null) {
                final nfcvData = tag.data['nfcv'];
                nfcTag = NfcV(
                  tag: tag,
                  identifier: Uint8List.fromList(
                      List<int>.from(nfcvData['identifier'])),
                  dsfId: nfcvData['dsfId'] ?? 0,
                  responseFlags: nfcvData['responseFlags'] ?? 0,
                  maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
                );
              }
              if (nfcTag == null) {
                final message = 'Thẻ không phải ISO15693';
                print(message);
                onError?.call(message);
                await NfcManager.instance
                    .stopSession(errorMessage: 'Thẻ không hợp lệ');
                return;
              }
              identifier = nfcTag.identifier;
            } else {
              nfcTag = Iso15693.from(tag);
              if (nfcTag == null) {
                final message = 'Thẻ không phải ISO15693';
                print(message);
                onError?.call(message);
                await NfcManager.instance
                    .stopSession(errorMessage: 'Thẻ không hợp lệ');
                return;
              }
              identifier = Uint8List.fromList(
                  List<int>.from(tag.data['iso15693']['identifier']));
            }

            int capacity = await getCardCapacity(nfcTag);
            if (capacity < 60) {
              final message =
                  'Dung lượng thẻ ($capacity byte) không đủ (tối thiểu 60 byte)';
              print(message);
              onError?.call(message);
              await NfcManager.instance.stopSession(errorMessage: message);
              return;
            }

            int blockSize = 4;
            int numberOfBlocks = (capacity / blockSize).ceil();
            List<int> allData = [];

            if (Platform.isAndroid) {
              for (int i = 0; i < numberOfBlocks; i++) {
                final command =
                    Uint8List.fromList([0x22, 0x20, ...identifier, i]);
                final blockData = await nfcTag.transceive(data: command);
                if (blockData.length > 1) {
                  allData.addAll(blockData.skip(1));
                }
                onStatus?.call('Đang đọc khối ${i + 1}/$numberOfBlocks');
              }
            } else {
              for (int i = 0; i < numberOfBlocks; i++) {
                final blockData = await nfcTag.readSingleBlock(
                  requestFlags: {Iso15693RequestFlag.highDataRate},
                  blockNumber: i,
                );
                allData.addAll(blockData);
                onStatus?.call('Đang đọc khối ${i + 1}/$numberOfBlocks');
              }
            }

            Uint8List rawData = Uint8List.fromList(allData);
            final cardData = parseCardData(context, rawData);

            onCardRead(cardData);
            await NfcManager.instance.stopSession();
          } catch (e, stackTrace) {
            print('Lỗi đọc thẻ: $e\n$stackTrace');
            onError?.call('Chưa đọc được thẻ, vui lòng thử lại');
            await NfcManager.instance.stopSession(errorMessage: 'Lỗi đọc thẻ');
          }
        },
        alertMessage: 'Đặt thẻ gần thiết bị để đọc',
      );
    } catch (e, stackTrace) {
      print('Lỗi khởi động NFC: $e\n$stackTrace');
      onError?.call('Chưa đọc được thẻ');
    }
  }

  /// Ghi dữ liệu ra thẻ NFC
  static Future<void> writeCard({
    required DriverCardData data,
    OnError? onError,
    OnStatus? onStatus,
  }) async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            print('Tag detected: ${tag.data}');
            dynamic nfcTag;
            Uint8List identifier;

            if (Platform.isAndroid) {
              nfcTag = NfcV.from(tag);
              if (nfcTag == null && tag.data['nfcv'] != null) {
                final nfcvData = tag.data['nfcv'];
                nfcTag = NfcV(
                  tag: tag,
                  identifier: Uint8List.fromList(
                      List<int>.from(nfcvData['identifier'])),
                  dsfId: nfcvData['dsfId'] ?? 0,
                  responseFlags: nfcvData['responseFlags'] ?? 0,
                  maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
                );
              }
              if (nfcTag == null) {
                final message = 'Thẻ không phải ISO15693';
                print(message);
                onError?.call(message);
                await NfcManager.instance
                    .stopSession(errorMessage: 'Thẻ không hợp lệ');
                return;
              }
              identifier = nfcTag.identifier;
            } else {
              nfcTag = Iso15693.from(tag);
              if (nfcTag == null) {
                final message = 'Thẻ không phải ISO15693';
                print(message);
                onError?.call(message);
                await NfcManager.instance
                    .stopSession(errorMessage: 'Thẻ không hợp lệ');
                return;
              }
              identifier = Uint8List.fromList(
                  List<int>.from(tag.data['iso15693']['identifier']));
            }

            int capacity = await getCardCapacity(nfcTag);
            if (capacity < 60) {
              final message =
                  'Dung lượng thẻ ($capacity byte) không đủ (tối thiểu 60 byte)';
              print(message);
              onError?.call(message);
              await NfcManager.instance.stopSession(errorMessage: message);
              return;
            }

            int blockSize = 4;
            int numberOfBlocks = (capacity / blockSize).ceil();

            Uint8List dataToWrite = encodeCardData(data, capacity: capacity);

            int successfulBlocks = 0;
            for (int i = 0; i < numberOfBlocks; i++) {
              int start = i * blockSize;
              int end = (start + blockSize > dataToWrite.length)
                  ? dataToWrite.length
                  : start + blockSize;
              Uint8List blockData = dataToWrite.sublist(start, end);

              try {
                if (Platform.isAndroid) {
                  final writeCommand = Uint8List.fromList(
                      [0x22, 0x21, ...identifier, i, ...blockData]);
                  final response = await nfcTag.transceive(data: writeCommand);
                  if (response.isNotEmpty && response[0] == 0x00) {
                    successfulBlocks++;
                  }
                } else {
                  await nfcTag.writeSingleBlock(
                    requestFlags: {Iso15693RequestFlag.highDataRate},
                    blockNumber: i,
                    dataBlock: blockData,
                  );
                  successfulBlocks++;
                }
                onStatus?.call('Đang ghi khối ${i + 1}/$numberOfBlocks');
              } catch (e) {
                print('Lỗi ghi khối $i: $e');
                continue;
              }
            }

            if (successfulBlocks != numberOfBlocks) {
              final message =
                  'Ghi thất bại: chỉ ghi được $successfulBlocks/$numberOfBlocks khối';
              print(message);
              onError?.call(message);
              await NfcManager.instance.stopSession(errorMessage: message);
              return;
            }

            final message = 'Ghi xong $successfulBlocks/$numberOfBlocks khối';
            print(message);
            onStatus?.call(message);
            await NfcManager.instance.stopSession();
          } catch (e, stackTrace) {
            final message = 'Lỗi ghi thẻ: $e\n$stackTrace';
            print(message);
            onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ');
            await NfcManager.instance.stopSession(errorMessage: 'Lỗi ghi thẻ');
          }
        },
        alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển',
      );
    } catch (e, stackTrace) {
      final message = 'Lỗi khởi động phiên NFC: $e\n$stackTrace';
      print(message);
      onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ');
    }
  }
}

class DebugHelper {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }
}

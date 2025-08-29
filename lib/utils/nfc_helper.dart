import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

class DriverCardData {
  String licenseNumber;
  String driverName;

  DriverCardData({this.licenseNumber = '', this.driverName = ''});
}

typedef OnCardRead = void Function(DriverCardData data);
typedef OnError = void Function(String error);
typedef OnStatus = void Function(String message);

class NfcHelper {
  /// Kiểm tra NFC có khả dụng hay không
  static Future<bool> isNfcAvailable() async {
    bool available = await NfcManager.instance.isAvailable();
    if (Platform.isIOS && available) {
      // Kiểm tra thêm nếu cần (ví dụ: phiên bản iOS)
      print('NFC available on iOS');
    }
    return available;
  }

  /// Parse dữ liệu thẻ thành model
  static DriverCardData parseCardData(Uint8List rawData) {
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
          licenseNumber: licenseNumber, driverName: driverName);
    } catch (e) {
      print('Error parsing card data: $e');
      return DriverCardData(licenseNumber: 'Unknown', driverName: 'Unknown');
    }
  }

  /// Chuyển DriverCardData thành Uint8List để ghi thẻ
  // static Uint8List encodeCardData(DriverCardData data, {int fixedSize = 64}) {
  //   Uint8List buffer = Uint8List(fixedSize);
  //   buffer.fillRange(0, fixedSize, 0);
  //
  //   try {
  //     String license = data.licenseNumber.padRight(15, ' ').substring(0, 15);
  //     List<int> licenseBytes = utf8.encode(license);
  //     for (int i = 0; i < 15; i++) buffer[i] = licenseBytes[i];
  //
  //     int licenseChecksum = 0;
  //     for (int i = 0; i < 15; i++) licenseChecksum ^= buffer[i];
  //     buffer[15] = licenseChecksum;
  //
  //     String name = data.driverName.padRight(43, ' ').substring(0, 43);
  //     List<int> nameBytes = utf8.encode(name);
  //     for (int i = 0; i < 43; i++) buffer[16 + i] = nameBytes[i];
  //
  //     int nameChecksum = 0;
  //     for (int i = 16; i < 59; i++) nameChecksum ^= buffer[i];
  //     buffer[59] = nameChecksum;
  //   } catch (e) {
  //     print('Error encoding card data: $e');
  //   }
  //
  //   return buffer;
  // }
  /// Chuyển DriverCardData thành Uint8List để ghi thẻ
  static Uint8List encodeCardData(DriverCardData data, {int fixedSize = 64}) {
    Uint8List buffer = Uint8List(fixedSize);
    buffer.fillRange(0, fixedSize, 0); // Khởi tạo với các byte rỗng

    try {
      // Mã hóa số giấy phép (tối đa 15 byte)
      List<int> licenseBytes = utf8.encode(data.licenseNumber);
      int licenseLength = licenseBytes.length > 15 ? 15 : licenseBytes.length;
      for (int i = 0; i < licenseLength; i++) {
        buffer[i] = licenseBytes[i];
      }
      // Các byte còn lại đã là số không do khởi tạo buffer

      // Tính mã kiểm tra cho số giấy phép
      int licenseChecksum = 0;
      for (int i = 0; i < 15; i++) {
        licenseChecksum ^= buffer[i];
      }
      buffer[15] = licenseChecksum;

      // Mã hóa họ tên (tối đa 43 byte)
      List<int> nameBytes = utf8.encode(data.driverName);
      int nameLength = nameBytes.length > 43 ? 43 : nameBytes.length;
      for (int i = 0; i < nameLength; i++) {
        buffer[16 + i] = nameBytes[i];
      }
      // Các byte còn lại đã là số không do khởi tạo buffer

      // Tính mã kiểm tra cho họ tên
      int nameChecksum = 0;
      for (int i = 16; i < 59; i++) {
        nameChecksum ^= buffer[i];
      }
      buffer[59] = nameChecksum;
    } catch (e) {
      print('Lỗi khi mã hóa dữ liệu thẻ: $e');
    }

    return buffer;
  }

  /// Lấy dung lượng thẻ ISO15693
  static Future<int> getCardCapacity(NfcV nfcV) async {
    try {
      final command = Uint8List.fromList([0x22, 0x2B, ...nfcV.identifier]);
      final response = await nfcV.transceive(data: command);
      if (response.length >= 15) {
        int blockSize = response[12] + 1;
        int numberOfBlocks = response[13] + 1;
        return blockSize * numberOfBlocks;
      }
      return 64; // fallback
    } catch (e) {
      print('Error getting card capacity: $e');
      return 64;
    }
  }

  /// Quét NFC và đọc dữ liệu thẻ
  // static Future<void> readCard({
  //   required OnCardRead onCardRead,
  //   OnError? onError,
  //   OnStatus? onStatus,
  // }) async {
  //   try {
  //     NfcManager.instance.startSession(
  //       onDiscovered: (NfcTag tag) async {
  //         try {
  //           NfcV? nfcV = NfcV.from(tag);
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
  //             onError?.call('Thẻ không phải ISO15693');
  //             NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
  //             return;
  //           }
  //
  //           int capacity = await getCardCapacity(nfcV);
  //           int blockSize = 4;
  //           int numberOfBlocks = (capacity / blockSize).ceil();
  //
  //           List<int> allData = [];
  //           for (int i = 0; i < numberOfBlocks; i++) {
  //             final command =
  //                 Uint8List.fromList([0x22, 0x20, ...nfcV.identifier, i]);
  //             final blockData = await nfcV.transceive(data: command);
  //             if (blockData.length > 1) allData.addAll(blockData.skip(1));
  //           }
  //
  //           Uint8List fixedData = Uint8List.fromList(allData.take(60).toList());
  //           DriverCardData cardData = parseCardData(fixedData);
  //           print("gplx ${cardData.licenseNumber.length}");
  //           onCardRead(cardData);
  //           NfcManager.instance.stopSession();
  //         } catch (e) {
  //           onError?.call('Chưa đọc được thẻ, vui lòng đặt lại thẻ');
  //           NfcManager.instance.stopSession(errorMessage: 'Lỗi đọc thẻ');
  //         }
  //       },
  //     );
  //   } catch (e) {
  //     onError?.call('Chưa đọc được thẻ, vui lòng đặt lại thẻ');
  //   }
  // }
  static Future<void> readCard({
    required OnCardRead onCardRead,
    OnError? onError,
    OnStatus? onStatus,
  }) async {
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            final message = 'Tag detected: ${tag.data}';
            print(message);

            dynamic nfcV;
            if (Platform.isAndroid) {
              nfcV = NfcV.from(tag);
              if (nfcV == null && tag.data['nfcv'] != null) {
                final nfcvData = tag.data['nfcv'];
                nfcV = NfcV(
                  tag: tag,
                  identifier: Uint8List.fromList(
                      List<int>.from(nfcvData['identifier'])),
                  dsfId: nfcvData['dsfId'] ?? 0,
                  responseFlags: nfcvData['responseFlags'] ?? 0,
                  maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
                );
              }
            } else if (Platform.isIOS) {
              // iOS: Use tag.data for ISO15693, as nfc_manager abstracts Core NFC
              if (!tag.data.containsKey('iso15693')) {
                final message = 'Thẻ không phải ISO15693';
                print(message);

                onError?.call(message);
                NfcManager.instance
                    .stopSession(errorMessage: 'Thẻ không hợp lệ');
                return;
              }
              nfcV = tag;
            }

            if (nfcV == null) {
              final message = 'Thẻ không phải ISO15693';
              print(message);

              onError?.call(message);
              NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
              return;
            }

            int capacity = await getCardCapacity(nfcV);
            int blockSize = 4;
            int numberOfBlocks = (capacity / blockSize).ceil();

            List<int> allData = [];
            for (int i = 0; i < numberOfBlocks; i++) {
              final command =
                  Uint8List.fromList([0x22, 0x20, ...nfcV.identifier, i]);
              late Uint8List blockData;
              if (Platform.isIOS) {
                // iOS: Custom command not supported, fallback to transceive or platform channel
                final message =
                    'iOS: Custom read command not supported. Using default transceive.';
                print(message);

                blockData = await nfcV.transceive(data: command);
              } else {
                blockData = await nfcV.transceive(data: command);
              }
              if (blockData.length > 1) allData.addAll(blockData.skip(1));
            }

            Uint8List fixedData = Uint8List.fromList(allData.take(60).toList());
            DriverCardData cardData = parseCardData(fixedData);
            final successMessage =
                'Đọc thành công: GPLX ${cardData.licenseNumber}, Tên ${cardData.driverName}';
            print(successMessage);

            onCardRead(cardData);
            NfcManager.instance.stopSession();
          } catch (e, stackTrace) {
            final message = 'Lỗi đọc thẻ: $e\n$stackTrace';
            print(message);

            onError?.call('Chưa đọc được thẻ, vui lòng đặt lại thẻ: $e');
            NfcManager.instance.stopSession(errorMessage: 'Lỗi đọc thẻ: $e');
          }
        },
        alertMessage: 'Đặt thẻ gần thiết bị để đọc',
      );
    } catch (e, stackTrace) {
      final message = 'Lỗi khởi động phiên NFC: $e\n$stackTrace';
      print(message);

      onError?.call('Chưa đọc được thẻ, vui lòng đặt lại thẻ: $e');
    }
  }

  /// Ghi dữ liệu ra thẻ NFC
  // static Future<void> writeCard({
  //   required DriverCardData data,
  //   OnError? onError,
  //   OnStatus? onStatus,
  // }) async {
  //   try {
  //     NfcManager.instance.startSession(
  //       onDiscovered: (NfcTag tag) async {
  //         try {
  //           NfcV? nfcV = NfcV.from(tag);
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
  //             onError?.call('Thẻ không phải ISO15693');
  //             NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
  //             return;
  //           }
  //
  //           int capacity = await getCardCapacity(nfcV);
  //           int blockSize = 4;
  //           int numberOfBlocks = (capacity / blockSize).ceil();
  //
  //           Uint8List fixedData = encodeCardData(data);
  //           Uint8List dynamicData = Uint8List(capacity - 60);
  //           Uint8List dataToWrite =
  //               Uint8List.fromList([...fixedData, ...dynamicData]);
  //
  //           int successfulBlocks = 0;
  //           for (int i = 0; i < numberOfBlocks; i++) {
  //             int start = i * blockSize;
  //             int end = (start + blockSize > dataToWrite.length)
  //                 ? dataToWrite.length
  //                 : start + blockSize;
  //             Uint8List blockData = dataToWrite.sublist(start, end);
  //
  //             final writeCommand = Uint8List.fromList(
  //                 [0x22, 0x21, ...nfcV.identifier, i, ...blockData]);
  //             final response = await nfcV.transceive(data: writeCommand);
  //             if (response.isNotEmpty && response[0] == 0x00)
  //               successfulBlocks++;
  //             //onStatus?.call('Đang ghi block ${i + 1}/$numberOfBlocks');
  //           }
  //
  //           onStatus?.call('Ghi xong $successfulBlocks/$numberOfBlocks blocks');
  //           NfcManager.instance.stopSession();
  //         } catch (e) {
  //           onError?.call('Chưa đọc được thẻ, vui lòng đặt lại thẻ');
  //           NfcManager.instance.stopSession(errorMessage: 'Lỗi ghi thẻ');
  //         }
  //       },
  //       alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển',
  //     );
  //   } catch (e) {
  //     onError?.call('Chưa đọc được thẻ, vui lòng đặt lại thẻ');
  //   }
  // }
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
            final message = 'Tag detected: ${tag.data}';
            print(message);

            dynamic nfcV;
            if (Platform.isAndroid) {
              nfcV = NfcV.from(tag);
              if (nfcV == null && tag.data['nfcv'] != null) {
                final nfcvData = tag.data['nfcv'];
                nfcV = NfcV(
                  tag: tag,
                  identifier: Uint8List.fromList(
                      List<int>.from(nfcvData['identifier'])),
                  dsfId: nfcvData['dsfId'] ?? 0,
                  responseFlags: nfcvData['responseFlags'] ?? 0,
                  maxTransceiveLength: nfcvData['maxTransceiveLength'] ?? 0,
                );
              }
            } else if (Platform.isIOS) {
              if (!tag.data.containsKey('iso15693')) {
                final message = 'Thẻ không phải ISO15693';
                print(message);

                onError?.call(message);
                NfcManager.instance
                    .stopSession(errorMessage: 'Thẻ không hợp lệ');
                return;
              }
              nfcV = tag;
            }

            if (nfcV == null) {
              final message = 'Thẻ không phải ISO15693';
              print(message);

              onError?.call(message);
              NfcManager.instance.stopSession(errorMessage: 'Thẻ không hợp lệ');
              return;
            }

            int capacity = await getCardCapacity(nfcV);
            int blockSize = 4;
            int numberOfBlocks = (capacity / blockSize).ceil();

            Uint8List fixedData = encodeCardData(data);
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

              late Uint8List response;
              if (Platform.isIOS) {
                // iOS: Custom write command not supported, fallback to transceive
                final message =
                    'iOS: Custom write command not supported. Using default transceive.';
                print(message);

                response = await nfcV.transceive(
                    data: Uint8List.fromList(
                        [0x22, 0x21, ...nfcV.identifier, i, ...blockData]));
              } else {
                response = await nfcV.transceive(
                    data: Uint8List.fromList(
                        [0x22, 0x21, ...nfcV.identifier, i, ...blockData]));
              }
              if (response.isNotEmpty && response[0] == 0x00)
                successfulBlocks++;
            }

            final messages =
                'Ghi xong $successfulBlocks/$numberOfBlocks blocks';
            print(messages);

            onStatus?.call(messages);
            NfcManager.instance.stopSession();
          } catch (e, stackTrace) {
            final message = 'Lỗi ghi thẻ: $e\n$stackTrace';
            print(message);

            onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ: $e');
            NfcManager.instance.stopSession(errorMessage: 'Lỗi ghi thẻ: $e');
          }
        },
        alertMessage: 'Đặt thẻ gần thiết bị và KHÔNG di chuyển',
      );
    } catch (e, stackTrace) {
      final message = 'Lỗi khởi động phiên NFC: $e\n$stackTrace';
      print(message);

      onError?.call('Chưa ghi được thẻ, vui lòng đặt lại thẻ: $e');
    }
  }
}

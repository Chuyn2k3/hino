// import Foundation
// import CoreNFC
// import Flutter

// public class Iso15693Plugin: NSObject, FlutterPlugin, NFCTagReaderSessionDelegate {
//     private var channel: FlutterMethodChannel
//     private var session: NFCTagReaderSession?
//     private var isoTag: NFCISO15693Tag?
//     private var flutterResult: FlutterResult?

//     private var startBlock: Int = 0
//     private var blockCount: Int = 15   // mặc định đọc 15 block = 60 byte

//     init(channel: FlutterMethodChannel) {
//         self.channel = channel
//     }

//     // MARK: - FlutterPlugin
//     public static func register(with registrar: FlutterPluginRegistrar) {
//         let channel = FlutterMethodChannel(
//             name: "iso15693_channel",
//             binaryMessenger: registrar.messenger()
//         )
//         let instance = Iso15693Plugin(channel: channel)
//         registrar.addMethodCallDelegate(instance, channel: channel)
//     }

//     public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//         switch call.method {
//         case "readBlocks":
//             // đọc nhiều block cùng lúc
//             let args = call.arguments as? [String: Any]
//             self.startBlock = args?["startBlock"] as? Int ?? 0
//             self.blockCount = args?["count"] as? Int ?? 15
//             self.flutterResult = result
//             self.startSession()

//         default:
//             result(FlutterMethodNotImplemented)
//         }
//     }

//     private func startSession() {
//         session = NFCTagReaderSession(
//             pollingOption: .iso15693,
//             delegate: self,
//             queue: nil
//         )
//         session?.alertMessage = "Đặt thẻ ISO15693 gần thiết bị"
//         session?.begin()
//     }

//     // MARK: - NFCTagReaderSessionDelegate
//     public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
//         print("NFC session started")
//     }

//     public func tagReaderSession(_ session: NFCTagReaderSession,
//                                  didInvalidateWithError error: Error) {
//         print("Session invalidated: \(error)")
//         if let result = flutterResult {
//             result(FlutterError(code: "SESSION_ERROR",
//                                 message: error.localizedDescription,
//                                 details: nil))
//             flutterResult = nil
//         }
//     }

//     public func tagReaderSession(_ session: NFCTagReaderSession,
//                                  didDetect tags: [NFCTag]) {
//         guard let firstTag = tags.first else { return }

//         if case let .iso15693(tag) = firstTag {
//             self.isoTag = tag
//             session.connect(to: firstTag) { error in
//                 if let error = error {
//                     self.flutterResult?(FlutterError(code: "CONNECT_ERROR",
//                                                      message: error.localizedDescription,
//                                                      details: nil))
//                     session.invalidate()
//                     return
//                 }

//                 self.readMultipleBlocks(tag: tag, session: session)
//             }
//         } else {
//             session.invalidate(errorMessage: "Không phải thẻ ISO15693")
//             flutterResult?(FlutterError(code: "INVALID_TAG",
//                                         message: "Tag không phải ISO15693",
//                                         details: nil))
//         }
//     }

//     private func readMultipleBlocks(tag: NFCISO15693Tag, session: NFCTagReaderSession) {
//     var allBytes: [Int] = []
//     let group = DispatchGroup()

//     for i in 0..<blockCount {
//         group.enter()
//         tag.readSingleBlock(
//             requestFlags: [.highDataRate, .address],
//             blockNumber: UInt8(startBlock + i)
//         ) { data, error in
//             if let error = error {
//                 print("⚠️ Read block \(i) failed: \(error.localizedDescription)")
//                 // fill 4 bytes 0x00 nếu block đọc lỗi
//                 allBytes.append(contentsOf: [0, 0, 0, 0])
//             } else {
//                 allBytes.append(contentsOf: data.map { Int($0) })
//             }
//             group.leave()
//         }
//     }

//     group.notify(queue: .main) {
//         print("✅ Finished reading \(self.blockCount) blocks, got \(allBytes.count) bytes")

//         if let result = self.flutterResult {
//             if allBytes.count < self.blockCount * 4 {
//                 result(FlutterError(code: "PARTIAL_DATA",
//                                     message: "Chỉ đọc được \(allBytes.count) byte",
//                                     details: nil))
//             } else {
//                 result(allBytes)
//             }
//             self.flutterResult = nil
//         }
//         session.invalidate()
//     }
// }

// }
import Foundation
import CoreNFC
import Flutter

public class Iso15693Plugin: NSObject, FlutterPlugin, NFCTagReaderSessionDelegate {
    private var channel: FlutterMethodChannel
    private var session: NFCTagReaderSession?
    private var isoTag: NFCISO15693Tag?
    private var flutterResult: FlutterResult?

    private var startBlock: Int = 0
    private var blockCount: Int = 15   // mặc định đọc 15 block = 60 byte

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    // MARK: - FlutterPlugin
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "iso15693_channel",
            binaryMessenger: registrar.messenger()
        )
        let instance = Iso15693Plugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "readBlocks":
            let args = call.arguments as? [String: Any]
            self.startBlock = args?["startBlock"] as? Int ?? 0
            self.blockCount = args?["count"] as? Int ?? 15
            self.flutterResult = result
            self.startSession()
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func startSession() {
        session = NFCTagReaderSession(
            pollingOption: .iso15693,
            delegate: self,
            queue: nil
        )
        session?.alertMessage = "Đặt thẻ ISO15693 gần thiết bị"
        session?.begin()
    }

    // MARK: - NFCTagReaderSessionDelegate
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        self.logToFlutter("📡 NFC session started")
    }

    public func tagReaderSession(_ session: NFCTagReaderSession,
                                 didInvalidateWithError error: Error) {
        self.logToFlutter("❌ Session invalidated: \(error.localizedDescription)")
        if let result = flutterResult {
            result(FlutterError(code: "SESSION_ERROR",
                                message: error.localizedDescription,
                                details: nil))
            flutterResult = nil
        }
    }

    public func tagReaderSession(_ session: NFCTagReaderSession,
                                 didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else { return }

        if case let .iso15693(tag) = firstTag {
            self.isoTag = tag
            session.connect(to: firstTag) { error in
                if let error = error {
                    self.flutterResult?(FlutterError(code: "CONNECT_ERROR",
                                                     message: error.localizedDescription,
                                                     details: nil))
                    session.invalidate()
                    return
                }
                self.tryReadMultipleBlocks(tag: tag, session: session)
            }
        } else {
            session.invalidate(errorMessage: "Không phải thẻ ISO15693")
            flutterResult?(FlutterError(code: "INVALID_TAG",
                                        message: "Tag không phải ISO15693",
                                        details: nil))
        }
    }

    // MARK: - Ưu tiên dùng readMultipleBlocks
    private func tryReadMultipleBlocks(tag: NFCISO15693Tag, session: NFCTagReaderSession) {
        let blockRange = NSRange(location: startBlock, length: blockCount)
        tag.readMultipleBlocks(requestFlags: [.highDataRate], blockRange: blockRange) { datas, error in
            if let error = error {
                self.logToFlutter("⚠️ readMultipleBlocks failed: \(error.localizedDescription)")
                self.readBlocksOneByOne(tag: tag, session: session)
            } else {
                var allBytes: [Int] = []
                for (i, data) in datas.enumerated() {
                    let bytes = [UInt8](data)
                    self.logToFlutter("🔹 Block \(i) = \(bytes.map { String(format: "%02X", $0) }.joined(separator: " "))")
                    allBytes.append(contentsOf: bytes.map { Int($0) })
                }
                self.logToFlutter("✅ Got \(allBytes.count) bytes via readMultipleBlocks")
                self.flutterResult?(allBytes)
                self.flutterResult = nil
                session.invalidate()
            }
        }
    }

    // MARK: - fallback: đọc từng block
    private func readBlocksOneByOne(tag: NFCISO15693Tag, session: NFCTagReaderSession) {
        var allBytes: [Int] = []
        let group = DispatchGroup()

        for i in 0..<blockCount {
            group.enter()
            let blockNumber = UInt8(startBlock + i)
            tag.readSingleBlock(requestFlags: [.highDataRate], blockNumber: blockNumber) { data, error in
                if let error = error {
                    self.logToFlutter("⚠️ Read block \(i) failed: \(error.localizedDescription)")
                    allBytes.append(contentsOf: [0, 0, 0, 0])
                } else {
                    // `data` có thể là Data hoặc Data?
                    let bytes = [UInt8](data ?? Data([0, 0, 0, 0]))
                    self.logToFlutter("🔹 Block \(i) = \(bytes.map { String(format: "%02X", $0) }.joined(separator: " "))")
                    allBytes.append(contentsOf: bytes.map { Int($0) })
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.logToFlutter("✅ Finished reading \(allBytes.count) bytes via singleBlock")
            self.flutterResult?(allBytes)
            self.flutterResult = nil
            session.invalidate()
        }
    }

    private func logToFlutter(_ message: String) {
        DispatchQueue.main.async {
            self.channel.invokeMethod("debugLog", arguments: message)
        }
    }
}

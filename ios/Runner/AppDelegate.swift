import UIKit
import Flutter
import GoogleMaps
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Google Maps API
        GMSServices.provideAPIKey("AIzaSyClbDwx0hXz073dTUPe89TP7MAdfFIaIfQ")

        // Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        // Notifications
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        // Register generated plugins
        GeneratedPluginRegistrant.register(with: self)
        
        Iso15693Plugin.register(with: self.registrar(forPlugin: "iso15693_channel")!)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Firebase Messaging delegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "")")
    }
}

// import UIKit
// import Flutter
// import GoogleMaps
// import Firebase
// import FirebaseMessaging
// import UserNotifications
// import CoreNFC
// import Foundation // Thêm import này

// struct NFCRequest {
//     let method: String
//     let identifier: Data?
//     let blockNumber: Int?
//     let result: FlutterResult
// }

// @main
// @objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
//     var session: NFCISO15693ReaderSession?
//     var currentRequest: NFCRequest?

//     override func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
//         // Google Maps API
//         GMSServices.provideAPIKey("AIzaSyClbDwx0hXz073dTUPe89TP7MAdfFIaIfQ")

//         // Firebase
//         FirebaseApp.configure()
//         Messaging.messaging().delegate = self

//         // Notifications
//         if #available(iOS 10.0, *) {
//             UNUserNotificationCenter.current().delegate = self
//             let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//             UNUserNotificationCenter.current().requestAuthorization(
//                 options: authOptions,
//                 completionHandler: { _, _ in }
//             )
//         } else {
//             let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//             application.registerUserNotificationSettings(settings)
//         }
//         application.registerForRemoteNotifications()

//         // Register generated plugins
//         GeneratedPluginRegistrant.register(with: self)

//         // NFC Platform Channel
//         let controller = window?.rootViewController as! FlutterViewController
//         let nfcChannel = FlutterMethodChannel(
//             name: "com.example.nfc/iso15693",
//             binaryMessenger: controller.binaryMessenger
//         )

//         nfcChannel.setMethodCallHandler { (call, result) in
//             if call.method == "readSingleBlock" {
//                 guard let args = call.arguments as? [String: Any],
//                       let identifier = args["identifier"] as? FlutterStandardTypedData,
//                       let blockNumber = args["blockNumber"] as? Int else {
//                     result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
//                     return
//                 }
//                 self.currentRequest = NFCRequest(
//                     method: "readSingleBlock",
//                     identifier: identifier.data,
//                     blockNumber: blockNumber,
//                     result: result
//                 )
//                 self.startNFCSession()
//             } else if call.method == "getSystemInfo" {
//                 guard let args = call.arguments as? [String: Any],
//                       let identifier = args["identifier"] as? FlutterStandardTypedData else {
//                     result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
//                     return
//                 }
//                 self.currentRequest = NFCRequest(
//                     method: "getSystemInfo",
//                     identifier: identifier.data,
//                     blockNumber: nil,
//                     result: result
//                 )
//                 self.startNFCSession()
//             } else {
//                 result(FlutterMethodNotImplemented)
//             }
//         }

//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }

//     // Firebase Messaging delegate
//     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//         print("FCM Token: \(fcmToken ?? "")")
//     }

//     // NFC Session Handling
//     func startNFCSession() {
//         if #available(iOS 13.0, *) {
//             session = NFCISO15693ReaderSession(delegate: self, queue: DispatchQueue.main) // Sửa .main thành DispatchQueue.main
//             session?.alertMessage = currentRequest?.method == "readSingleBlock"
//                 ? "Đặt thẻ gần thiết bị để đọc"
//                 : "Đặt thẻ gần thiết bị để lấy thông tin"
//             session?.begin()
//         } else {
//             currentRequest?.result(FlutterError(code: "UNSUPPORTED", message: "NFC requires iOS 13+", details: nil))
//         }
//     }
// }

// @available(iOS 13.0, *)
// extension AppDelegate: NFCISO15693ReaderSessionDelegate {
//     func readerSession(_ session: NFCISO15693ReaderSession, didInvalidateWithError error: Error) {
//         if let nfcError = error as? NFCReaderError,
//            nfcError.code != .readerSessionInvalidationErrorUserCanceled {
//             currentRequest?.result(FlutterError(code: "SESSION_ERROR", message: error.localizedDescription, details: nil))
//         }
//     }

//     func readerSession(_ session: NFCISO15693ReaderSession, didDetect tags: [NFCISO15693Tag]) {
//         guard let tag = tags.first, let request = currentRequest else {
//             currentRequest?.result(FlutterError(code: "NO_TAG", message: "No tag detected", details: nil))
//             session.invalidate()
//             return
//         }

//         session.connect(to: tag) { error in
//             if let error = error {
//                 request.result(FlutterError(code: "CONNECT_ERROR", message: error.localizedDescription, details: nil))
//                 session.invalidate()
//                 return
//             }

//             if let expectedId = request.identifier, tag.identifier != expectedId {
//                 request.result(FlutterError(code: "INVALID_TAG", message: "Tag identifier mismatch", details: nil))
//                 session.invalidate()
//                 return
//             }

//             if request.method == "readSingleBlock", let blockNumber = request.blockNumber {
//                 tag.readSingleBlock(requestFlags: [.highDataRate], blockNumber: UInt8(blockNumber)) { (data, error) in
//                     if let error = error {
//                         request.result(FlutterError(code: "READ_ERROR", message: error.localizedDescription, details: nil))
//                     } else {
//                         request.result(Array(data))
//                     }
//                     session.invalidate()
//                 }
//             } else if request.method == "getSystemInfo" {
//                 tag.getSystemInfo(requestFlags: [.highDataRate]) { (dsfid, afi, blockSize, blockCount, icReference, error) in
//                     if let error = error {
//                         request.result(FlutterError(code: "SYSTEM_INFO_ERROR", message: error.localizedDescription, details: nil))
//                     } else {
//                         let response = [0x00, dsfid, afi, 0, 0, 0, 0, 0, 0, 0, 0, 0, blockSize - 1, blockCount - 1, icReference]
//                         request.result(response)
//                     }
//                     session.invalidate()
//                 }
//             }
//         }
//     }
// }


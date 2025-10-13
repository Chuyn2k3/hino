// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hino/feature/home/home.dart';
// import 'package:hino/model/profile.dart';
// import 'package:hino/model/upload.dart';
// import 'package:http/http.dart' as http;
//
// class Api {
//   static String BaseUrlBuilding =
//       "https://apihinov1.hino-connect.vn/prod/";
//       //"http://42.96.40.69:9082/prod/";
//   static String BaseUrlBuildingSwagger = "http://42.96.42.254:4004/prod/";
//   static String firebase_key =
//       "AAAAwmmo4S8:APA91bFrpiUhVSV5orW6qBnwzUa2376P3t7pTvkY-cPjTn2U_a93n3hj03CgaJNNjqTFZcA_KqcWggwbPZoyvzGXglFj5SEZDBVIQ985JW896aOXybIN2N_nSnxJY9BxBqNakXImCJYt";
//
//   static String login = "${BaseUrlBuilding}fleet/mobile/auth/login";
//   static String forgot_password =
//       "https://apihinov1.hino-connect.vn/prod/fleet/users/forgot-password";
//   //BaseUrlBuilding + "users/auth/forgot-password";
//   static String forgot_password_confirm =
//       "https://apihinov1.hino-connect.vn/prod/fleet/users/confirm-forgot-password";
//   //BaseUrlBuilding + "users/auth/confirm-forgot-password";
//
//   // static String realtime = BaseUrlBuilding + "fleet/mobile/realtime";
//   static String realtime = "${BaseUrlBuilding}fleet/mobile/V2/realtime";
//   static String vid_detail = "${BaseUrlBuilding}fleet/mobile/information?vid=";
//   static String factory = "${BaseUrlBuilding}fleet/mobile/V2/listgeofence";
//
//   // static String factory = BaseUrlBuilding + "fleet/mobile/listgeofence";
//   static String listmember = "${BaseUrlBuilding}fleet/mobile/listmember";
//   static String listdriver = "${BaseUrlBuilding}fleet/mobile/V2/listdriver";
//   static String driver_detail =
//       "${BaseUrlBuilding}fleet/mobile/driverdetails?driver_id=";
//   static String notify = "${BaseUrlBuilding}fleet/mobile/history/notify";
//   static String history = "${BaseUrlBuilding}fleet/mobile/history";
//   static String dashboard_summary =
//       "${BaseUrlBuilding}fleet/mobile/V2/dashboard/summary";
//   static String dashboard_realtime =
//       "${BaseUrlBuilding}fleet/mobile/dashboard/realtime";
//   static String dashboard_driver =
//       "${BaseUrlBuilding}fleet/mobile/dashboard/driver";
//   static String trip = "${BaseUrlBuilding}fleet/mobile/V2/trips";
//   static String trip_detail = "${BaseUrlBuilding}fleet/mobile/V2/trips/detail";
//   static String logout = "${BaseUrlBuilding}fleet/mobile/auth/logout";
//   static String token = "${BaseUrlBuilding}fleet/mobile/token";
//   //static String cctv_vehicle = BaseUrlBuilding + "fleet/mdvr/device?user_id=";
//   //static String cctv_vehicle = "https://iov-apidm.veconnect.vn/prod/fleet/picture?";
//   static String cctv_vehicle = "${BaseUrlBuilding}fleet/picture?";
//   static String cctv_date =
//       "${BaseUrlBuilding}fleet/mdvr/playback/calendar/info?user_id=";
//   static String cctv_live = "${BaseUrlBuilding}fleet/mdvr/playback?user_id=";
//   static String cctv_live_channel =
//       "${BaseUrlBuilding}fleet/mdvr/playback/info?user_id=";
//   static String snapshot =
//       "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/mdvr/playback/images?";
//   static String banner = "https://3tirkucu7j.execute-api.ap-southeast-1"
//       ".amazonaws"
//       ".com/prod/prod/fleet/banner/display";
//   static String news =
//       "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/news/management/display";
//
//   // fleet/mdvr/playback?user_id=11378&vehicle_id=33508&channel=1&start=2022-06-01%2018:48:24&end=2022-06-01%2018:49:03
//   // fleet/mdvr/playback/calendar/info?user_id=6120&vehicle_id=31503&start=2022-11-01&st=1
//   static String postFileUrl =
//       "https://ru.71dev.com/etest-enrollment/api/upload/upload";
//
//   static String version =
//       "https://apihinov1.hino-connect.vn/prod/fleet/mobile/getLastestVersion";
//   static String changePassword = "fleet/users/change-password";
//   static String createDriver = "fleet/mobile/create_driver";
//   static String createDriverUser = "fleet/mobile/create_driver_user";
//   static String updateDriver = "fleet/mobile/update_driver";
//   static String deleteDriver = "fleet/mobile/delete_driver";
//   static String importDriver = "fleet/driver_changes/import";
//   static String updateVehicleAssignment = "fleet/mobile/driver_manage_vehicle";
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//   static Profile? profile;
//
//   static String language = "vi";
//
//   static setProfile(Profile p) {
//     profile = p;
//   }
//
//   static Future<dynamic> get(BuildContext context, String url) async {
//     try {
//       http.Response response;
//       if (profile != null) {
//         // print("userID = " + profile!.userId.toString());
//         Map<String, String> requestHeaders = {
//           'Accept-Language': language == "vi" || language == "en" ? "en" : "vi",
//           'Accept': 'application/json',
//           'userId': profile!.userId.toString(),
//           "applicationId": "2",
//           "app_id": platform,
//           "uuid": uuid,
//           "token_id": token,
//           "os": os,
//           // 'user_id': "38"
//         };
//         print(requestHeaders);
//         print(url);
//         response = await http.get(Uri.parse(url), headers: requestHeaders);
//         print(response.body);
//       } else {
//         response = await http.get(Uri.parse(url));
//       }
//       // final jsonResponse = json.decode(response.body);
//
//       // print( 'Accept-Language   '+ language);
//       // print('Accept-Language   ' + url + "////" + response.statusCode.toString());
//       // print(response.body + "////" + url + "////" + response.statusCode.toString());
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final jsonResponse = json.decode(response.body);
//         //print(jsonResponse);
//         return jsonResponse;
//       } else if (response.statusCode == 404) {
//         // showAlertDialog(context, "Not found");
//       } else {
//         // showAlertDialog(context, response.body);
//         try {
//           final jsonResponse = json.decode(response.body);
//           // print(response.body);
//           return jsonResponse;
//         } catch (a) {
//           print(a);
//         }
//       }
//     } catch (e) {
//       print(e);
//       // showAlertDialog(context, e.toString());
//     }
//   }
//
//   static Future<dynamic> post(
//       BuildContext context, String url, String jsonParam,
//       {String? accessToken = ""}) async {
//     print(url);
//     try {
//       print(jsonParam);
//
//       // http.Response response = await http.post(
//       //   Uri.parse(url),
//       //   body: jsonParam,
//       //   headers: <String, String>{
//       //     HttpHeaders.contentTypeHeader: "application/json"
//       //   },
//       // );
//
//       var response;
//       if (profile != null) {
//         print("userID = ${profile!.userId}");
//         Map<String, String> requestHeaders = {
//           'Accept-Language': language == "vi" ? "en" : "en",
//           'Accept': 'application/json',
//           'user_id': profile!.userId.toString(),
//           "applicationId": "2",
//           "app_id": platform,
//           "uuid": uuid,
//           "token_id": token,
//           "os": os,
//           "Authorization": accessToken ?? "",
//           HttpHeaders.contentTypeHeader: "application/json"
//           // 'user_id': "38"
//         };
//         response = await http.post(Uri.parse(url),
//             body: jsonParam, headers: requestHeaders);
//         print(requestHeaders);
//       } else {
//         Map<String, String> requestHeaders = {
//           HttpHeaders.contentTypeHeader: "application/json"
//           // 'user_id': "38"
//         };
//         response = await http.post(Uri.parse(url),
//             body: jsonParam, headers: requestHeaders);
//       }
//
//       print('Accept-Language   ' +
//           language +
//           url +
//           "////" +
//           response.statusCode.toString());
//       // print('print respon status code = ' + response.statusCode.toString());
//       // print(response.body);
//       printApiStatus(response);
//
//       if (response.statusCode == 200 ||
//           response.statusCode == 201 ||
//           response.statusCode == 204) {
//         final jsonResponse = json.decode(response.body);
//         return jsonResponse;
//       } else if (response.statusCode == 404) {
//         // showAlertDialog(context, "Not found");
//       } else {
//         final jsonResponse = json.decode(response.body);
//         var code = jsonResponse["Error"]["Code"];
//         if (code == 112) {
//           showAlertDialog(context, jsonResponse["Error"]["Message"]);
//         } else if (code == 111) {
//           showAlertDialog(context, jsonResponse["Error"]["Message"]);
//         } else if (code == 113) {
//           showAlertDialog(context, jsonResponse["Error"]["Message"]);
//         }
//       }
//     } catch (e) {
//       print(e);
//       // showAlertDialog(context, e.toString());
//     }
//   }
//
//   static Future<dynamic> put(
//       BuildContext context, String url, String jsonParam) async {
//     print(url);
//     try {
//       print(jsonParam);
//
//       // http.Response response = await http.post(
//       //   Uri.parse(url),
//       //   body: jsonParam,
//       //   headers: <String, String>{
//       //     HttpHeaders.contentTypeHeader: "application/json"
//       //   },
//       // );
//
//       var response;
//       if (profile != null) {
//         print("userID = ${profile!.userId}");
//         Map<String, String> requestHeaders = {
//           'Accept-Language': language,
//           'Accept': 'application/json',
//           'user_id': profile!.userId.toString(),
//           "applicationId": "2",
//           "app_id": platform,
//           "uuid": uuid,
//           "token_id": token,
//           "os": os,
//           HttpHeaders.contentTypeHeader: "application/json"
//           // 'user_id': "38"
//         };
//         response = await http.put(Uri.parse(url),
//             body: jsonParam, headers: requestHeaders);
//       } else {
//         Map<String, String> requestHeaders = {
//           HttpHeaders.contentTypeHeader: "application/json"
//           // 'user_id': "38"
//         };
//         response = await http.post(Uri.parse(url),
//             body: jsonParam, headers: requestHeaders);
//       }
//
//       print('print respon status code = ${response.statusCode}');
//
//       if (response.statusCode == 200 ||
//           response.statusCode == 201 ||
//           response.statusCode == 204) {
//         if (response.body != null) {
//           print(response.body);
//           final jsonResponse = json.decode(response.body);
//           return jsonResponse;
//         } else {}
//       } else if (response.statusCode == 404) {
//         // showAlertDialog(context, "Not found");
//       } else {
//         final jsonResponse = json.decode(response.body);
//         var code = jsonResponse["Error"]["Code"];
//         if (code == 112) {
//           showAlertDialog(context, jsonResponse["Error"]["Message"]);
//         } else if (code == 111) {
//           showAlertDialog(context, jsonResponse["Error"]["Message"]);
//         } else if (code == 113) {
//           showAlertDialog(context, jsonResponse["Error"]["Message"]);
//         }
//       }
//     } catch (e) {
//       print(e);
//       // showAlertDialog(context, e.toString());
//     }
//   }
//
//   static Future<List<Upload>?> postFile(
//       BuildContext context, String path) async {
//     try {
//       print(path);
//
//       var request = http.MultipartRequest("POST", Uri.parse(postFileUrl));
//       //add text fields
//       // request.fields["text_field"] = text;
//       //create multipart using filepath, string or bytes
//
//       var pic = await http.MultipartFile.fromPath("path", path);
//       //add multipart to request
//       request.files.add(pic);
//
//       var res = await request.send();
//       final response = await http.Response.fromStream(res);
//
//       print('print respon status code = ${response.statusCode}');
//       print(response.body);
//
//       final List<dynamic> responseData1 = json.decode(response.body);
//       if (response.statusCode == 200) {
//         List<Upload> upload =
//             List.from(responseData1).map((a) => Upload.fromJson(a)).toList();
//         return upload;
//         // for (int i = 0; i < upload.length; i++) {
//         //   _img.add(Img(upload[i].fileName));
//         // }
//         // print(_img.toList());
//       } else if (response.statusCode == 404) {
//         showAlertDialog(context, "Not found");
//       } else {
//         showAlertDialog(context, response.body);
//       }
//     } catch (e) {
//       print(e);
//       showAlertDialog(context, e.toString());
//     }
//   }
//
//   static showAlertDialog(BuildContext context, String message) {
//     // set up the button
//     Widget okButton = ElevatedButton(
//       child: const Text("OK"),
//       onPressed: () {
//         Navigator.pop(context);
//       },
//     );
//
//     // set up the AlertDialog
//     AlertDialog alert = AlertDialog(
//       content: Text(message),
//       actions: [
//         okButton,
//       ],
//     );
//
//     // show the dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   static showLoaderDialog(BuildContext context) {
//     AlertDialog alert = AlertDialog(
//       content: new Row(
//         children: [
//           const CircularProgressIndicator(),
//           Container(
//               margin: const EdgeInsets.only(left: 7),
//               child: const Text("Loading...")),
//         ],
//       ),
//     );
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }
// Refactor of your Api class to use Dio with an interceptor that
// automatically refreshes the access token and replays the original request.
// All APIs (except login) will send the access token on every call via
// headers: `token_id` and `Authorization: Bearer <token>`.

// import 'dart:async';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:hino/feature/home/home.dart';
// import 'package:hino/model/profile.dart';
// import 'package:hino/model/upload.dart';
//
// class Api {
//   // ===== Endpoints (kept from your file) =====
//   static String BaseUrlBuilding =
//       //"https://apihinov1.hino-connect.vn/prod/";
//       "http://42.96.40.69:9082/prod/";
//   static String BaseUrlBuildingSwagger = "http://42.96.42.254:4004/prod/";
//   static String firebase_key =
//       "AAAAwmmo4S8:APA91bFrpiUhVSV5orW6qBnwzUa2376P3t7pTvkY-cPjTn2U_a93n3hj03CgaJNNjqTFZcA_KqcWggwbPZoyvzGXglFj5SEZDBVIQ985JW896aOXybIN2N_nSnxJY9BxBqNakXImCJYt";
//
//   static String login = "${BaseUrlBuilding}fleet/mobile/auth/login";
//   static String forgot_password =
//       "https://apihinov1.hino-connect.vn/prod/fleet/users/forgot-password";
//   static String forgot_password_confirm =
//       "https://apihinov1.hino-connect.vn/prod/fleet/users/confirm-forgot-password";
//
//   static String realtime = "${BaseUrlBuilding}fleet/mobile/V2/realtime";
//   static String vid_detail = "${BaseUrlBuilding}fleet/mobile/information?vid=";
//   static String factory = "${BaseUrlBuilding}fleet/mobile/V2/listgeofence";
//
//   static String listmember = "${BaseUrlBuilding}fleet/mobile/listmember";
//   static String listdriver = "${BaseUrlBuilding}fleet/mobile/V2/listdriver";
//   static String driver_detail =
//       "${BaseUrlBuilding}fleet/mobile/driverdetails?driver_id=";
//   static String notify = "${BaseUrlBuilding}fleet/mobile/history/notify";
//   static String history = "${BaseUrlBuilding}fleet/mobile/history";
//   static String dashboard_summary =
//       "${BaseUrlBuilding}fleet/mobile/V2/dashboard/summary";
//   static String dashboard_realtime =
//       "${BaseUrlBuilding}fleet/mobile/dashboard/realtime";
//   static String dashboard_driver =
//       "${BaseUrlBuilding}fleet/mobile/dashboard/driver";
//   static String trip = "${BaseUrlBuilding}fleet/mobile/V2/trips";
//   static String trip_detail = "${BaseUrlBuilding}fleet/mobile/V2/trips/detail";
//   static String logout = "${BaseUrlBuilding}fleet/mobile/auth/logout";
//   static String token =
//       "${BaseUrlBuilding}fleet/mobile/token"; // refresh endpoint
//
//   static String cctv_vehicle = "${BaseUrlBuilding}fleet/picture?";
//   static String cctv_date =
//       "${BaseUrlBuilding}fleet/mdvr/playback/calendar/info?user_id=";
//   static String cctv_live = "${BaseUrlBuilding}fleet/mdvr/playback?user_id=";
//   static String cctv_live_channel =
//       "${BaseUrlBuilding}fleet/mdvr/playback/info?user_id=";
//   static String snapshot =
//       "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/mdvr/playback/images?";
//   static String banner =
//       "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/banner/display";
//   static String news =
//       "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/news/management/display";
//
//   static String postFileUrl =
//       "https://ru.71dev.com/etest-enrollment/api/upload/upload";
//
//   static String version =
//       "https://apihinov1.hino-connect.vn/prod/fleet/mobile/getLastestVersion";
//   static String changePassword = "fleet/users/change-password";
//   static String createDriver = "fleet/mobile/create_driver";
//   static String createDriverUser = "fleet/mobile/create_driver_user";
//   static String updateDriver = "fleet/mobile/update_driver";
//   static String deleteDriver = "fleet/mobile/delete_driver";
//   static String importDriver = "fleet/driver_changes/import";
//   static String updateVehicleAssignment = "fleet/mobile/driver_manage_vehicle";
//
//   // ===== Session state =====
//   static Profile? profile;
//   static String language = "vi";
//
//   /// Access token & refresh token (lưu trong RAM; bạn tự lưu storage ở bên ngoài)
//   static String accessToken = "";
//   static String refreshTokenValue = ""; // fallback nếu profile == null
//
//   /// Cho phép gán callback để lưu token vào SecureStorage mỗi khi cập nhật
//   static Future<void> Function(String access, String? refresh)? onTokensUpdated;
//
//   // ===== Dio =====
//   static final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 25),
//       receiveTimeout: const Duration(seconds: 25),
//       responseType: ResponseType.json,
//       // cho phép 401 đi vào onError
//       validateStatus: (s) => s != null && ((s >= 200 && s < 300) || s == 401),
//     ),
//   );
//
//   static Future<void>? _refreshingFuture; // single-flight guard
//
//   /// Gọi 1 lần khi khởi động app
//   static void init() {
//     _dio.interceptors.clear();
//
//     _dio.interceptors.add(QueuedInterceptorsWrapper(
//       onRequest: (options, handler) async {
//         final isLogin =
//             options.path == login || options.uri.toString() == login;
//         final isRefresh = options.extra['isRefresh'] == true;
//         final forceAuth = options.extra['forceAuth'] == true; // ép gắn token
//
//         // Nếu đang refresh, tạm chờ các request khác để tránh gửi token cũ
//         if (!isLogin && !isRefresh && _refreshingFuture != null) {
//           try {
//             await _refreshingFuture;
//           } catch (_) {}
//         }
//
//         final lang = (language == 'vi') ? 'vi' : 'en';
//         options.headers.addAll({
//           'Accept': 'application/json',
//           'Accept-Language': lang,
//           'applicationId': '2',
//           'app_id': platform,
//           'uuid': uuid,
//           'os': os,
//         });
//         if (profile?.userId != null) {
//           options.headers['user_id'] = profile!.userId.toString();
//           options.headers['userId'] = profile!.userId.toString();
//         }
//
//         // YÊU CẦU: mọi API (trừ login) phải gửi access token; refresh cũng gửi
//         if (!isLogin || forceAuth || isRefresh) {
//           if (accessToken.isEmpty) {
//             return handler.reject(
//               DioException(
//                 requestOptions: options,
//                 error: 'Missing access token',
//                 type: DioExceptionType.unknown,
//               ),
//             );
//           }
//           options.headers['token_id'] = accessToken;
//           options.headers['Authorization'] = 'Bearer $accessToken';
//         }
//
//         handler.next(options);
//       },
//       onResponse: (response, handler) async {
//         // Một số API trả 200 nhưng body có Error.Code báo hết hạn
//         final data = response.data;
//         if (response.statusCode == 200 &&
//             data is Map &&
//             data['Error'] is Map &&
//             _isTokenExpiredCode(data['Error']['Code']) &&
//             response.requestOptions.extra['isRefresh'] != true) {
//           try {
//             await _ensureRefreshedToken();
//             final replay = await _retry(response.requestOptions);
//             return handler.resolve(replay);
//           } catch (e) {
//             return handler.reject(
//               DioException(
//                 requestOptions: response.requestOptions,
//                 response: response,
//                 error: e,
//                 type: DioExceptionType.badResponse,
//               ),
//             );
//           }
//         }
//         handler.next(response);
//       },
//       onError: (err, handler) async {
//         // HTTP 401 thực sự
//         if (err.response?.statusCode == 401 &&
//             err.requestOptions.extra['__retried'] != true &&
//             err.requestOptions.extra['isRefresh'] != true &&
//             !_isLoginRequest(err.requestOptions) &&
//             _hasRefreshToken()) {
//           try {
//             await _ensureRefreshedToken();
//             final replay = await _retry(err.requestOptions);
//             return handler.resolve(replay);
//           } catch (e) {
//             // rơi xuống lỗi gốc
//           }
//         }
//         handler.next(err);
//       },
//     ));
//
//     if (kDebugMode) {
//       _dio.interceptors.add(LogInterceptor(
//         requestBody: true,
//         responseBody: true,
//       ));
//     }
//   }
//
//   // ===== Public methods (giữ signature gần như cũ) =====
//
//   static setProfile(Profile p) {
//     profile = p;
//   }
//
//   static void setTokens({required String access, String? refresh}) {
//     accessToken = access;
//     if (refresh != null && refresh.isNotEmpty) {
//       refreshTokenValue = refresh;
//       if (profile != null) profile!.userTokenInfo?.refreshToken = refresh;
//     }
//     if (onTokensUpdated != null) {
//       // ignore: discarded_futures
//       onTokensUpdated!(accessToken, refresh);
//     }
//   }
//
//   static Future<dynamic> get(BuildContext context, String url) async {
//     try {
//       final res = await _dio.get(url);
//       return res.data;
//     } on DioException catch (e) {
//       _handleDioError(context, e);
//     } catch (e) {
//       debugPrint('GET error: $e');
//     }
//   }
//
//   static Future<dynamic> post(
//     BuildContext context,
//     String url,
//     String jsonParam, {
//     String? accessToken /* unused now, kept for API compatibility */,
//   }) async {
//     try {
//       final isLogin = url == login;
//       final res = await _dio.post(
//         url,
//         data: jsonParam,
//         options: Options(
//           contentType: Headers.jsonContentType,
//           extra: {
//             'isRefresh': false,
//             'forceAuth': false,
//             // login sẽ KHÔNG gắn token (vì chưa có)
//             // các API còn lại sẽ gắn token ở onRequest
//           },
//         ),
//       );
//       return res.data;
//     } on DioException catch (e) {
//       _handleDioError(context, e);
//     } catch (e) {
//       debugPrint('POST error: $e');
//     }
//   }
//
//   static Future<dynamic> put(
//     BuildContext context,
//     String url,
//     String jsonParam,
//   ) async {
//     try {
//       final res = await _dio.put(
//         url,
//         data: jsonParam,
//         options: Options(contentType: Headers.jsonContentType),
//       );
//       return res.data;
//     } on DioException catch (e) {
//       _handleDioError(context, e);
//     } catch (e) {
//       debugPrint('PUT error: $e');
//     }
//   }
//
//   static Future<List<Upload>?> postFile(
//       BuildContext context, String path) async {
//     try {
//       final file = await MultipartFile.fromFile(
//         path,
//         filename: path.split('/').last,
//       );
//       final form = FormData.fromMap({'path': file});
//
//       final res = await _dio.post(postFileUrl, data: form);
//
//       if (res.statusCode == 200) {
//         if (res.data is List) {
//           final list = (res.data as List)
//               .map((a) => Upload.fromJson(a))
//               .toList(growable: false);
//           return List<Upload>.from(list);
//         }
//       } else if (res.statusCode == 404) {
//         showAlertDialog(context, "Not found");
//       } else {
//         showAlertDialog(context, res.data.toString());
//       }
//     } on DioException catch (e) {
//       _handleDioError(context, e);
//     } catch (e) {
//       showAlertDialog(context, e.toString());
//     }
//     return null;
//   }
//
//   // ===== Refresh mechanics =====
//
//   static bool _isLoginRequest(RequestOptions ro) {
//     final u = ro.uri.toString();
//     return u == login || ro.path == login;
//   }
//
//   static bool _hasRefreshToken() {
//     final rt = profile!.userTokenInfo?.refreshToken ?? refreshTokenValue;
//     return rt != null && rt.toString().isNotEmpty;
//   }
//
//   static bool _isTokenExpiredCode(dynamic code) {
//     // tuỳ backend: các code báo token hết hạn
//     return code == 401 ||
//         code == 111 ||
//         code == 112 ||
//         code == 113 ||
//         code == '401' ||
//         code == '111' ||
//         code == '112' ||
//         code == '113';
//   }
//
//   static Future<void> _ensureRefreshedToken() async {
//     if (_refreshingFuture != null) {
//       return _refreshingFuture!; // await current refresh
//     }
//     _refreshingFuture = _refreshToken();
//     try {
//       await _refreshingFuture!;
//     } finally {
//       _refreshingFuture = null;
//     }
//   }
//
//   static Future<void> _refreshToken() async {
//     final refreshToken =
//         profile!.userTokenInfo?.refreshToken ?? refreshTokenValue;
//     if (refreshToken == null || refreshToken.isEmpty) {
//       throw 'Missing refresh token';
//     }
//
//     final res = await _dio.post(
//       token,
//       data: {
//         'refresh_token': refreshToken,
//       },
//       // Theo yêu cầu: refresh cũng gửi access token (dù có thể đã hết hạn)
//       options: Options(extra: {'isRefresh': true, 'forceAuth': true}),
//     );
//
//     if (res.statusCode == 200 && res.data is Map) {
//       final m = res.data as Map;
//       final newAccess = (m['access_token'] ?? m['token'] ?? '').toString();
//       if (newAccess.isEmpty) {
//         throw 'Refresh returned empty access token';
//       }
//       accessToken = newAccess;
//
//       final newRefresh = (m['refresh_token'] ?? '').toString();
//       if (newRefresh.isNotEmpty) {
//         refreshTokenValue = newRefresh;
//         if (profile != null)
//           profile!.userTokenInfo?.refreshToken = newRefresh; // rotate
//       }
//
//       if (onTokensUpdated != null) {
//         try {
//           await onTokensUpdated!(
//               accessToken, newRefresh.isNotEmpty ? newRefresh : null);
//         } catch (_) {}
//       }
//     } else {
//       throw 'Refresh token failed (${res.statusCode})';
//     }
//   }
//
//   static Future<Response<dynamic>> _retry(RequestOptions ro) {
//     final newOptions = Options(
//       method: ro.method,
//       headers: ro.headers,
//       responseType: ro.responseType,
//       contentType: ro.contentType,
//       followRedirects: ro.followRedirects,
//       validateStatus: ro.validateStatus,
//       extra: {...ro.extra, '__retried': true},
//     );
//
//     final path = ro.uri.toString(); // absolute URL
//     return _dio.request<dynamic>(
//       path,
//       data: ro.data,
//       queryParameters: ro.queryParameters,
//       options: newOptions,
//       cancelToken: ro.cancelToken,
//       onReceiveProgress: ro.onReceiveProgress,
//       onSendProgress: ro.onSendProgress,
//     );
//   }
//
//   // ===== UI helpers (kept) =====
//
//   static void showAlertDialog(BuildContext context, String message) {
//     Widget okButton = ElevatedButton(
//       child: const Text("OK"),
//       onPressed: () {
//         Navigator.pop(context);
//       },
//     );
//
//     AlertDialog alert = AlertDialog(
//       content: Text(message),
//       actions: [
//         okButton,
//       ],
//     );
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
//
//   static void _handleDioError(BuildContext context, DioException e) {
//     final code = e.response?.statusCode ?? -1;
//     if (code == 404) {
//       // optionally ignore or show a nicer message
//       return;
//     }
//     try {
//       final data = e.response?.data;
//       if (data is Map && data['Error'] is Map) {
//         final err = data['Error'];
//         if (err['Message'] != null) {
//           showAlertDialog(context, err['Message'].toString());
//           return;
//         }
//       }
//     } catch (_) {}
//
//     final errStr = e.message ?? e.error?.toString() ?? 'Network error';
//     if (errStr.contains('Missing access token')) {
//       showAlertDialog(context, 'Thiếu access token. Vui lòng đăng nhập lại.');
//     } else {
//       showAlertDialog(context, errStr);
//     }
//   }
//
//   static void showLoaderDialog(BuildContext context) {
//     AlertDialog alert = AlertDialog(
//       content: Row(
//         children: [
//           const CircularProgressIndicator(),
//           Container(
//               margin: const EdgeInsets.only(left: 7),
//               child: const Text("Loading...")),
//         ],
//       ),
//     );
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return alert;
//       },
//     );
//   }
// }

// Api with Dio + Interceptor refresh + Pretty debug logs
// - Auto attach access token for all APIs (except login)
// - Auto refresh on 401 / Error.Code 111/112/113/401, then replay the request
// - Pretty request/response/error logs with masking & timing

// Api (Dio) — Enforce x-api-key + access token on all APIs except login,
// auto-refresh with new refresh contract (POST /auth/refresh { refreshToken })
// Response returns { accessToken, refreshToken }.

// Api (Dio) — fixed refresh flow + strict headers
// - 401 is NOT an acceptable status -> goes to onError -> refresh -> replay
// - All APIs except login must send: x-api-key + token_id + Authorization
// - Refresh endpoint: POST /fleet/mobile/auth/refresh { refreshToken }
//   Response: { accessToken, refreshToken }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hino/feature/home/home.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/model/upload.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // ===== Endpoints =====
  static String BaseUrlBuilding =
      // "https://apihinov1.hino-connect.vn/prod/";
      "http://42.96.40.69:9082/prod/";
  static String BaseUrlBuildingSwagger = "http://42.96.42.254:4004/prod/";
  static String firebase_key =
      "AAAAwmmo4S8:APA91bFrpiUhVSV5orW6qBnwzUa2376P3t7pTvkY-cPjTn2U_a93n3hj03CgaJNNjqTFZcA_KqcWggwbPZoyvzGXglFj5SEZDBVIQ985JW896aOXybIN2N_nSnxJY9BxBqNakXImCJYt";

  static String login = "${BaseUrlBuilding}fleet/mobile/auth/login";
  static String forgot_password =
      "https://apihinov1.hino-connect.vn/prod/fleet/users/forgot-password";
  static String forgot_password_confirm =
      "https://apihinov1.hino-connect.vn/prod/fleet/users/confirm-forgot-password";

  static String realtime = "${BaseUrlBuilding}fleet/mobile/V2/realtime";
  static String vid_detail = "${BaseUrlBuilding}fleet/mobile/information?vid=";
  static String factory = "${BaseUrlBuilding}fleet/mobile/V2/listgeofence";

  static String listmember = "${BaseUrlBuilding}fleet/mobile/listmember";
  static String listdriver = "${BaseUrlBuilding}fleet/mobile/V2/listdriver";
  static String driver_detail =
      "${BaseUrlBuilding}fleet/mobile/driverdetails?driver_id=";
  static String notify = "${BaseUrlBuilding}fleet/mobile/history/notify";
  static String history = "${BaseUrlBuilding}fleet/mobile/history";
  static String dashboard_summary =
      "${BaseUrlBuilding}fleet/mobile/V2/dashboard/summary";
  static String dashboard_realtime =
      "${BaseUrlBuilding}fleet/mobile/dashboard/realtime";
  static String dashboard_driver =
      "${BaseUrlBuilding}fleet/mobile/dashboard/driver";
  static String trip = "${BaseUrlBuilding}fleet/mobile/V2/trips";
  static String trip_detail = "${BaseUrlBuilding}fleet/mobile/V2/trips/detail";
  static String logout = "${BaseUrlBuilding}fleet/mobile/auth/logout";

  // Deprecated for refresh; kept for compatibility in other flows
  static String token = "${BaseUrlBuilding}fleet/mobile/token";
  // NEW refresh contract
  static String refreshTokenUrl = "${BaseUrlBuilding}fleet/mobile/auth/refresh";

  static String cctv_vehicle = "${BaseUrlBuilding}fleet/picture?";
  static String cctv_date =
      "${BaseUrlBuilding}fleet/mdvr/playback/calendar/info?user_id=";
  static String cctv_live = "${BaseUrlBuilding}fleet/mdvr/playback?user_id=";
  static String cctv_live_channel =
      "${BaseUrlBuilding}fleet/mdvr/playback/info?user_id=";
  static String snapshot =
      "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/mdvr/playback/images?";
  static String banner =
      "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/banner/display";
  static String news =
      "https://3tirkucu7j.execute-api.ap-southeast-1.amazonaws.com/prod/prod/fleet/news/management/display";

  static String postFileUrl =
      "https://ru.71dev.com/etest-enrollment/api/upload/upload";

  static String version =
      "https://apihinov1.hino-connect.vn/prod/fleet/mobile/getLastestVersion";
  static String changePassword = "fleet/users/change-password";
  static String createDriver = "fleet/mobile/create_driver";
  static String createDriverUser = "fleet/mobile/create_driver_user";
  static String updateDriver = "fleet/mobile/update_driver";
  static String deleteDriver = "fleet/mobile/delete_driver";
  static String importDriver = "fleet/driver_changes/import";
  static String updateVehicleAssignment = "fleet/mobile/driver_manage_vehicle";

  // ===== Session state =====
  static Profile? profile;
  static String language = "vi";

  static String accessToken = "";
  static String refreshTokenValue = ""; // fallback nếu profile == null

  static Future<void> Function(String access, String? refresh)? onTokensUpdated;

  // ===== Debug controls =====
  static bool enableDebug = kDebugMode;
  static bool maskSensitive = true;
  static const String _tag = '[API]';

  // ===== Dio =====
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      responseType: ResponseType.json,
      // IMPORTANT: 401 is NOT valid -> triggers onError
      validateStatus: (s) => s != null && (s >= 200 && s < 300),
    ),
  );

  static Future<void>? _refreshingFuture; // single-flight guard

  /// Call once at app start
  static void init() {
    _dio.interceptors.clear();

    _dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final url = options.uri.toString();
        final isLogin = (options.path == login || url == login);
        final isRefresh = options.extra['isRefresh'] == true;

        // start time for duration
        options.extra['__start'] = DateTime.now().millisecondsSinceEpoch;

        // If a refresh is running, queue other requests until it's done
        if (!isLogin && !isRefresh && _refreshingFuture != null) {
          try {
            await _refreshingFuture;
          } catch (_) {}
        }

        final lang = (language == 'vi') ? 'vi' : 'en';
        options.headers.addAll({
          'Accept': 'application/json',
          'Accept-Language': lang,
          'applicationId': '2',
          'app_id': platform,
          'uuid': uuid,
          'os': os,
        });
        if (profile?.userId != null) {
          options.headers['user_id'] = profile!.userId.toString();
          options.headers['userId'] = profile!.userId.toString();
        }

        // All APIs except login require x-api-key + tokens
        if (!isLogin) {
          final xKey = profile?.redisKey ?? '';
          if (xKey.isEmpty) {
            _debug('REQ MISSING x-api-key → ${options.method} ${options.uri}');
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Missing x-api-key',
                type: DioExceptionType.unknown,
              ),
            );
          }
          options.headers['x-api-key'] = xKey;

          if (accessToken.isEmpty) {
            _debug(
                'REQ MISSING access token → ${options.method} ${options.uri}');
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Missing access token',
                type: DioExceptionType.unknown,
              ),
            );
          }
          // Send in BOTH custom + standard headers
          options.headers['token_id'] = accessToken;
          options.headers['Authorization'] = 'Bearer $accessToken';
        }

        _logRequest(options);
        handler.next(options);
      },
      onResponse: (response, handler) async {
        _logResponse(response);

        // Fallback if 401 somehow arrives here (different transport stacks)
        if (response.statusCode == 401 &&
            response.requestOptions.extra['isRefresh'] != true &&
            !_isLoginRequest(response.requestOptions) &&
            _hasRefreshToken()) {
          try {
            await _ensureRefreshedToken();
            final replay = await _retry(response.requestOptions);
            return handler.resolve(replay);
          } catch (e) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                error: e,
                type: DioExceptionType.badResponse,
              ),
            );
          }
        }

        // 200 but body indicates expired token
        final data = response.data;
        if ((response.statusCode == 200) &&
            data is Map &&
            ((data['Error'] is Map &&
                    _isTokenExpiredCode(data['Error']['Code'])) ||
                (data['Code'] != null && _isTokenExpiredCode(data['Code']))) &&
            response.requestOptions.extra['isRefresh'] != true) {
          try {
            await _ensureRefreshedToken();
            final replay = await _retry(response.requestOptions);
            return handler.resolve(replay);
          } catch (e) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                error: e,
                type: DioExceptionType.badResponse,
              ),
            );
          }
        }

        handler.next(response);
      },
      onError: (err, handler) async {
        _logError(err);

        // True HTTP 401 → refresh + replay
        if (err.response?.statusCode == 401 &&
            err.requestOptions.extra['__retried'] != true &&
            err.requestOptions.extra['isRefresh'] != true &&
            !_isLoginRequest(err.requestOptions) &&
            _hasRefreshToken()) {
          try {
            await _ensureRefreshedToken();
            final replay = await _retry(err.requestOptions);
            return handler.resolve(replay);
          } catch (_) {}
        }
        handler.next(err);
      },
    ));
  }

  // ===== Public methods =====

  static setProfile(Profile p) {
    profile = p;
  }

  static void setTokens({required String access, String? refresh}) {
    accessToken = access;
    if (refresh != null && refresh.isNotEmpty) {
      refreshTokenValue = refresh;
      if (profile != null) profile!.userTokenInfo?.refreshToken = refresh;
    }
    if (onTokensUpdated != null) {
      // ignore: discarded_futures
      onTokensUpdated!(accessToken, refresh);
    }
  }

  static Future<dynamic> get(BuildContext context, String url) async {
    try {
      final res = await _dio.get(url);
      return res.data;
    } on DioException catch (e) {
      _handleDioError(context, e);
    } catch (e) {
      _debug('GET error: $e');
    }
  }

  static Future<dynamic> post(
    BuildContext context,
    String url,
    String jsonParam, {
    String? accessToken /* kept for compatibility, unused */,
  }) async {
    try {
      final res = await _dio.post(
        url,
        data: jsonParam,
        options: Options(contentType: Headers.jsonContentType),
      );
      return res.data;
    } on DioException catch (e) {
      _handleDioError(context, e);
    } catch (e) {
      _debug('POST error: $e');
    }
  }

  static Future<dynamic> put(
    BuildContext context,
    String url,
    String jsonParam,
  ) async {
    try {
      final res = await _dio.put(
        url,
        data: jsonParam,
        options: Options(contentType: Headers.jsonContentType),
      );
      return res.data;
    } on DioException catch (e) {
      _handleDioError(context, e);
    } catch (e) {
      _debug('PUT error: $e');
    }
  }

  static Future<List<Upload>?> postFile(
      BuildContext context, String path) async {
    try {
      final file = await MultipartFile.fromFile(
        path,
        filename: path.split('/').last,
      );
      final form = FormData.fromMap({'path': file});

      final res = await _dio.post(postFileUrl, data: form);

      if (res.statusCode == 200) {
        if (res.data is List) {
          final list = (res.data as List)
              .map((a) => Upload.fromJson(a))
              .toList(growable: false);
          return List<Upload>.from(list);
        }
      } else if (res.statusCode == 404) {
        showAlertDialog(context, "Not found");
      } else {
        showAlertDialog(context, res.data.toString());
      }
    } on DioException catch (e) {
      _handleDioError(context, e);
    } catch (e) {
      showAlertDialog(context, e.toString());
    }
    return null;
  }

  // ===== Refresh mechanics =====

  static bool _isLoginRequest(RequestOptions ro) {
    final u = ro.uri.toString();
    return u == login || ro.path == login;
  }

  static bool _hasRefreshToken() {
    final rt = profile?.userTokenInfo?.refreshToken ?? refreshTokenValue;
    return rt != null && rt.toString().isNotEmpty;
  }

  static bool _isTokenExpiredCode(dynamic code) {
    return code == 401 ||
        code == 111 ||
        code == 112 ||
        code == 113 ||
        code == '401' ||
        code == '111' ||
        code == '112' ||
        code == '113';
  }

  static Future<void> _ensureRefreshedToken() async {
    if (_refreshingFuture != null) {
      _debug('⏳ wait existing refresh');
      return _refreshingFuture!; // await current refresh
    }
    _debug('🔄 start refresh');
    _refreshingFuture = _refreshToken();
    try {
      await _refreshingFuture!;
      _debug('✅ refresh done');
    } finally {
      _refreshingFuture = null;
    }
  }

  static Future<void> _refreshToken() async {
    final refreshToken =
        profile?.userTokenInfo?.refreshToken ?? refreshTokenValue;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw 'Missing refresh token';
    }

    final res = await _dio.post(
      refreshTokenUrl,
      data: {
        'refreshToken': refreshToken,
      },
      options: Options(
        extra: {
          'isRefresh': true,
        },
        contentType: Headers.jsonContentType,
      ),
    );

    if (res.statusCode == 200 && res.data is Map) {
      final m = res.data as Map;
      final newAccess = (m['accessToken'] ?? '').toString();
      final newRefresh = (m['refreshToken'] ?? '').toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', newAccess);

      await prefs.setString('refreshToken', newRefresh);

      _debug('newAccess token → $newAccess');
      _debug('newRefresh token → $newRefresh');
      if (newAccess.isEmpty) {
        throw 'Refresh returned empty access token';
      }
      accessToken = newAccess;
      profile!.userTokenInfo?.refreshToken = newRefresh;
      if (newRefresh.isNotEmpty) {
        refreshTokenValue = newRefresh;
        if (profile != null)
          profile!.userTokenInfo?.refreshToken = newRefresh; // rotate
      }

      if (onTokensUpdated != null) {
        try {
          await onTokensUpdated!(
              accessToken, newRefresh.isNotEmpty ? newRefresh : null);
        } catch (_) {}
      }
    } else {
      throw 'Refresh token failed (${res.statusCode})';
    }
  }

  static Future<Response<dynamic>> _retry(RequestOptions ro) {
    final newOptions = Options(
      method: ro.method,
      headers: ro.headers,
      responseType: ro.responseType,
      contentType: ro.contentType,
      followRedirects: ro.followRedirects,
      validateStatus: ro.validateStatus,
      extra: {...ro.extra, '__retried': true},
    );

    final path = ro.uri.toString();
    return _dio.request<dynamic>(
      path,
      data: ro.data,
      queryParameters: ro.queryParameters,
      options: newOptions,
      cancelToken: ro.cancelToken,
      onReceiveProgress: ro.onReceiveProgress,
      onSendProgress: ro.onSendProgress,
    );
  }

  // ===== UI helpers =====

  static void showAlertDialog(BuildContext context, String message) {
    Widget okButton = ElevatedButton(
      child: const Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      content: Text(message),
      actions: [okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }

  static void _handleDioError(BuildContext context, DioException e) {
    final code = e.response?.statusCode ?? -1;
    if (code == 404) {
      return;
    }
    try {
      final data = e.response?.data;
      if (data is Map && data['Error'] is Map) {
        final err = data['Error'];
        if (err['Message'] != null) {
          showAlertDialog(context, err['Message'].toString());
          return;
        }
      }
    } catch (_) {}

    final errStr = e.message ?? e.error?.toString() ?? 'Network error';
    if (errStr.contains('Missing access token')) {
      showAlertDialog(context, 'Thiếu access token. Vui lòng đăng nhập lại.');
    } else if (errStr.contains('Missing x-api-key')) {
      showAlertDialog(context, 'Thiếu x-api-key. Vui lòng đăng nhập lại.');
    } else {
      showAlertDialog(context, errStr);
    }
  }

  // ===== Pretty debug =====
  static const String $__pfx = '$_tag';

  static void prindebug(Object? msg) => _debug(msg);

  static void _debug(Object? msg) {
    if (!enableDebug) return;
    debugPrint(msg?.toString());
  }

  static void _logRequest(RequestOptions o) {
    if (!enableDebug) return;
    final h = _safeHeaders(o.headers);
    final qp = o.queryParameters;
    final dataStr = _pretty(o.data);
    _debug('➡️  ${o.method} ${o.uri}');
    if (qp.isNotEmpty) _debug(' Query : ${jsonEncode(qp)}');
    _debug('Headers: ${jsonEncode(h)}');
    if (o.data != null) _debug(' Body   : ${_truncate(dataStr)}');
  }

  static void _logResponse(Response r) {
    if (!enableDebug) return;
    final start = r.requestOptions.extra['__start'] as int?;
    final elapsed = start == null
        ? ''
        : ' (${DateTime.now().millisecondsSinceEpoch - start} ms)';

    _debug(
        '✅  [${r.statusCode}] ${r.requestOptions.method} ${r.requestOptions.uri}$elapsed');
    try {
      final body = _pretty(r.data);
      _debug('Resp  : ${_truncate(body)}');
    } catch (_) {}
  }

  static void _logError(DioException e) {
    if (!enableDebug) return;
    final ro = e.requestOptions;
    final start = ro.extra['__start'] as int?;
    final elapsed = start == null
        ? ''
        : ' (${DateTime.now().millisecondsSinceEpoch - start} ms)';

    _debug(
        ' ❌  [${e.response?.statusCode ?? '-'}] ${ro.method} ${ro.uri}$elapsed');
    _debug(' Type  : ${e.type}');
    if (e.message != null) _debug(' Error : ${e.message}');
    if (e.response?.data != null) {
      _debug('Body  : ${_truncate(_pretty(e.response!.data))}');
    }
  }

  static Map<String, dynamic> _safeHeaders(Map<String, dynamic> h) {
    final m = Map<String, dynamic>.from(h);
    for (final k in [
      'Authorization',
      'authorization',
      'token_id',
      'x-api-key'
    ]) {
      if (m[k] != null) m[k] = _mask(m[k].toString());
    }
    return m;
  }

  static String _mask(String? v) {
    if (!maskSensitive) return v ?? '';
    if (v == null || v.isEmpty) return '';
    if (v.length <= 8) return '***';
    return '${v.substring(0, 4)}***${v.substring(v.length - 4)}';
  }

  static String _truncate(String s, {int max = 2000}) {
    if (s.length <= max) return s;
    return s.substring(0, max) + '…(${s.length} chars)';
  }

  static String _pretty(dynamic data) {
    try {
      if (data == null) return 'null';
      if (data is String) {
        final d = jsonDecode(data);
        return const JsonEncoder.withIndent('  ').convert(d);
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}

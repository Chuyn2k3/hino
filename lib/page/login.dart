// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hino/api/api.dart';
// import 'package:hino/feature/home_realtime/home_realtime_page.dart';
// import 'package:hino/localization/language/languages.dart';
// import 'package:hino/localization/locale_constant.dart';
// import 'package:hino/model/profile.dart';
// import 'package:hino/page/forgot_password.dart';
// import 'package:hino/utils/color_custom.dart';
// import 'package:hino/utils/utils.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:io' show Platform;
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   @override
//   _PageState createState() => _PageState();
// }
//
// class _PageState extends State<LoginPage> {
//   // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//
//   var token = "";
//   var isLoading = false;
//   var obscureText = true;
//   @override
//   void initState() {
//     // firebaseMessaging
//     //     .getToken(
//     //         vapidKey:
//     //             Api.firebase_key)
//     //     .then((value) => {
//     //           if (value != null) {token = value}
//     //         });
//     super.initState();
//   }
//
//   TextEditingController usernameController = new TextEditingController();
//   TextEditingController passwordController = new TextEditingController();
//
//   loginApi(BuildContext context) {
//     isLoading = true;
//     refresh();
//     var uuid = const Uuid();
//     var platform = Platform.isAndroid ? "ANDROID" : "IOS";
//
//     var param = jsonEncode(<dynamic, dynamic>{
//       "userName": usernameController.text,
//       "password": passwordController.text,
//       "applicationId": 2,
//       "app_id": "FLEET-" + platform,
//       "uuid": uuid.v1(),
//       "token_id": token,
//     });
//
//     Api.post(context, Api.login, param).then((value) async {
//       isLoading = false;
//       refresh();
//
//       if (value != null) {
//         Profile profile = Profile.fromJson(value);
//         if (profile.userId != null) {
//           Api.setProfile(profile);
//
//           // ✅ Lưu toàn bộ profile
//           await storeProfile(json.encode(value));
//
//           // ✅ Lưu riêng token vào SharedPreferences
//           if (profile.userTokenInfo?.accessToken != null) {
//             SharedPreferences prefs = await SharedPreferences.getInstance();
//             await prefs.setString(
//                 'accessToken', profile.userTokenInfo!.accessToken!);
//           }
//
//           Navigator.of(context).pushNamedAndRemoveUntil(
//               '/root', (Route<dynamic> route) => false);
//         } else {
//           Utils.showAlertDialog(context, "Sai Tên đăng nhập hoặc Mật khẩu");
//         }
//       } else {
//         Utils.showAlertDialog(context, "Sai Tên đăng nhập hoặc Mật khẩu");
//       }
//     });
//   }
//
//   postToken(BuildContext context) {
//     var uuid = const Uuid();
//     var platform = "";
//     if (Platform.isAndroid) {
//       // Android-specific code
//       platform = "ANDROID";
//     } else if (Platform.isIOS) {
//       // iOS-specific code
//       platform = "IOS";
//     }
//
//     var param = jsonEncode(<dynamic, dynamic>{
//       "app_id": "FLEET-" + platform,
//       "uuid": uuid.v1(),
//       "token_id": token,
//       "notify": true,
//     });
//
//     Api.post(
//             context,
//             Api.token +
//                 "/" +
//                 "FLEET-" +
//                 platform +
//                 "/" +
//                 uuid.v1() +
//                 "/" +
//                 token +
//                 "?notify=true",
//             param)
//         .then((value) => {if (value != null) {} else {}});
//   }
//
//   refresh() {
//     setState(() {});
//   }
//
//   storeProfile(var jsonString) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('profile', jsonString);
//   }
//
//   // Profile? profile;
//   //
//   // getProfile() async {
//   //   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //   final jsonResponse = json.decode(prefs.getString('profile')!);
//   //   profile = Profile.fromJson(jsonResponse);
//   //   if (profile != null) {
//   //     Api.setProfile(profile!);
//   //     // Navigator.pushReplacement(
//   //     //     context, MaterialPageRoute(builder: (_) => HomePage()));
//   //     Navigator.of(context).pushNamedAndRemoveUntil(
//   //         '/root', (Route<dynamic> route) => false);
//   //   }
//   // }
//   setLang() {
//     Api.language = Api.language == 'en' ? 'vi' : 'en';
//     changeLanguage(context, Api.language);
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFFe3f2fd),
//                   Colors.white,
//                 ],
//               ),
//             ),
//           ),
//
//           // Content
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Logo
//                   Hero(
//                     tag: "app_logo",
//                     child: Image.asset(
//                       "assets/images/logo_login.png",
//                       height: 120,
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//
//                   // Username
//                   _buildTextField(
//                     controller: usernameController,
//                     hint: Languages.of(context)!.username,
//                     icon: Icons.person_outline,
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Password
//                   _buildTextField(
//                     controller: passwordController,
//                     hint: Languages.of(context)!.password,
//                     icon: Icons.lock_outline,
//                     obscure: obscureText,
//                     suffix: IconButton(
//                       icon: Icon(
//                         obscureText ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           obscureText = !obscureText;
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//
//                   // Login button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 4,
//                         backgroundColor: ColorCustom.blue,
//                       ),
//                       onPressed: () => loginApi(context),
//                       child: Text(
//                         Languages.of(context)!.signin,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                   // Forgot password
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (_) => const ForgotPasswordPage(),
//                         ),
//                       );
//                     },
//                     child: Text(
//                       Languages.of(context)!.forgot_password,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black54,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 40),
//
//                   const Text(
//                     "All Rights Reserved. © Onelink Technology Co., Ltd.",
//                     style: TextStyle(fontSize: 10, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           // Language switch (chip style)
//           Positioned(
//             top: kTextTabBarHeight,
//             right: 16,
//             child: ActionChip(
//               backgroundColor: Colors.white,
//               avatar: const Icon(Icons.language, color: ColorCustom.blue),
//               label: Text(
//                 Api.language.toUpperCase(),
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: ColorCustom.blue,
//                 ),
//               ),
//               onPressed: () => setLang(),
//             ),
//           ),
//
//           // Loading overlay
//           if (isLoading)
//             Container(
//               color: Colors.black38,
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   strokeWidth: 3,
//                   valueColor: AlwaysStoppedAnimation(ColorCustom.blue),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     bool obscure = false,
//     Widget? suffix,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: ColorCustom.blue),
//         suffixIcon: suffix,
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.white,
//         contentPadding:
//             const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide.none,
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: ColorCustom.blue, width: 1.5),
//         ),
//       ),
//     );
//   }
// }

// ======================== login.dart (refactored) ========================
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/localization/locale_constant.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/page/forgot_password.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../utils/device_id.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<LoginPage> {
  // FCM token for push
  var fcmToken = "";
  var isLoading = false;
  var obscureText = true;

  @override
  void initState() {
    super.initState();
    // TODO: lấy FCM token thật sự nếu cần
    // FirebaseMessaging.instance.getToken(vapidKey: Api.firebase_key).then((v){ if(v!=null) fcmToken = v; });
  }

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginApi(BuildContext context) async {
    isLoading = true;
    setState(() {});

    final uuidGen = const Uuid();
    final platform = Platform.isAndroid ? "ANDROID" : "IOS";
    final deviceId = await DeviceId.get();
    final param = jsonEncode(<String, dynamic>{
      "userName": usernameController.text,
      "password": passwordController.text,
      "applicationId": 2,
      "app_id": "FLEET-" + platform,
      "uuid": uuidGen.v1(),
      "deviceId": deviceId
      //"token_id": fcmToken, // push token in BODY (không liên quan access token)
    });

    try {
      final value = await Api.post(context, Api.login, param);
      isLoading = false;
      setState(() {});

      if (value != null) {
        final profile = Profile.fromJson(value);
        if (profile.userId != null) {
          // Lưu profile vào Api để interceptor gắn user_id
          Api.setProfile(profile);

          // ====== NEW: lấy access/refresh token từ response và set vào Api ======
          final access = profile.userTokenInfo?.accessToken ??
              (value['accessToken'] ?? value['token'] ?? '')?.toString();
          final refresh = profile.userTokenInfo?.refreshToken ??
              (value['refreshToken'] ?? '')?.toString();

          if (access != null && access.isNotEmpty) {
            Api.setTokens(access: access, refresh: refresh);

            // Lưu profile & token xuống SharedPreferences (đơn giản hoá)
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('profile', json.encode(value));
            await prefs.setString('accessToken', access);
            if (refresh != null && refresh.isNotEmpty) {
              await prefs.setString('refreshToken', refresh);
            }

            // (Tuỳ chọn) đăng ký FCM token lên server nếu API này yêu cầu
            await postDeviceToken(context, fcmToken);

            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/root',
                (Route<dynamic> route) => false,
              );
            }
            return;
          }
        }
      }

      Utils.showAlertDialog(context, "Sai Tên đăng nhập hoặc Mật khẩu");
    } catch (e) {
      isLoading = false;
      setState(() {});
      Utils.showAlertDialog(context, "Đăng nhập thất bại: $e");
    }
  }

  Future<void> postDeviceToken(BuildContext context, String fcmToken) async {
    if (fcmToken.isEmpty) return;

    final uuidGen = const Uuid();
    final platform = Platform.isAndroid ? "ANDROID" : "IOS";

    final param = jsonEncode(<String, dynamic>{
      "app_id": "FLEET-" + platform,
      "uuid": uuidGen.v1(),
      "token_id": fcmToken,
      "notify": true,
    });

    // LƯU Ý: Api.token trong lớp Api bây giờ là endpoint refresh.
    // Endpoint để đăng ký device token theo code cũ là:
    final deviceTokenUrl =
        "${Api.BaseUrlBuilding}fleet/mobile/token/FLEET-$platform/${uuidGen.v1()}/$fcmToken?notify=true";

    await Api.post(context, deviceTokenUrl, param);
  }

  void setLang() {
    Api.language = Api.language == 'en' ? 'vi' : 'en';
    changeLanguage(context, Api.language);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFe3f2fd),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: "app_logo",
                    child: Image.asset(
                      "assets/images/logo_login.png",
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: usernameController,
                    hint: Languages.of(context)!.username,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: passwordController,
                    hint: Languages.of(context)!.password,
                    icon: Icons.lock_outline,
                    obscure: obscureText,
                    suffix: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => obscureText = !obscureText),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        backgroundColor: ColorCustom.blue,
                      ),
                      onPressed: () => loginApi(context),
                      child: Text(
                        Languages.of(context)!.signin,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      Languages.of(context)!.forgot_password,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "All Rights Reserved. © Onelink Technology Co., Ltd.",
                    style: TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: kTextTabBarHeight,
            right: 16,
            child: ActionChip(
              backgroundColor: Colors.white,
              avatar: const Icon(Icons.language, color: ColorCustom.blue),
              label: Text(
                Api.language.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ColorCustom.blue,
                ),
              ),
              onPressed: () => setLang(),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(ColorCustom.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: ColorCustom.blue),
        suffixIcon: suffix,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorCustom.blue, width: 1.5),
        ),
      ),
    );
  }
}

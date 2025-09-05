import 'dart:convert';

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
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<LoginPage> {
  // FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  var token = "";
  var isLoading = false;
  var obscureText = true;
  @override
  void initState() {
    // firebaseMessaging
    //     .getToken(
    //         vapidKey:
    //             Api.firebase_key)
    //     .then((value) => {
    //           if (value != null) {token = value}
    //         });
    super.initState();
  }

  TextEditingController usernameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  loginApi(BuildContext context) {
    isLoading = true;
    refresh();
    var uuid = const Uuid();
    var platform = "";
    if (Platform.isAndroid) {
      // Android-specific code
      platform = "ANDROID";
    } else if (Platform.isIOS) {
      // iOS-specific code
      platform = "IOS";
    }

    var param = jsonEncode(<dynamic, dynamic>{
      "userName": usernameController.text,
      "password": passwordController.text,
      // "userName": "hc0853861806s",
      // "password": "hc0853861806solt",
      "applicationId": 2,
      "app_id": "FLEET-" + platform,
      "uuid": uuid.v1(),
      "token_id": token,
      // "student_code": "62000344",
      // "password": "123456",
    });

    Profile profile;
    Api.post(context, Api.login, param).then((value) => {
          isLoading = false,
          refresh(),
          if (value != null)
            {
              // postToken(context),
              profile = Profile.fromJson(value),
              if (profile.userId != null)
                {
                  isAdvertise = true,
                  Api.setProfile(profile),
                  storeProfile(json.encode(value)),
                  // Navigator.pushReplacement(
                  //     context, MaterialPageRoute(builder: (_) => HomePage()))
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/root', (Route<dynamic> route) => false),
                }
              else
                {
                  Utils.showAlertDialog(
                      context, "Sai Tên đăng nhập hoặc Mật khẩu")
                }
            }
          else
            {
              Utils.showAlertDialog(
                  context, "Sai Tên đăng nhập hoặc Mật khẩu")
            }
        });
  }

  postToken(BuildContext context) {
    var uuid = const Uuid();
    var platform = "";
    if (Platform.isAndroid) {
      // Android-specific code
      platform = "ANDROID";
    } else if (Platform.isIOS) {
      // iOS-specific code
      platform = "IOS";
    }

    var param = jsonEncode(<dynamic, dynamic>{
      "app_id": "FLEET-" + platform,
      "uuid": uuid.v1(),
      "token_id": token,
      "notify": true,
    });

    Api.post(
            context,
            Api.token +
                "/" +
                "FLEET-" +
                platform +
                "/" +
                uuid.v1() +
                "/" +
                token +
                "?notify=true",
            param)
        .then((value) => {if (value != null) {} else {}});
  }

  refresh() {
    setState(() {});
  }

  storeProfile(var jsonString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile', jsonString);
  }

  // Profile? profile;
  //
  // getProfile() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final jsonResponse = json.decode(prefs.getString('profile')!);
  //   profile = Profile.fromJson(jsonResponse);
  //   if (profile != null) {
  //     Api.setProfile(profile!);
  //     // Navigator.pushReplacement(
  //     //     context, MaterialPageRoute(builder: (_) => HomePage()));
  //     Navigator.of(context).pushNamedAndRemoveUntil(
  //         '/root', (Route<dynamic> route) => false);
  //   }
  // }
  setLang() {
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
                  // Logo
                  Hero(
                    tag: "app_logo",
                    child: Image.asset(
                      "assets/images/logo_login.png",
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 40),
      
                  // Username
                  _buildTextField(
                    controller: usernameController,
                    hint: Languages.of(context)!.username,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
      
                  // Password
                  _buildTextField(
                    controller: passwordController,
                    hint: Languages.of(context)!.password,
                    icon: Icons.lock_outline,
                    obscure: obscureText,
                    suffix: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
      
                  // Login button
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
      
                  // Forgot password
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
      
          // Language switch (chip style)
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
      
          // Loading overlay
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

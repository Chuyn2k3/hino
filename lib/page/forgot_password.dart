import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/page/forgot_password_confirm.dart';
import 'package:hino/page/home.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/widget/back_ios.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

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

class _PageState extends State<ForgotPasswordPage> {
  @override
  void initState() {
    super.initState();
  }

  forgot(BuildContext context) {
    var param = jsonEncode(<dynamic, dynamic>{
      "phone_number": textEditingController.text,
    });

    Api.post(context, Api.forgot_password, param).then((value) {
      if (value != null && value["message"]?["token"] != null) {
        var user = value["message"]["token"].toString();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForgotPasswordConfirmPage(
              user: user,
            ),
          ),
        );
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value?["message"]?["error"]?.toString() ??
                  "Có lỗi xảy ra. Vui lòng thử lại!",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }).catchError((e) {
      // Trường hợp lỗi network hoặc exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không thể kết nối. Vui lòng thử lại sau."),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  TextEditingController textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppbar.basic(onTap: () => Navigator.pop(context)),
      body: Container(
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       Color(0xFF4A90E2), // xanh gradient
        //       Colors.white,
        //     ],
        //   ),
        // ),
        child: Column(
          children: [
            //BackIOS(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo/Icon minh hoạ
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.lock_reset,
                          color: Color(0xFF4A90E2), size: 40),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      Languages.of(context)!.forgot_password,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Languages.of(context)!.email_phone,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Card form input
                    Card(
                      color: Colors.white,
                      elevation: 6,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: TextField(
                          controller: textEditingController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Colors.grey),
                            border: InputBorder.none,
                            hintText: Languages.of(context)!.email_phone,
                            hintStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Confirm button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorCustom.blue,
                          // gradient: const LinearGradient(
                          //   colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                          // ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => forgot(context),
                          child: Text(
                            Languages.of(context)!.confirm,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

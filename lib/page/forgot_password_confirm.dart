import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/page/home.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/widget/back_ios.dart';

class ForgotPasswordConfirmPage extends StatefulWidget {
  const ForgotPasswordConfirmPage({Key? key, required this.user}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String user;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<ForgotPasswordConfirmPage> {
  @override
  void initState() {
    super.initState();
  }

  forgotConfirm(BuildContext context) {
    var param = jsonEncode(<dynamic, dynamic>{
      "token": widget.user,
      "new_password": textNewPassEditingController.text,
    });

    Api.post(context, Api.forgot_password_confirm, param).then((value) => {
          if (value != null)
            {Navigator.of(context).popUntil(ModalRoute.withName('/login'))}
          else
            {}
        });
  }

  TextEditingController textNewPassEditingController = new TextEditingController();
  TextEditingController textRePassEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                ColorCustom.greyBG2,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              BackIOS(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(bottom: 40, top: 40),
                        child: Text(Languages.of(context)!.confirm_password,
                          style: TextStyle(color: Colors.black, fontSize: 40),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(Languages.of(context)!.new_password,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                      Container(
                        child: TextField(
                          controller: textNewPassEditingController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: Languages.of(context)!.new_password,
                            hintStyle: TextStyle(fontSize: 16),
                            // fillColor: colorSearchBg,
                          ),
                        ),
                      ),
                      /* Container(
                        margin: EdgeInsets.only(top: 10),
                        alignment: Alignment.centerLeft,
                        child: Text(Languages.of(context)!.reenter_password,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                      Container(
                        child: TextField(
                          controller: textRePassEditingController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: Languages.of(context)!.reenter_password,
                            hintStyle: TextStyle(fontSize: 16),
                            // fillColor: colorSearchBg,
                          ),
                        ),
                      ), */
                      Expanded(child: Container()),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: ColorCustom.blue,
                            padding: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(5), // <-- Radius
                            ),
                          ),
                          onPressed: () {
                            forgotConfirm(context);
                          },
                          child: Text(Languages.of(context)!.confirm,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/page/home.dart';
import 'package:hino/page/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_noti_map.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {

    super.initState();
    goMainScreen();
  }

  // 5 seconds later -> onDoneControl
  Future<Timer> goMainScreen() async {
    return new Timer(Duration(seconds: 2), onDoneControl);
  }

  // route to MainScreen
  onDoneControl() {
    // Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (context) => LandingPage()));
    var jsonResponse;
    var profile;
    SharedPreferences.getInstance().then((prefs) => {
          if (prefs.getString('profile') != null &&
              !prefs.getString('profile')!.isEmpty)
            {
              jsonResponse = json.decode(prefs.getString('profile')!),
              profile = Profile.fromJson(jsonResponse),
              Api.setProfile(profile!),
              // Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(builder: (context) => HomePage())),
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/root', (Route<dynamic> route) => false),
            }
          else
            {
              // Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(builder: (context) => LoginPage()))
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false),
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    var assetImage = AssetImage('assets/images/logo_login.png');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Image(image: assetImage),
              ),
            ),
            Text(
              "All Rights Reserved. © Onelink Technology Co., Ltd.",
              style: TextStyle(color: Colors.black, fontSize: 10),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/localization/locale_constant.dart';
import 'package:hino/page/login.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSettingsPage extends StatefulWidget {
  const HomeSettingsPage({super.key});

  @override
  State<HomeSettingsPage> createState() => _HomeSettingsPageState();
}

class _HomeSettingsPageState extends State<HomeSettingsPage> {
  bool isNotiSetting = false;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _loadNotiSetting();
  }

  Future<void> _loadNotiSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNotiSetting = prefs.getBool('noti') ?? false;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('noti', value);
    setState(() => isNotiSetting = value);

    if (value) {
      final token =
          await firebaseMessaging.getToken(vapidKey: Api.firebase_key);
      if (token != null) {
        Api.post(context, Api.token, jsonEncode({}));
      }
    } else {
      await firebaseMessaging.deleteToken();
      Api.post(context, Api.token, jsonEncode({}));
    }
  }

  void _switchLanguage() {
    Api.language = Api.language == 'en' ? 'vi' : 'en';
    changeLanguage(context, Api.language);
  }

  Future<void> _logout() async {
    await Api.post(context, Api.logout, jsonEncode({}));
    AwesomeNotifications().cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  Widget _settingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? ColorCustom.blue),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;
    final profile = Api.profile!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      // appBar: AppBar(
      //   title: Text(lang.settings),
      //   //backgroundColor: ColorCustom.blue,
      //   elevation: 1,
      // ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: ColorCustom.greyBG2, width: 1.5),
                    ),
                    child: ClipOval(
                      child: profile.avatarUrl != null &&
                              profile.avatarUrl!.isNotEmpty
                          ? FadeInImage.assetNetwork(
                              placeholder: 'assets/images/profile_empty.png',
                              image: profile.avatarUrl!,
                              fit: BoxFit.cover,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                    'assets/images/profile_empty.png',
                                    fit: BoxFit.cover);
                              },
                            )
                          : Image.asset('assets/images/profile_empty.png',
                              fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.displayName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(profile.email,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _settingItem(
            icon: Icons.translate,
            title: lang.select_lang,
            trailing: Text(Api.language == 'vi' ? 'Tiếng Việt' : 'English',
                style: const TextStyle(
                  color: ColorCustom.blue,
                  fontSize: 16,
                )),
            onTap: _switchLanguage,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(Icons.notifications,
                color: isNotiSetting ? ColorCustom.blue : Colors.grey),
            title: Text(lang.notification),
            value: isNotiSetting,
            onChanged: _toggleNotifications,
            tileColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          const SizedBox(height: 30),
          _settingItem(
            icon: Icons.logout,
            title: lang.sign_out,
            iconColor: Colors.red,
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

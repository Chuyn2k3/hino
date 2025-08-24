import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/localization/locale_constant.dart';
import 'package:hino/page/login.dart';
import 'package:hino/utils/base_scaffold.dart';
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

  Widget _settingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: (iconColor ?? ColorCustom.blue).withOpacity(0.1),
              child: Icon(icon, color: iconColor ?? ColorCustom.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;
    final profile = Api.profile!;

    return BaseScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
             // Spacer(),
              // SizedBox(height: 32,),
              // Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
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
                          const SizedBox(height: 8),
                          // ElevatedButton(
                          //   onPressed: () {},
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: ColorCustom.blue,
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 20, vertical: 8),
                          //     shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8)),
                          //   ),
                          //   child: Text(lang.edit_profile,
                          //       style: const TextStyle(color: Colors.white)),
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
        
              // Settings Card (gộp chung)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _settingTile(
                      icon: Icons.translate,
                      title: lang.select_lang,
                      trailing: Text(
                        Api.language == 'vi' ? 'Tiếng Việt' : 'English',
                        style: const TextStyle(
                            color: ColorCustom.blue, fontWeight: FontWeight.w500),
                      ),
                      onTap: _switchLanguage,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeColor: ColorCustom.blue,
                      secondary: CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            (isNotiSetting ? ColorCustom.blue : Colors.grey)
                                .withOpacity(0.1),
                        child: Icon(Icons.notifications,
                            color:
                                isNotiSetting ? ColorCustom.blue : Colors.grey),
                      ),
                      title: Text(lang.notification,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                      value: isNotiSetting,
                      onChanged: _toggleNotifications,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    const Divider(height: 1),
                    _settingTile(
                      icon: Icons.logout,
                      title: lang.sign_out,
                      iconColor: Colors.red,
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home_driver/home_driver.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/feature/home_settings/home_settings.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/banner.dart';
import 'package:hino/model/marker_icon.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/page/home_backup.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;


final String uuid = const Uuid().v1();
String platform = "", token = "", os = "";
bool isNotiSetting = false;
List<BannerHino> listBanner = [];
List<MarkerIcon> listIcon = [];
StreamController<int> notiController = StreamController<int>.broadcast();
int noti_count = 0;

void printApiStatus(http.Response res) {
  log(res.request!.headers.toString());
  log(res.request!.url.toString());
  log(res.statusCode.toString());
  log(res.body);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool isActive = false;
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeRealtimePage(),
    const HomeBackupPage(),
    const HomeDriverPage(),
    const HomeSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    isActive = true;
    _initApp();
  }

  Future<void> _initApp() async {
    _loadMarkerIcons();
    await _loadProfileOrRedirect();
    _setupNotifications();
    _fetchBanner();
    _checkForceUpdate();
  }

  Future<void> _loadProfileOrRedirect() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString('profile') ?? '';
    if (profileString.isEmpty) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }
    final profile = Profile.fromJson(json.decode(profileString));
    Api.setProfile(profile);
    setState(() {});
  }

  Future<void> _setupNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    isNotiSetting = prefs.getBool('noti') ?? false;

    if (await Permission.notification.request().isGranted) {
      FirebaseMessaging.onMessage.listen(_onMessageReceived);
    }

    _setPlatformInfo();

    token = await _messaging.getToken(vapidKey: Api.firebase_key) ?? '';
    if (token.isNotEmpty && isNotiSetting) postToken();
  }

  void _onMessageReceived(RemoteMessage message) {
    log('Firebase message: ${message.data}');
    if (!isNotiSetting) return;
    noti_count++;
    notiController.add(noti_count);
    if (message.notification?.title != null) {
      Utils.sendNotification(
        message.notification!.title!,
        message.notification!.body ?? '',
        message.notification!.title!,
      );
    }
  }

  Future<void> _setPlatformInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      os = '${info.version.release} (SDK ${info.version.sdkInt}), '
          '${info.manufacturer} ${info.model}';
      platform = "FLEET-ANDROID";
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      os = '${info.systemName} ${info.systemVersion}, '
          '${info.name} ${info.model}';
      platform = "FLEET-IOS";
    }
  }

  void postToken() {
    final body = jsonEncode({
      "app_id": platform,
      "uuid": uuid,
      "token": token,
      "notify": true,
    });
    Api.post(context, '${Api.token}/$platform/$uuid/$token?notify=true', body);
  }

  Future<void> _fetchBanner() async {
    final value = await Api.get(context, Api.banner);
    if (value != null) {
      setState(() {
        listBanner = (value['result']['banner'] as List)
            .map((e) => BannerHino.fromJson(e))
            .toList();
      });
    }
  }

  Future<void> _checkForceUpdate() async {
    try {
      final response = await Api.get(context, Api.version);
      final minVersion = response?['result']?['version'] as String?;
      if (minVersion != null) {
        final current = (await PackageInfo.fromPlatform()).version;
        if (_compareVersion(current, minVersion) < 0) {
          _showForceUpdateDialog();
        }
      }
    } catch (e) {
      log('Force update check failed: $e');
    }
  }

  int _compareVersion(String v1, String v2) {
    final a = v1.split('.');
    final b = v2.split('.');
    final len = [a.length, b.length].reduce((a, b) => a > b ? a : b);
    for (int i = 0; i < len; i++) {
      final ai = int.tryParse(a.elementAt(i)) ?? 0;
      final bi = int.tryParse(b.elementAt(i)) ?? 0;
      if (ai != bi) return ai > bi ? 1 : -1;
    }
    return 0;
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text("Cập nhật ứng dụng"),
          content: const Text("Vui lòng cập nhật phiên bản mới nhất để tiếp tục."),
          actions: [
            TextButton(
              onPressed: () {
                final url = Platform.isAndroid
                    ? "https://play.google.com/store/apps/details?id=com.hinogpsfleetmanagerapp"
                    : "https://apps.apple.com/us/app/hino-gps/id6670476079";
                launchUrl(Uri.parse(url));
              },
              child: const Text("Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }

  void _loadMarkerIcons() {
    const colors = ["GREEN", "RED", "RED", "YELLOW", "WHITE", "VIOLET"];
    for (int i = 0; i < 7; i++) {
      for (final c in colors) {
        final path = 'assets/images/$c${i + 1}.png';
        getBytesFromAsset(path, 250).then((bytes) {
          listIcon.add(MarkerIcon(BitmapDescriptor.fromBytes(bytes), path, bytes));
        });
      }
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  void dispose() {
    super.dispose();
    isActive = false;
    notiController.close();
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = context.watch<PageProvider>().is_select_vehicle;
    if (vehicle != null) {
      _currentIndex = 0;
    }
    final lang = Languages.of(context)!;
    return Scaffold(
      backgroundColor: ColorCustom.black,
      body: SafeArea(
        child: listBanner.isEmpty && Api.profile == null
            ? _buildEmptyState()
            : Column(
                children: [
                  Expanded(child: _pages[_currentIndex]),
                  BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i),
                    selectedItemColor: ColorCustom.blue,
                    unselectedItemColor: ColorCustom.greyButton,
                    items: [
                      _navItem(lang.track, "Fix Icon Hino25.svg"),
                      _navItem(lang.history, "icon_history.svg"),
                      _navItem(lang.event_driver, "Fix Icon Hino33.svg"),
                      _navItem(lang.settings, "Fix Icon Hino15.svg", size: 30),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(String label, String asset,
      {double? size}) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset("assets/images/$asset", width: size),
      activeIcon: SvgPicture.asset(
        "assets/images/$asset",
        width: size,
        color: ColorCustom.blue,
      ),
      label: label,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset('assets/images/logo_login.png'),
          )),
          const Text("All Rights Reserved. © Onelink Technology Co., Ltd.",
              style: TextStyle(color: Colors.black, fontSize: 10)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

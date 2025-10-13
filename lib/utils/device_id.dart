import 'dart:io' show Platform;

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceId {
  static const _prefsKey = 'device_id_cached';

  /// Trả về deviceId ổn định:
  /// - Android: ANDROID_ID
  /// - iOS: identifierForVendor
  /// - Fallback: UUID v4 (nếu vì lý do nào đó 2 cách trên trả null)
  static Future<String> get() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefsKey);
    if (cached != null && cached.isNotEmpty) return cached;

    String? id;

    try {
      if (Platform.isAndroid) {
        id = await const AndroidId().getId(); // ANDROID_ID
      } else if (Platform.isIOS) {
        final ios = await DeviceInfoPlugin().iosInfo;
        id = ios.identifierForVendor; // IDFV
      }
    } catch (_) {
      // ignore và dùng fallback phía dưới
    }

    id ??= const Uuid().v4(); // fallback an toàn trong mọi trường hợp
    await prefs.setString(_prefsKey, id);
    return id;
  }
}

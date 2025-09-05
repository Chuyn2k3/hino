import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hino/utils/nfc_helper.dart';
import 'package:path/path.dart';

class Iso15693Channel {
  static const MethodChannel _channel = MethodChannel('iso15693_channel');
  static void initLogListener(void Function(String log) onLog) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "debugLog") {
        final msg = call.arguments as String;
        onLog(msg);
      }
    });
  }

  static Future<Uint8List?> readBlocks({
    int startBlock = 0,
    int count = 15,
  }) async {
    try {
      final dynamic result = await _channel.invokeMethod(
        'readBlocks',
        {
          "startBlock": startBlock,
          "count": count,
        },
      );
      //  DebugHelper.show(context, result.toString());
      if (result is List) {
        return Uint8List.fromList(
            result.map((e) => (e as num).toInt()).toList());
      }
      return null;
    } on PlatformException catch (e) {
      print("Error reading blocks: $e");
      return null;
    }
  }
}

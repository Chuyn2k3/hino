import 'dart:ffi';

import 'package:hino/api/api.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_jp.dart';
import 'package:hino/localization/language/language_th.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/utils/utils.dart';

class CctvDateChannel {

  String? label_name;
  int? channel_id;

  CctvDateChannel(String name,int a) {
    this.label_name = name;
    this.channel_id = a;
  }

  CctvDateChannel.fromJson(Map<String, dynamic> json) {

    label_name = json['label_name'];
    channel_id = json['channel_id'];
  }
}

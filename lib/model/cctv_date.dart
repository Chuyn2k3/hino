import 'dart:ffi';

import 'package:hino/api/api.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_jp.dart';
import 'package:hino/localization/language/language_th.dart';
import 'package:hino/model/cctv_date_channel.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/utils/utils.dart';

import 'cctv_date_date.dart';

class CctvDate {
  List<CctvDateDate> listDate = [];
  List<CctvDateChannel> listChannel = [];

  CctvDate.fromJson(Map<String, dynamic> json) {
    listDate =
        List.from(json['data']).map((a) => CctvDateDate.fromJson(a)).toList();
    listChannel = List.from(json['channel_info'])
        .map((a) => CctvDateChannel.fromJson(a))
        .toList();
    listDate.sort((b, a) => a.date!.compareTo(b.date!));
  }
}

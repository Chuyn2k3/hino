import 'dart:ffi';

import 'package:hino/api/api.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_jp.dart';
import 'package:hino/localization/language/language_th.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/utils/utils.dart';

class CctvDateDate {
  String? date;
  int? filetype;
  CctvDateDate.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    filetype = json['filetype'];

  }
}

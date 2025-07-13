import 'dart:ffi';

import 'package:hino/api/api.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_jp.dart';
import 'package:hino/localization/language/language_th.dart';
import 'package:hino/localization/language/language_vi.dart';
import 'package:hino/localization/language/languages.dart';

class DriverCard {
  String? card_id;
  String? name;
  String? driver_phone;

  int? status_swipe_card;

  DriverCard.fromJson(Map<String, dynamic> json) {
    card_id = json['card_id'];
    name = json['name'];
    status_swipe_card = json['status_swipe_card'];
    driver_phone = json['driver_phone'];

    if (card_id == null || card_id!.isEmpty || card_id! == "-") {

      if (Api.language == "vi") {
        card_id = LanguageVi().unidentified_driver;
      } else {
        card_id = LanguageEn().unidentified_driver;
      }
    }
    if (name == null || name!.isEmpty) {
      name = card_id;
    }
    if (name == null || name!.isEmpty) {
      if (Api.language == "vi") {
        name = LanguageVi().unidentified_driver;
      } else {
        name = LanguageEn().unidentified_driver;
      }
    }
  }
}

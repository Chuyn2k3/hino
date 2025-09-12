import 'package:hino/api/api.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_vi.dart';

class DriverCard {
  String? card_id;
  String? name;
  String? driver_phone;
  int? status_swipe_card;

  DriverCard({
    this.card_id,
    this.name,
    this.driver_phone,
    this.status_swipe_card,
  });

  DriverCard.fromJson(Map<String, dynamic> json) {
    card_id = json['card_id'];
    name = json['name'];
    status_swipe_card = json['status_swipe_card'];
    driver_phone = json['driver_phone'];

    // Nếu card_id null/empty/"-"
    if (card_id == null || card_id!.isEmpty || card_id == "-") {
      card_id = Api.language == "vi"
          ? LanguageVi().unidentified_driver
          : LanguageEn().unidentified_driver;
    }

    // Nếu name null/empty → lấy card_id
    if (name == null || name!.isEmpty) {
      name = card_id;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "card_id": card_id,
      "name": name,
      "driver_phone": driver_phone,
      "status_swipe_card": status_swipe_card,
    };
  }
}

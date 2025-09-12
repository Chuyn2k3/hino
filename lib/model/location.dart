import 'package:hino/api/api.dart';

class Location {
  String? admin_level3_name;
  String? admin_level2_name;
  String? admin_level1_name;

  Location({
    this.admin_level3_name,
    this.admin_level2_name,
    this.admin_level1_name,
  });

  Location.fromJson(Map<String, dynamic> json) {
    if (Api.language == "en") {
      admin_level3_name = json['admin_level3_name_en'];
      admin_level2_name = json['admin_level2_name_en'];
      admin_level1_name = json['admin_level1_name_en'];
    } else {
      admin_level3_name = json['admin_level3_name'];
      admin_level2_name = json['admin_level2_name'];
      admin_level1_name = json['admin_level1_name'];
    }
  }

  Map<String, dynamic> toJson() {
    if (Api.language == "en") {
      return {
        "admin_level3_name_en": admin_level3_name,
        "admin_level2_name_en": admin_level2_name,
        "admin_level1_name_en": admin_level1_name,
      };
    } else {
      return {
        "admin_level3_name": admin_level3_name,
        "admin_level2_name": admin_level2_name,
        "admin_level1_name": admin_level1_name,
      };
    }
  }
}

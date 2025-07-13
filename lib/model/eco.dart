import 'dart:ffi';

import 'package:hino/api/api.dart';

class Eco {
  String? arg;

  var avg;

  var point;

  Eco.fromJson(Map<String, dynamic> json) {
    arg = mapName(json['arg']);
    avg = json['avg'];
    point = json['point'];
  }

  mapName(String name) {
    if (Api.language == "en") {
      if (name == "rpm_high") {
        return "RPM High Speed";
      } else if (name == "rpm_low") {
        return "RPM Low Speed";
      } else if (name == "shift_up") {
        return "Shift Up & Exceeding RPM";
      } else if (name == "shift_down,") {
        return "Shift Down & Exceeding RPM";
      } else if (name == "long_idling") {
        return "Long Idling";
      } else if (name == "exhaust_brake") {
        return "Exhaust Brake Retarder";
      } else {
        return name;
      }
    } else {
      if (name == "rpm_high") {
        return "RPM Tốc độ cao";
      } else if (name == "rpm_low") {
        return "RPM Tốc độ thấp";
      } else if (name == "shift_up") {
        return "Tăng tốc và vượt quá RPM";
      } else if (name == "shift_down,") {
        return "Giảm tốc và vượt quá RPM";
      } else if (name == "long_idling") {
        return "Chạy không tải lâu";
      } else if (name == "exhaust_brake") {
        return "Bộ hãm phanh xả";
      } else {
        return name;
      }
    }
  }
}

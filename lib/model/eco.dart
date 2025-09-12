import 'package:hino/api/api.dart';

class Eco {
  String? arg; // tên hiển thị đã map
  String? rawArg; // tên gốc từ API
  dynamic avg;
  dynamic point;

  Eco({
    this.arg,
    this.rawArg,
    this.avg,
    this.point,
  });

  factory Eco.fromJson(Map<String, dynamic> json) {
    final raw = json['arg'] as String?;
    return Eco(
      arg: raw != null ? _mapName(raw) : null,
      rawArg: raw,
      avg: json['avg'],
      point: json['point'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "arg": rawArg, // trả về tên gốc
      "avg": avg,
      "point": point,
    };
  }

  static String _mapName(String name) {
    if (Api.language == "en") {
      switch (name) {
        case "rpm_high":
          return "RPM High Speed";
        case "rpm_low":
          return "RPM Low Speed";
        case "shift_up":
          return "Shift Up & Exceeding RPM";
        case "shift_down":
          return "Shift Down & Exceeding RPM";
        case "long_idling":
          return "Long Idling";
        case "exhaust_brake":
          return "Exhaust Brake Retarder";
        default:
          return name;
      }
    } else {
      switch (name) {
        case "rpm_high":
          return "RPM Tốc độ cao";
        case "rpm_low":
          return "RPM Tốc độ thấp";
        case "shift_up":
          return "Tăng tốc và vượt quá RPM";
        case "shift_down":
          return "Giảm tốc và vượt quá RPM";
        case "long_idling":
          return "Chạy không tải lâu";
        case "exhaust_brake":
          return "Bộ hãm phanh xả";
        default:
          return name;
      }
    }
  }
}

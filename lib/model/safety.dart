import 'package:hino/api/api.dart';

class Safety {
  String? arg; // Tên hiển thị đã map
  String? rawArg; // Giá trị gốc từ API
  dynamic avg;
  dynamic point;

  Safety({
    this.arg,
    this.rawArg,
    this.avg,
    this.point,
  });

  factory Safety.fromJson(Map<String, dynamic> json) {
    final raw = json['arg'] as String?;
    return Safety(
      arg: raw != null ? _mapName(raw) : null,
      rawArg: raw,
      avg: json['avg'],
      point: json['point'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "arg": rawArg, // trả về tên gốc, không phải tên hiển thị
      "avg": avg,
      "point": point,
    };
  }

  static String _mapName(String name) {
    if (Api.language == "en") {
      switch (name) {
        case "harsh_start":
          return "Harsh Start";
        case "harsh_acceleration":
          return "Harsh Acceleration";
        case "harsh_brake":
          return "Harsh Brake";
        case "sharp_turn":
          return "Sharp Turn";
        case "exceeding_speed":
          return "Exceeding Speed";
        case "exceeding_rpm":
          return "Exceeding RPM";
        default:
          return name;
      }
    } else {
      switch (name) {
        case "harsh_start":
          return "Bắt đầu đột ngột";
        case "harsh_acceleration":
          return "Tăng tốc đột ngột";
        case "harsh_brake":
          return "Phanh đột ngột";
        case "sharp_turn":
          return "Rẽ đột ngột";
        case "exceeding_speed":
          return "Quá tốc độ";
        case "exceeding_rpm":
          return "Quá RPM";
        default:
          return name;
      }
    }
  }
}

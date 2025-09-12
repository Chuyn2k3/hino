import 'package:hino/model/location.dart';

class Gps {
  String? imei;
  String? gpsdate;
  String? server_date;
  double? lat;
  double? lng;
  dynamic speed;
  String? io_code;
  String? io_name;
  String? io_color;
  String? acc;
  String? gps_stat;
  double? course;
  int? sattellite;
  int? sattellite_per;
  int? sattellite_level;
  int? gsm;
  int? gsm_per;
  int? gsm_level;
  double? device_batt;
  double? vehicle_batt;
  int? device_batt_level;
  int? vehicle_batt_level;
  String? fuel_rate;
  int? fuel_cons;
  int? fuel_per;
  Location? location;
  String? display_gpsdate;

  Gps({
    this.imei,
    this.gpsdate,
    this.server_date,
    this.lat,
    this.lng,
    this.speed,
    this.io_code,
    this.io_name,
    this.io_color,
    this.acc,
    this.gps_stat,
    this.course,
    this.sattellite,
    this.sattellite_per,
    this.sattellite_level,
    this.gsm,
    this.gsm_per,
    this.gsm_level,
    this.device_batt,
    this.vehicle_batt,
    this.device_batt_level,
    this.vehicle_batt_level,
    this.fuel_rate,
    this.fuel_cons,
    this.fuel_per,
    this.location,
    this.display_gpsdate,
  });

  Gps.fromJson(Map<String, dynamic> json) {
    imei = json['imei']?.toString();
    gpsdate = json['gpsdate']?.toString();
    server_date = json['server_date']?.toString();

    lat = (json['lat'] as num?)?.toDouble();
    lng = (json['lng'] as num?)?.toDouble();
    speed = json['speed'];

    io_code = json['io_code']?.toString();
    io_name = json['io_name']?.toString();
    io_color = json['io_color']?.toString();
    acc = json['acc']?.toString();
    gps_stat = json['gps_stat']?.toString();

    course = (json['course'] as num?)?.toDouble();
    sattellite = json['sattellite'];
    sattellite_per = json['sattellite_per'];
    sattellite_level = json['sattellite_level'];

    gsm = json['gsm'];
    gsm_per = json['gsm_per'];
    gsm_level = json['gsm_level'];

    device_batt = (json['device_batt'] as num?)?.toDouble();
    vehicle_batt = (json['vehicle_batt'] as num?)?.toDouble();

    device_batt_level = json['device_batt_level'];
    vehicle_batt_level = json['vehicle_batt_level'];

    fuel_rate = json['fuel_rate']?.toString();
    fuel_cons = json['fuel_cons'];
    fuel_per = json['fuel_per'];

    display_gpsdate = json['display_gpsdate']?.toString();

    if (json['location'] != null) {
      location = Location.fromJson(json['location']);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "imei": imei,
      "gpsdate": gpsdate,
      "server_date": server_date,
      "lat": lat,
      "lng": lng,
      "speed": speed,
      "io_code": io_code,
      "io_name": io_name,
      "io_color": io_color,
      "acc": acc,
      "gps_stat": gps_stat,
      "course": course,
      "sattellite": sattellite,
      "sattellite_per": sattellite_per,
      "sattellite_level": sattellite_level,
      "gsm": gsm,
      "gsm_per": gsm_per,
      "gsm_level": gsm_level,
      "device_batt": device_batt,
      "vehicle_batt": vehicle_batt,
      "device_batt_level": device_batt_level,
      "vehicle_batt_level": vehicle_batt_level,
      "fuel_rate": fuel_rate,
      "fuel_cons": fuel_cons,
      "fuel_per": fuel_per,
      "display_gpsdate": display_gpsdate,
      "location": location?.toJson(),
    };
  }
}

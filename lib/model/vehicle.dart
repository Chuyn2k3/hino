import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/model/driver_card.dart';
import 'package:hino/model/fleet.dart';
import 'package:hino/model/info.dart';
import 'gps.dart';

class Vehicle {
  Fleet? fleet;
  Info? info;
  Gps? gps;
  DriverCard? driverCard;
  BitmapDescriptor? icon;

  int searchType;
  bool isSelect;

  Vehicle({
    this.fleet,
    this.info,
    this.gps,
    this.driverCard,
    this.icon,
    this.searchType = 0,
    this.isSelect = true,
  });

  Vehicle.fromJson(Map<String, dynamic> json)
      : searchType = 0,
        isSelect = true {
    if (json.containsKey("fleet") && json["fleet"] != null) {
      fleet = Fleet.fromJson(json["fleet"]);
    }
    if (json.containsKey("info") && json["info"] != null) {
      info = Info.fromJson(json["info"]);
    }
    if (json.containsKey("gps") && json["gps"] != null) {
      gps = Gps.fromJson(json["gps"]);
    }
    if (json.containsKey("driver_cards") && json["driver_cards"] != null) {
      driverCard = DriverCard.fromJson(json["driver_cards"]);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "fleet": fleet?.toJson(),
      "info": info?.toJson(),
      "gps": gps?.toJson(),
      "driver_cards": driverCard?.toJson(),
      // icon không serialize được trực tiếp, nếu cần thì convert sang String (bitmap path)
      "searchType": searchType,
      "isSelect": isSelect,
    };
  }
}

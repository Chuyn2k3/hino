//import 'dart:ffi';

import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/model/Sensor.dart';
import 'package:hino/model/driver_card.dart';
import 'package:hino/model/fleet.dart';
import 'package:hino/model/info.dart';
import 'package:hino/model/maintenance.dart';

import 'gps.dart';

class Vehicle {
  Vehicle();

  Fleet? fleet;
  Info? info;
  Gps? gps;
  DriverCard? driverCard;
  BitmapDescriptor? icon;

  int searchType = 0;
  bool isSelect = true;

  Vehicle.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("fleet")) {
      fleet = Fleet.fromJson(json['fleet']);
    }

    info = Info.fromJson(json['info']);
    gps = Gps.fromJson(json['gps']);
    driverCard = DriverCard.fromJson(json['driver_cards']);
  }
}

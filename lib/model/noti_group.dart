import 'dart:ffi';

import 'package:hino/model/history.dart';
import 'package:hino/model/location.dart';
import 'package:hino/model/noti.dart';
import 'package:hino/model/vehicle.dart';

class NotiGroup {
  String? name;
  List<Noti> notifications = [];
  List<Vehicle> vehicle = [];

  NotiGroup({String? name}) {
    this.name = name;
    this.notifications = [];
    this.vehicle = [];
  }
}

import 'dart:ffi';

import 'package:hino/model/canbus.dart';
import 'package:hino/model/option.dart';
import 'package:hino/model/temperature.dart';

class Sensor {
  Option? option;

  Temperature? temperature;

  Canbus? canbus;

  Sensor.fromJson(Map<String, dynamic> json) {
    option = Option.fromJson(json['options']);
    temperature = Temperature.fromJson(json['temperatures']);
    canbus = Canbus.fromJson(json["canbus"]);
  }
}

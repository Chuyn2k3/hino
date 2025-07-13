import 'dart:ffi';

import 'package:hino/model/history.dart';
import 'package:hino/model/location.dart';
import 'package:hino/model/trip.dart';

class EventGroup {

  String? date;
  List<History> history = [];
  bool isExpand = false;
  List<Trip> trips = [];

}

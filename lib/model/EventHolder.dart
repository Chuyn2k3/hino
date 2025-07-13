import 'dart:ffi';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventHolder {

  LatLng latlng = LatLng(0, 0);
  double course = 0;
  String date = "";

  EventHolder({required LatLng l,required double c,required String d}){
    this.course = c;
    this.latlng = l;
    date = d;
  }
}

import 'dart:typed_data';

import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/model/factory.dart';
import 'package:hino/model/vehicle.dart';

class MarkerIcon  {
   BitmapDescriptor? icon;
   String? name;
   Uint8List? iconByte;

   MarkerIcon(BitmapDescriptor icon,String name,Uint8List iconByte){
     this.icon = icon;
     this.name = name;
     this.iconByte = iconByte;
   }


}
import 'dart:typed_data';

import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/model/factory.dart';
import 'package:hino/model/vehicle.dart';

class MarkerIconFactory  {
  Uint8List? icon;
   int? name;

   MarkerIconFactory(Uint8List icon,int name){
     this.icon = icon;
     this.name = name;
   }


}
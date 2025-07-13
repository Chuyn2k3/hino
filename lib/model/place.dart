import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/model/factory.dart';
import 'package:hino/model/vehicle.dart';

class Place with ClusterItem {
   Factory? factory;
   Vehicle? vehicle;
  final LatLng latLng;

  Place({this.factory,this.vehicle, required this.latLng});

  @override
  LatLng get location => latLng;
}
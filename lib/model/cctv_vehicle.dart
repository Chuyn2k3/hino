import 'dart:ffi';

import 'package:hino/api/api.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_jp.dart';
import 'package:hino/localization/language/language_th.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/utils/utils.dart';

class CctvVehicle {
  String? terid;
  int? vehicleId;
  String? vehicleName;
  String? licensePlateNo;
  String? vinNo;
  int? status;

  CctvVehicle.fromJson(Map<String, dynamic> json) {
    terid = json['terid'];
    vehicleId = json['vehicle_id'];
    vehicleName = json['vehicle_name'];
    licensePlateNo = json['license_plate_no'];
    vinNo = json['vin_no'];
    status = json['status'];
  }
}


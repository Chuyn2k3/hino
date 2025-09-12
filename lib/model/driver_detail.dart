import 'package:hino/model/eco.dart';
import 'package:hino/model/safety.dart';

import 'driver_info_model.dart';
import 'driver_user_model.dart';

class DriverDetail {
  String? driverName;
  String? driverLicenseId;
  String? driverLicensecardType;
  String? cardExpire;
  String? totalTime;
  double? distance;
  double? fuelUsage;
  List<Safety> safety = [];
  List<Eco> eco = [];
  DriverInfoModel? driverInfo;
  DriverUserModel? driverUser;

  DriverDetail({
    this.driverName,
    this.driverLicenseId,
    this.driverLicensecardType,
    this.cardExpire,
    this.totalTime,
    this.distance,
    this.fuelUsage,
    this.safety = const [],
    this.eco = const [],
    this.driverInfo,
    this.driverUser,
  });

  factory DriverDetail.fromJson(Map<String, dynamic> json) {
    return DriverDetail(
      driverName: json['driver_name'],
      driverLicenseId: json['driver_license_id'],
      driverLicensecardType: json['driver_licensecard_type'],
      cardExpire: json['card_expire'],
      totalTime: json['total_time'],
      distance: (json['distance'] ?? 0).toDouble(),
      fuelUsage: (json['fuel_usage'] ?? 0).toDouble(),
      safety: (json['safety'] != null)
          ? List.from(json['safety']).map((a) => Safety.fromJson(a)).toList()
          : [],
      eco: (json['eco'] != null)
          ? List.from(json['eco']).map((a) => Eco.fromJson(a)).toList()
          : [],
      driverInfo: json['driver_info'] != null
          ? DriverInfoModel.fromJson(json['driver_info'])
          : null,
      driverUser: json['driver_user'] != null
          ? DriverUserModel.fromJson(json['driver_user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "driver_name": driverName,
      "driver_license_id": driverLicenseId,
      "driver_licensecard_type": driverLicensecardType,
      "card_expire": cardExpire,
      "total_time": totalTime,
      "distance": distance,
      "fuel_usage": fuelUsage,
      "safety": safety.map((e) => e.toJson()).toList(),
      "eco": eco.map((e) => e.toJson()).toList(),
      "driver_info": driverInfo?.toJson(),
      "driver_user": driverUser?.toJson(),
    };
  }
}

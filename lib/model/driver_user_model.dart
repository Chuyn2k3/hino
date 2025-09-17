import 'package:intl/intl.dart';

class DriverUserModel {
  final int? driverUserId;
  final String? displayName;
  final String? username;
  final String? mobile;
  final String? email;
  final DateTime? expiredDate;
  final String? lastChangePassword;
  final String? avatarAttachId;
  final List<int?>? vehicleIds;

  DriverUserModel({
    this.driverUserId,
    this.displayName,
    this.username,
    this.mobile,
    this.email,
    this.expiredDate,
    this.lastChangePassword,
    this.avatarAttachId,
    this.vehicleIds,
  });

  factory DriverUserModel.fromJson(Map<String, dynamic> json) {
    return DriverUserModel(
      driverUserId: json['driver_user_id'] as int?,
      displayName: json['display_name'] as String?,
      username: json['username'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
      expiredDate: (json['expired_date'] != null && json['expired_date'] != "")
          ? DateTime.tryParse(json['expired_date'] as String)
          : null,
      lastChangePassword: json['last_change_password'] as String?,
      avatarAttachId: json['avatar_attach_id'] as String?,
      vehicleIds: json['vehicle_ids'] != null
          ? List<int?>.from(json['vehicle_ids'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "driver_user_id": driverUserId,
      "display_name": displayName,
      "username": username,
      "mobile": mobile,
      "email": email,
      "expired_date": expiredDate != null
          ? DateFormat("yyyy-MM-dd").format(expiredDate!)
          : null,
      "last_change_password": lastChangePassword,
      "avatar_attach_id": avatarAttachId,
      "vehicle_ids": vehicleIds,
    };
  }
}

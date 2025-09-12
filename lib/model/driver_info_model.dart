import 'dart:convert';
import 'package:intl/intl.dart';

class DriverInfoModel {
  final String? prefix;
  final String? firstname;
  final String? lastname;
  final String? fullAddress;
  final String? displayName;
  final DateTime? startDate;
  final String? personalId;
  final String? phone;

  final DateTime? birthDate;

  final DateTime? cardExpiredDate;
  final String? cardId;
  final int? userId;
  DriverInfoModel({
    this.prefix,
    this.firstname,
    this.lastname,
    this.personalId,
    this.cardId,
    this.phone,
    this.birthDate,
    this.startDate,
    this.fullAddress,
    this.cardExpiredDate,
    this.displayName,
    this.userId,
  });

  factory DriverInfoModel.fromJson(Map<String, dynamic> json) {
    return DriverInfoModel(
      prefix: json['prefix'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      personalId: json['personal_id'] as String?,
      cardId: json['card_id'] as String?,
      phone: json['phone1'] as String?,
      birthDate: json['birth_date'] != null && json['birth_date'] != ""
          ? DateTime.tryParse(json['birth_date'])
          : null,
      startDate: json['start_date'] != null && json['start_date'] != ""
          ? DateTime.tryParse(json['start_date'])
          : null,
      fullAddress: json['full_address'] as String?,
      userId: json['user_id'] as int?,
      cardExpiredDate:
          json['card_expired_date'] != null && json['card_expired_date'] != ""
              ? DateTime.tryParse(json['card_expired_date'])
              : null,
      displayName: json['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> body = {
      "prefix": prefix,
      "firstname": firstname,
      "lastname": lastname,
      "personal_id": personalId,
      "card_id": cardId,
      "phone1": phone,
      "birth_date": birthDate != null
          ? DateFormat("yyyy-MM-dd").format(birthDate!)
          : null,
      "start_date": startDate != null
          ? DateFormat("yyyy-MM-dd").format(startDate!)
          : null,
      "full_address": fullAddress,
      "user_id": userId,
      "display_name": displayName,
    };
    if (cardExpiredDate != null) {
      body["card_expired_date"] =
          DateFormat("yyyy-MM-dd").format(cardExpiredDate!);
    }
    return body;
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}

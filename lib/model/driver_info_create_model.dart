import 'dart:convert';
import 'package:hino/model/driver_info_model.dart';
import 'package:intl/intl.dart';

class DriverInfoCreateModel {
  final String? prefix;
  final String? firstname;
  final String? lastname;
  final String? personalId;
  final String? cardId;
  final String? phone;
  final DateTime? birthDate;
  final DateTime? startDate;
  final String? fullAddress;
  final int? userId;
  final DateTime? cardExpiredDate;

  DriverInfoCreateModel({
    this.prefix,
    this.firstname,
    this.lastname,
    this.personalId,
    this.cardId,
    this.phone,
    this.birthDate,
    this.startDate,
    this.fullAddress,
    this.userId,
    this.cardExpiredDate,
  });

  factory DriverInfoCreateModel.fromJson(Map<String, dynamic> json) {
    return DriverInfoCreateModel(
      prefix: json['prefix'] as String?,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      personalId: json['personal_id'] as String?,
      cardId: json['card_id'] as String?,
      phone: json['phone'] as String?,
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
    );
  }
  factory DriverInfoCreateModel.fromDriverInfoModel(DriverInfoModel model) {
    return DriverInfoCreateModel(
      prefix: model.prefix,
      firstname: model.firstname,
      lastname: model.lastname,
      personalId: model.personalId,
      cardId: model.cardId,
      phone: model.phone, // lưu ý: DriverInfoModel.phone lấy từ phone1
      birthDate: model.birthDate,
      startDate: model.startDate,
      fullAddress: model.fullAddress,
      userId: model.userId,
      cardExpiredDate: model.cardExpiredDate,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> body = {
      "prefix": prefix,
      "firstname": firstname,
      "lastname": lastname,
      "personal_id": personalId,
      "card_id": cardId,
      "phone": phone,
      "start_date": startDate != null
          ? DateFormat("yyyy-MM-dd").format(startDate!)
          : null,
      "full_address": fullAddress,
      "user_id": userId,
    };
    if (birthDate != null) {
      body["birth_date"] = DateFormat("yyyy-MM-dd").format(birthDate!);
    }
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

import 'package:hino/api/api.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_vi.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/utils/utils.dart';

class Driver {
  int? id;
  int? driver_id;
  int? score;
  String? prefix;
  String? firstname;
  String? lastname;
  String? personalId;
  String? photoUrl;
  String? datetimeSwipe;
  String? imei;
  int? statusSwipeCard;
  String? licensePlateNo;
  String? vehicleName;
  var lat;
  var lng;
  String? adminLevel3Name;
  String? adminLevel2Name;
  String? adminLevel1Name;
  Vehicle? vehicle;

  String? driver_phone_no;
  String? box_phone_no;

  String? display_datetime_swipe;
  String? display_last_updated;
  String? card_id;

  Driver({
    this.id,
    this.driver_id,
    this.score,
    this.prefix,
    this.firstname,
    this.lastname,
    this.personalId,
    this.photoUrl,
    this.datetimeSwipe,
    this.imei,
    this.statusSwipeCard,
    this.licensePlateNo,
    this.vehicleName,
    this.lat,
    this.lng,
    this.adminLevel3Name,
    this.adminLevel2Name,
    this.adminLevel1Name,
    this.vehicle,
    this.driver_phone_no,
    this.box_phone_no,
    this.display_datetime_swipe,
    this.display_last_updated,
    this.card_id,
  });

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driver_id = json['driver_id'];
    score = json['score'];
    prefix = json['prefix'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    personalId = json['personal_id'];
    photoUrl = json['photo_url'];
    datetimeSwipe = json['datetime_swipe'];
    imei = json['imei'];
    statusSwipeCard = json['status_swipe_card'];
    licensePlateNo = json['license_plate_no'];
    vehicleName = json['vehicle_name'];
    lat = json['lat'];
    lng = json['lng'];

    if (Api.language == "en") {
      adminLevel3Name = json['admin_level3_name_en'];
      adminLevel2Name = json['admin_level2_name_en'];
      adminLevel1Name = json['admin_level1_name_en'];
    } else {
      adminLevel3Name = json['admin_level3_name'];
      adminLevel2Name = json['admin_level2_name'];
      adminLevel1Name = json['admin_level1_name'];
    }

    display_datetime_swipe = json['display_datetime_swipe'];
    display_last_updated = json['display_last_updated'];

    vehicle = Utils.getVehicleByLicense(licensePlateNo ?? "");

    if (vehicleName == null || vehicleName!.isEmpty || vehicleName! == "-") {
      vehicleName = licensePlateNo;
    }
    card_id = json['card_id'] ?? "";
    if (firstname == null || firstname!.isEmpty) {
      firstname = card_id;
    }

    if (firstname == null || firstname!.isEmpty) {
      if (Api.language == "vi") {
        firstname = LanguageVi().unidentified_driver;
      } else {
        firstname = LanguageEn().unidentified_driver;
      }
    }

    driver_phone_no = json['driver_phone_no'] ?? "";
    box_phone_no = json['box_phone_no'] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "driver_id": driver_id,
      "score": score,
      "prefix": prefix,
      "firstname": firstname,
      "lastname": lastname,
      "personal_id": personalId,
      "photo_url": photoUrl,
      "datetime_swipe": datetimeSwipe,
      "imei": imei,
      "status_swipe_card": statusSwipeCard,
      "license_plate_no": licensePlateNo,
      "vehicle_name": vehicleName,
      "lat": lat,
      "lng": lng,
      "admin_level3_name": adminLevel3Name,
      "admin_level2_name": adminLevel2Name,
      "admin_level1_name": adminLevel1Name,
      "display_datetime_swipe": display_datetime_swipe,
      "display_last_updated": display_last_updated,
      "card_id": card_id,
      "driver_phone_no": driver_phone_no,
      "box_phone_no": box_phone_no,
      // nếu Vehicle có toJson thì thêm vào:
      "vehicle": vehicle != null ? vehicle!.toJson() : null,
    };
  }
}

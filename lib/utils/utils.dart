import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/driver.dart';
import 'package:hino/model/noti.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_realtime.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../page/home.dart';

class Utils {
  static String convertDateFromMilli(String? selectedDate) {
    if (selectedDate == null) {
      return "";
    }
    var date = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(selectedDate);
    return DateFormat('d MMM yyyy').format(date);
  }

  static String convertDateToBase(String? selectedDate) {
    if (selectedDate == null || selectedDate.isEmpty) {
      return "";
    }
    // print(selectedDate);
    // var date =
    // DateFormat('yyyy-MM-dd HH:mm:ss').parseUTC(selectedDate).toLocal();
    // return DateFormat('d MMM yy HH:mm').format(date);
    try {
      var date =
          DateFormat('yyyy-MM-dd HH:mm:ss').parseUTC(selectedDate).toLocal();
      return DateFormat('d MMM yy HH:mm').format(date);
    } catch (e) {
      return selectedDate;
    }
  }

  static String convertDateToDay(String? selectedDate) {
    if (selectedDate == null || selectedDate.isEmpty) {
      return "";
    }
    // print(selectedDate);
    // var date =
    // DateFormat('yyyy-MM-dd HH:mm:ss').parseUTC(selectedDate).toLocal();
    // return DateFormat('d MMM yy HH:mm').format(date);
    try {
      var date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(selectedDate);
      return DateFormat('d MMM yy').format(date);
    } catch (e) {
      return selectedDate;
    }
  }

  static String convertDateToBaseReal(String? selectedDate) {
    if (selectedDate == null || selectedDate.isEmpty) {
      return "";
    }
    try {
      var date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(selectedDate);
      return DateFormat('d MMM yy HH:mm').format(date);
    } catch (e) {
      return selectedDate;
    }
  }

  static String convertDatePlayback(String? selectedDate) {
    if (selectedDate == null || selectedDate.isEmpty) {
      return "";
    }
    var date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(selectedDate);
    return DateFormat('d MMM yy HH:mm:ss').format(date);
  }

  static String convertDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      return "";
    }
    return DateFormat('d MMM yyyy').format(selectedDate);
  }

  static String convertDatePickup(String? selectedDate) {
    if (selectedDate == null) {
      return "";
    }
    var date = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(selectedDate);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static DateTime convertDatePickupDateTime(String? selectedDate) {
    if (selectedDate == null) {
      return DateTime.now();
    }
    var date = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(selectedDate);
    return date;
  }

  static String getDateGraph(String? selectedDate) {
    if (selectedDate == null) {
      return "";
    }
    try {
      var date = DateFormat('yyyy-MM-dd').parse(selectedDate);
      return DateFormat('d MMM').format(date) +
          "\n" +
          DateFormat('yyyy').format(date);
    } catch (e) {
      return selectedDate;
    }
  }

  // 2021-09-28T07:27:37.873Z
  static getDateCreate() {
    return DateFormat('yyyy-MM-dd').format(new DateTime.now());
  }

  static getDateTimeCreate() {
    return DateFormat('HH:mm').format(new DateTime.now());
  }

  static getDateBackYear() {
    var d = DateTime.now().subtract(Duration(days: 30));
    return DateFormat('yyyy-MM-dd').format(d);
  }

  static getDatePickup(String selectedDate) {
    var date = DateFormat('dd/MM/yyyy').parse(selectedDate);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static dateFromServerToPost(String selectedDate) {
    var date = DateFormat('yyyy-MM-ddTHH:mm:ss').parse(selectedDate);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static Widget getRisk(int? risk_id) {
    if (risk_id == null) {
      return Container();
    }
    if (risk_id == 0) {
      return Icon(
        Icons.circle,
        color: Colors.red,
        size: 40,
      );
    } else if (risk_id == 1) {
      return Icon(
        Icons.circle,
        color: Colors.yellow,
        size: 40,
      );
    } else {
      return Icon(
        Icons.circle,
        color: Colors.green,
        size: 40,
      );
    }
  }

  static showAlertDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static String numberFormat(double number) {
    var formatter = NumberFormat('#,###,##0.0');
    try {
      return formatter.format(number);
    } catch (e) {
      return number.toString();
    }
  }

  static String numberFormatInt(int number) {
    var formatter = NumberFormat('#,###,##0');
    try {
      return formatter.format(number);
    } catch (e) {
      return number.toString();
    }
  }

  static Widget statusCarImage(String status, var speed) {
    if (Api.language == "th") {
      switch (status.toLowerCase()) {
        case "driving":
          return Image.asset(
            "assets/images/car_icon.png",
            width: 60,
            height: 60,
          );
        case "ign.off":
          return Image.asset("assets/images/car_icon2.png",
              width: 60, height: 60);
        case "parking":
          return Image.asset("assets/images/car_icon2.png",
              width: 60, height: 60);
        case "idling":
          return Image.asset("assets/images/car_icon3.png",
              width: 60, height: 60);
        case "offline":
          return Image.asset("assets/images/icon_offline.png",
              width: 60, height: 60);
        case "over_speed":
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorCustom.over_speed2,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  speed.toStringAsFixed(0),
                  style: TextStyle(
                      color: ColorCustom.over_speed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'กม/ชม',
                  style: TextStyle(
                      color: ColorCustom.over_speed,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
      }
    } else {
      switch (status.toLowerCase()) {
        case "driving":
          return Image.asset(
            "assets/images/icon_driving_en.png",
            width: 60,
            height: 60,
          );
        case "ign.off":
          return Image.asset("assets/images/icon_parking_en.png",
              width: 60, height: 60);
        case "parking":
          return Image.asset("assets/images/icon_parking_en.png",
              width: 60, height: 60);
        case "idling":
          return Image.asset("assets/images/icon_idle_en.png",
              width: 60, height: 60);
        case "offline":
          return Image.asset("assets/images/icon_offline_en.png",
              width: 60, height: 60);
        case "over_speed":
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorCustom.over_speed2,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  speed.toStringAsFixed(0),
                  style: TextStyle(
                      color: ColorCustom.over_speed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'km/h',
                  style: TextStyle(
                      color: ColorCustom.over_speed,
                      fontSize: 8,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
      }
    }

    return Image.asset("assets/images/car_icon.png", width: 60, height: 60);
  }

  static Widget eventIcon(Noti no, BuildContext context) {
    switch (no.event_id) {
      case 1001:
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: ColorCustom.over_speed2,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                no.speed.toString(),
                style: TextStyle(
                    color: ColorCustom.over_speed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                Languages.of(context)!.km_h,
                style: TextStyle(
                    color: ColorCustom.over_speed,
                    fontSize: 8,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case 10000:
        return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.handyman,
              size: 30,
              color: Colors.black,
            ));
      case 10001:
        return Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.bus_alert,
              size: 30,
              color: Colors.white,
            ));
    }
    return Container();
  }

  // List data1 = [
  //   "ความเร็วเกินกำหนด",
  //   "เข้าพื้นที่เสี่ยง",
  //   "ออกพื้นที่เสี่ยง",
  //   "แจ้งเตือนเข้าศูนย์บริการ",
  //   "ไฟเครื่องยนต์เตือน"
  // ];
  static String eventTitle(int event_id) {
    switch (event_id) {
      case 1001:
        return "ความเร็วเกินกำหนด";
      case 1004:
        return "เข้าพื้นที่เสี่ยง";
      case 1007:
        return "ออกพื้นที่เสี่ยง";
      case 10000:
        return "แจ้งเตือนเข้าศูนย์บริการ";
      case 10001:
        return "ไฟเครื่องยนต์เตือน";
      case 7:
        return "ออกตัวกระทันหัน";
      case 9:
        return "เร่งความเร็วกระทันหัน";
      case 14:
        return "เบรกกระแทก";
      case 21:
        return "เลี้ยวรุนแรง";
      case 1010:
        return "รูดบัตรขับรถ";
      case 1011:
        return "รูดบัตรเลิกขับ";
    }
    return "";
  }

  static String eventTitleEn(int event_id) {
    switch (event_id) {
      case 1001:
        return "Over Speed";
      case 1004:
        return "Enter hazard zone";
      case 1007:
        return "Exit hazard zone";
      case 10000:
        return "Maintenance Remind";
      case 10001:
        return "Engine Lamp";
      case 7:
        return "Harsh Start";
      case 9:
        return "Harsh Acceleration";
      case 14:
        return "Harsh Brake";
      case 21:
        return "Sharp Turn";
      case 1010:
        return "Swipe Card";
      case 1011:
        return "Not Swipe Card";
    }
    return "";
  }

  static Widget swipeCard(Driver driver, BuildContext context) {
    switch (driver.statusSwipeCard) {
      case 0:
        return Row(
          children: [
            Icon(
              Icons.credit_card,
              size: 20,
              color: Colors.red,
            ),
            Text(
              Languages.of(context)!.no_swipe_card,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        );
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  size: 20,
                  color: Colors.green,
                ),
                Text(
                  Languages.of(context)!.swipe_card,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        );
      case 2:
        return Row(
          children: [
            Icon(
              Icons.credit_card,
              size: 20,
              color: Colors.orange,
            ),
            Text(
              Languages.of(context)!.wrong_license,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
              ),
            ),
          ],
        );
      case 3:
        return Row(
          children: [
            Icon(
              Icons.credit_card,
              size: 20,
              color: Colors.grey,
            ),
            Text(
              Languages.of(context)!.expire_card,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        );
    }
    return Container();
  }

  static Vehicle? getVehicleByLicense(String license) {
    for (Vehicle v in listVehicle) {
      if (v.info!.licenseplate == license) {
        return v;
      }
    }
    return null;
  }

  static Vehicle? getVehicleByVinNo(String vinNo) {
    for (Vehicle v in listVehicle) {
      if (v.info!.vin_no == vinNo) {
        return v;
      }
    }
    return null;
  }

  static String mapEcoName(String name) {
    if (Api.language == "en") {
      if (name == "Exhaust Brake/Retarder") {
        return "Exhaust Brake Retarder";
      }
      return name;
    } else {
      if (name == "Long Idling") {
        return "Đỗ xe không tắt máy";
      } else if (name == "Exhaust Brake/Retarder") {
        return "Phanh xả chậm hơn";
      } else if (name == "RPM High Speed") {
        return "Chu kỳ máy ở tốc độ cao";
      } else if (name == "RPM Low Speed") {
        return "Chu kỳ máy ở tốc độ thấp";
      } else if (name == "Shift Up & Exceeding RPM") {
        return "Thêm thiết bị";
      } else if (name == "Shift Down & Exceeding RPM") {
        return "Giảm tốc độ";
      }
    }

    return name;
  }

  static String mapSafetyName(String name) {
    if (Api.language == "en") {
      return name;
    } else {
      if (name == "Exceeding Speed") {
        return "Quá tốc độ";
      } else if (name == "Exceeding RPM") {
        return "Quá RPM";
      } else if (name == "Harsh Start") {
        return "Bắt đầu đột ngột";
      } else if (name == "Harsh Acceleration") {
        return "Tăng tốc đột ngột";
      } else if (name == "Harsh Brake") {
        return "Phanh đột ngột";
      } else if (name == "Sharp Turn") {
        return "Rẽ đột ngột";
      }
    }

    return name;
  }

  static String mapDltName(String name) {
    if (Api.language == "en") {
      if (name == "dlt_4hour") {
        return "DLT Driving Continuous 4h";
      } else if (name == "dlt_8hour") {
        return "DLT Driving Over 8h per Day";
      } else if (name == "dlt_overspeed") {
        return "DLT Driving Over Speed";
      } else if (name == "dlt_unknown") {
        return "DLT Not Swipe Driving License Card";
      } else if (name == "dlt_unplug") {
        return "DLT GPS Unplugged";
      } else if (name == "dlt_wrongtype") {
        return "DLT Wrong Type License Card";
      }
    } else {
      if (name == "dlt_4hour") {
        return "Lái xe liên tục trong hơn 7 giờ.";
      } else if (name == "dlt_8hour") {
        return "Lái xe hơn 8 giờ mỗi ngày.";
      } else if (name == "dlt_overspeed") {
        return "Vượt quá giới hạn tốc độ";
      } else if (name == "dlt_unknown") {
        return "Không quẹt giấy phép lái xe";
      } else if (name == "dlt_unplug") {
        return "GPS không được kết nối";
      } else if (name == "dlt_wrongtype") {
        return "Loại giấy phép lái xe sai";
      }
    }

    return name;
  }

  static String mapDrivingName(String name) {
    if (Api.language == "en") {
      if (name == "harsh_acceleration") {
        return "Harsh Acceleration";
      } else if (name == "harsh_brake") {
        return "Harsh Brake";
      } else if (name == "harsh_start") {
        return "Harsh Start";
      } else if (name == "overspeed_100") {
        return "Over Speed 100 km/h";
      } else if (name == "overspeed_120") {
        return "Over Speed 120 km/h";
      } else if (name == "overspeed_60") {
        return "Over Speed 60 km/h";
      } else if (name == "overspeed_80") {
        return "Over Speed 80 km/h";
      } else if (name == "sharp_turn") {
        return "Sharp Turn";
      }
    } else {
      if (name == "harsh_acceleration") {
        return "Đột ngột tăng tốc";
      } else if (name == "harsh_brake") {
        return "Phanh đột ngột";
      } else if (name == "harsh_start") {
        return "Bắt đầu đột ngột";
      } else if (name == "overspeed_100") {
        return "Tốc độ vượt quá 100 km/h";
      } else if (name == "overspeed_120") {
        return "Tốc độ vượt quá 120 km/h";
      } else if (name == "overspeed_60") {
        return "Tốc độ vượt quá 60 km/h";
      } else if (name == "overspeed_80") {
        return "Tốc độ vượt quá 80 km/h";
      } else if (name == "sharp_turn") {
        return "Rẽ đột ngột";
      }
    }

    return name;
  }

  static String mapIconVehicle(int id) {
    if (id == 2) {
      return "1.png";
    } else if (id == 3) {
      return "2.png";
    } else if (id == 4) {
      return "6.png";
    } else if (id == 5) {
      return "4.png";
    } else if (id == 6) {
      return "4.png";
    } else if (id == 7) {
      return "5.png";
    } else if (id == 8) {
      return "5.png";
    } else if (id == 9) {
      return "5.png";
    } else if (id == 10) {
      return "8.png";
    } else if (id == 11) {
      return "8.png";
    } else if (id == 12) {
      return "9.png";
    } else if (id == 13) {
      return "4.png";
    } else if (id == 14) {
      return "7.png";
    } else if (id == 15) {
      return "5.png";
    } else if (id == 22) {
      return "8.png";
    } else if (id == 25) {
      return "6.png";
    }

    return "5.png";
  }

  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value.toDouble();
    }
  }

  static showAlertDialogEmpty(BuildContext context) {
    // set up the button
    Widget okButton = ElevatedButton(
      child: Text("Go back"),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("No data found"),
      content: Text("Please Try Again"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static String channelId = "1000";
  static String channelName = "FLUTTER_NOTIFICATION_CHANNEL";
  static String channelDescription = "FLUTTER_NOTIFICATION_CHANNEL_DETAIL";

  static sendNotification(String title, String message, String unix) async {
    // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //     channelId, channelName,
    //     channelDescription: channelDescription,
    //     importance: Importance.max,
    //     priority: Priority.high);
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    //
    // var platformChannelSpecifics = NotificationDetails(
    //     android: androidPlatformChannelSpecifics,
    //     iOS: iOSPlatformChannelSpecifics);
    Random random = new Random();
    int randomNumber = random.nextInt(1000);
    // var myInt = int.parse(unix);
    // await flutterLocalNotificationsPlugin.show(
    //     randomNumber, title, message, platformChannelSpecifics,
    //     payload: unix);
    // AwesomeNotifications().incrementGlobalBadgeCounter();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: randomNumber,
          channelKey: 'hino_noti',
          title: title,
          body: message),
    );
  }

  static bool isLoad = false;

  static void loadingProgress(BuildContext context) {
    isLoad = true;
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5), child: Text("Loading..")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

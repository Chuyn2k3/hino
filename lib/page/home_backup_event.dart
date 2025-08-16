// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:group_button/group_button.dart';
// import 'package:hino/api/api.dart';
// import 'package:hino/feature/home_realtime/home_realtime_page.dart';
// import 'package:hino/localization/language/language_en.dart';
// import 'package:hino/localization/language/language_jp.dart';
// import 'package:hino/localization/language/language_th.dart';
// import 'package:hino/localization/language/language_vi.dart';
// import 'package:hino/localization/language/languages.dart';
// import 'package:hino/model/dropdown.dart';
// import 'package:hino/model/member.dart';
// import 'package:hino/model/truck.dart';
// import 'package:hino/model/vehicle.dart';
// import 'package:hino/page/home_backup_event_search.dart';
// import 'package:hino/page/home_car_filter.dart';
// import 'package:hino/page/home_detail.dart';
// import 'package:hino/page/home_realtime.dart';
// import 'package:hino/utils/color_custom.dart';
// import 'package:hino/utils/responsive.dart';
// import 'package:hino/utils/utils.dart';
// import 'package:hino/widget/CustomPicker.dart';
// import 'package:hino/widget/back_ios.dart';
// import 'package:hino/widget/calendar_custom.dart';
// import 'package:hino/widget/dateview_custom.dart';
// import 'package:hino/widget/dateview_range_custom.dart';
// import 'package:hino/widget/dateview_range_custom2.dart';
// import 'package:hino/widget/dropbox_general_search.dart';
// import 'package:hino/widget/dropbox_general_search_trip.dart';
// import 'package:hino/widget/fancy_fab.dart';
// import 'package:intl/intl.dart';

// import 'dart:ui' as ui;

// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// import 'home_car_sort.dart';

// class HomeBackupEventPage extends StatefulWidget {
//   const HomeBackupEventPage({Key? key}) : super(key: key);
//   @override
//   _PageState createState() => _PageState();
// }

// class _PageState extends State<HomeBackupEventPage> {
//   List<Dropdown> listDropdown = [];

//   @override
//   void initState() {
//     timeStart = dateTime.subtract(Duration(
//         hours: dateTime.hour,
//         minutes: dateTime.minute,
//         seconds: dateTime.second,
//         milliseconds: dateTime.millisecond,
//         microseconds: dateTime.microsecond));
//     timeEnd = DateTime.now();
//     timeString = DateFormat('HH:mm').format(timeStart) +
//         " - " +
//         DateFormat('HH:mm').format(DateTime.now());
//     textEditingController.text = dateString;
//     if (Api.language == "en") {
//       listDropdown.add(Dropdown("1", LanguageEn().plate_no));
//       listDropdown.add(Dropdown("2", LanguageEn().vehicle_name));
//       listDropdown.add(Dropdown("3", LanguageEn().vin_no));
//     }else{
//       listDropdown.add(Dropdown("1", LanguageVi().plate_no));
//       listDropdown.add(Dropdown("2", LanguageVi().vehicle_name));
//       listDropdown.add(Dropdown("3", LanguageVi().vin_no));
//     }

//     super.initState();
//   }

//   var start = DateTime.now();
//   var to = DateTime.now();
//   var timeStart = DateTime.now().subtract(Duration(hours: 0, minutes: 0));
//   var timeEnd = DateTime.now();
//   DateTime dateTime = DateTime.now();
//   TextEditingController textEditingController = new TextEditingController();
//   TextEditingController timeController = new TextEditingController();

//   refresh() {
//     setState(() {});
//   }

//   var timeString = "00:00 - " + DateFormat('HH:mm').format(DateTime.now());
//   var dateString = DateFormat('dd MMM yy', Api.language).format(DateTime.now());

//   pickTimeStart() async {
//     DatePicker.showPicker(context,
//         showTitleActions: true,
//         // minTime: DateTime(2018, 3, 5),
//         // maxTime: DateTime(2019, 6, 7),
//         pickerModel: CustomPicker(currentTime: timeStart), onChanged: (date) {
//       print('change $date');
//       timeStart = date;
//       var s = DateFormat('HH:mm').format(timeStart);
//       var e = DateFormat('HH:mm').format(timeEnd);
//       timeString = s + " - " + e;
//       setState(() {});
//     }, onConfirm: (date) {
//       print('confirm $date');
//       timeStart = date;
//       var s = DateFormat('HH:mm').format(timeStart);
//       var e = DateFormat('HH:mm').format(timeEnd);
//       timeString = s + " - " + e;
//       setState(() {});
//       pickTimeEnd();
//     });
//   }

//   pickTimeEnd() async {
//     DatePicker.showPicker(
//       context,
//       showTitleActions: true,
//       // minTime: DateTime(2018, 3, 5),
//       // maxTime: DateTime(2019, 6, 7),
//       pickerModel: CustomPicker(currentTime: timeEnd),
//       onChanged: (date) {
//         print('change $date');
//         timeEnd = date;
//         var s = DateFormat('HH:mm').format(timeStart);
//         var e = DateFormat('HH:mm').format(timeEnd);
//         timeString = s + " - " + e;
//         setState(() {});
//       },
//       onConfirm: (date) {
//         print('confirm $date');
//         timeEnd = date;
//         var s = DateFormat('HH:mm').format(timeStart);
//         var e = DateFormat('HH:mm').format(timeEnd);
//         timeString = s + " - " + e;
//         setState(() {});
//       },
//     );
//   }

//   pickDateStart() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Center(
//               child: Container(
//                 color: Colors.white,
//                 // height: 320.0,
//                 width: 300.0,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       Languages.of(context)!.start_date,
//                       style: TextStyle(
//                         color: ColorCustom.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     SfDateRangePicker(
//                       initialDisplayDate: start,
//                       showActionButtons: true,
//                       showNavigationArrow: true,
//                       onCancel: () {
//                         Navigator.pop(context);
//                       },
//                       onSubmit: (p0) {
//                         Navigator.pop(context);
//                         pickDateEnd();
//                       },
//                       onSelectionChanged: (args) {
//                         if (args.value is DateTime) {
//                           final DateTime selectedDate = args.value;
//                           start = selectedDate;
//                           to = selectedDate;
//                           var s = DateFormat('dd MMM yy', "vi")
//                               .format(start);
//                           var e =
//                               DateFormat('dd MMM yy', Api.language).format(to);
//                           if (start.isBefore(to) && !start.isSameDate(to)) {
//                             dateString = s + " - " + e;
//                           } else {
//                             dateString = s;
//                           }

//                           if (start.isSameDate(DateTime.now()) ||
//                               start.isAfter(DateTime.now())) {
//                             timeStart = DateFormat("HH:mm").parse("00:00");
//                             timeEnd = DateTime.now();
//                             var s = DateFormat('HH:mm').format(timeStart);
//                             var e = DateFormat('HH:mm').format(timeEnd);
//                             timeString = s + " - " + e;
//                           } else {
//                             timeStart = DateFormat("HH:mm").parse("00:00");
//                             timeEnd = DateFormat("HH:mm").parse("23:59");
//                             var s = DateFormat('HH:mm').format(timeStart);
//                             var e = DateFormat('HH:mm').format(timeEnd);
//                             timeString = s + " - " + e;
//                           }

//                           textEditingController.text = dateString;
//                           refresh();
//                         }
//                       },
//                       initialSelectedDate: start,
//                       maxDate: DateTime.now(),
//                       minDate: DateTime(2000),
//                       selectionMode: DateRangePickerSelectionMode.single,
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   pickDateEnd() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Center(
//               child: Container(
//                 color: Colors.white,
//                 // height: 320.0,
//                 width: 300.0,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       Languages.of(context)!.end_date,
//                       style: TextStyle(
//                         color: ColorCustom.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     SfDateRangePicker(
//                       initialDisplayDate: start,
//                       showActionButtons: true,
//                       showNavigationArrow: true,
//                       onCancel: () {
//                         Navigator.pop(context);
//                       },
//                       onSubmit: (p0) {
//                         Navigator.pop(context);
//                       },
//                       onSelectionChanged: (args) {
//                         if (args.value is DateTime) {
//                           to = args.value;
//                           var s = DateFormat('dd MMM yy', Api.language)
//                               .format(start);
//                           var e =
//                               DateFormat('dd MMM yy', Api.language).format(to);
//                           if (start.isBefore(to) && !start.isSameDate(to)) {
//                             dateString = s + " - " + e;
//                           } else {
//                             dateString = s;
//                           }
//                           textEditingController.text = dateString;
//                           setState(() {});
//                         }
//                       },
//                       initialSelectedDate: start,
//                       maxDate: maxTimeEnd(),
//                       minDate: start,
//                       selectionMode: DateRangePickerSelectionMode.single,
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   DateTime maxTimeEnd() {
//     if (start.isSameDate(DateTime.now())) {
//       return DateTime.now();
//     } else {
//       return start.add(Duration(days: 1));
//     }
//   }

//   Vehicle? selectVehicle;

//   submit() {
//     if (selectVehicle == null) {
//       if (dropdown != null) {
//         Utils.showAlertDialog(
//             context, Languages.of(context)!.please_select + dropdown!.name);
//       } else {
//         Utils.showAlertDialog(
//             context,
//             Languages.of(context)!.please_select +
//                 Languages.of(context)!.plate_no);
//       }

//       return;
//     }

//     Navigator.of(context).push(MaterialPageRoute(
//         builder: (context) => HomeBackupEventSearchPage(
//               imei: selectVehicle!.gps!.imei!,
//               start: start,
//               end: to,
//               timeEnd: timeEnd,
//               timeStart: timeStart,
//               license: selectVehicle!.info!.licenseplate!,
//             )));
//   }

//   // String imei = "";
//   Dropdown? dropdown;

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.black,
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: _goToMe,
//       //   label: Text('My location'),
//       //   icon: Icon(Icons.near_me),
//       // ),
//       body: SafeArea(
//         child: Container(
//           color: Colors.white,
//           child: Column(
//             children: [
//               BackIOS(),
//               Expanded(
//                 child: Container(
//                   padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.restore,
//                             size: 30,
//                             color: Colors.grey,
//                           ),
//                           Text(
//                             Languages.of(context)!.event_log,
//                             style: TextStyle(
//                               color: ColorCustom.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             Languages.of(context)!.search_by,
//                             style: TextStyle(
//                               color: ColorCustom.black,
//                               fontSize: 16,
//                             ),
//                             textAlign: TextAlign.start,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 10),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: ColorCustom.greyBG2),
//                               color: ColorCustom.greyBG2,
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(15.0),
//                               ),
//                             ),
//                             child: DropboxGeneralSearchViewTrip(
//                               name: "",
//                               onChanged: (value) {
//                                 dropdown = value;
//                                 refresh();
//                               },
//                               listData: listDropdown,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             dropdown != null
//                                 ? dropdown!.name
//                                 : Languages.of(context)!.plate_no,
//                             style: TextStyle(
//                               color: ColorCustom.black,
//                               fontSize: 16,
//                             ),
//                             textAlign: TextAlign.start,
//                           ),
//                           Container(
//                             margin: EdgeInsets.only(top: 10),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: ColorCustom.greyBG2),
//                               color: ColorCustom.greyBG2,
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(15.0),
//                               ),
//                             ),
//                             child: DropboxGeneralSearchView(
//                               name: dropdown != null
//                                   ? Languages.of(context)!.please_select +
//                                       dropdown!.name
//                                   : Languages.of(context)!.please_select +
//                                       Languages.of(context)!.plate_no,
//                               onChanged: (value) {
//                                 // imei = value.gps!.imei!;
//                                 // license = value.info!.licenseplate!;
//                                 selectVehicle = value;
//                               },
//                               listData: listVehicle,
//                               dropdownID: dropdown?.id,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(
//                         height: 10,
//                       ),
//                       // Text(
//                       //   'ช่วงวัน',
//                       //   style: TextStyle(
//                       //     color: ColorCustom.black,
//                       //     fontSize: 16,
//                       //   ),
//                       //   textAlign: TextAlign.start,
//                       // ),
//                       // GroupButton(
//                       //   unselectedColor: ColorCustom.greyBG2,
//                       //   isRadio: true,
//                       //   spacing: 10,
//                       //   onSelected: (index, isSelected) {
//                       //     if (index == 2) {
//                       //       dateTime.subtract(Duration(days: 7));
//                       //     } else if (index == 3) {
//                       //       dateTime.subtract(Duration(days: 30));
//                       //     } else {
//                       //       dateTime.subtract(Duration(days: index));
//                       //     }
//                       //      to = DateFormat('dd/MM/yyyy').format(dateTime);
//                       //
//                       //     textEditingController.text =
//                       //         start + " - " + to;
//                       //     setState(() {});
//                       //   },
//                       //   buttons: ["วันนี้", "เมื่อวาน", "7 วัน", "30 วัน"],
//                       //   borderRadius: BorderRadius.circular(20.0),
//                       // ),
//                       // SizedBox(
//                       //   height: 10,
//                       // ),
//                       Text(
//                         Languages.of(context)!.date_range,
//                         style: TextStyle(
//                           color: ColorCustom.black,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.start,
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(top: 10),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: ColorCustom.greyBG2),
//                           color: ColorCustom.greyBG2,
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(15.0),
//                           ),
//                         ),
//                         child: InkWell(
//                           onTap: () {
//                             pickDateStart();
//                           },
//                           child: Row(
//                             children: [
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 20,
//                                 color: Colors.black,
//                               ),
//                               Expanded(
//                                 child: TextField(
//                                   controller: textEditingController,
//                                   enabled: false,
//                                   style: TextStyle(color: Colors.black),
//                                   decoration: InputDecoration(
//                                     disabledBorder: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.keyboard_arrow_down,
//                                 color: Colors.grey,
//                                 size: 25,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                             ],
//                           ),
//                         ),
//                         // child: DateViewRangeCustom2View(
//                         //   controller: textEditingController,
//                         //   limit: 1,
//                         //   dateSelect: start,
//                         //   returnDate: (value) {
//                         //     // start = DateFormat('yyyy-MM-dd')
//                         //     //     .format(value.start);
//                         //     // to = DateFormat('yyyy-MM-dd')
//                         //     //     .format(value.end);
//                         //     if (value.start.isSameDate(DateTime.now()) ||
//                         //         value.start.isAfter(DateTime.now())) {
//                         //       timeStart =
//                         //           DateFormat("HH:mm").parse("00:00");
//                         //       timeEnd = DateTime.now();
//                         //       var s = DateFormat('HH:mm').format(timeStart);
//                         //       var e = DateFormat('HH:mm').format(timeEnd);
//                         //       timeString = s + " - " + e;
//                         //     } else {
//                         //       timeStart =
//                         //           DateFormat("HH:mm").parse("00:00");
//                         //       timeEnd = DateFormat("HH:mm").parse("23:59");
//                         //       var s = DateFormat('HH:mm').format(timeStart);
//                         //       var e = DateFormat('HH:mm').format(timeEnd);
//                         //       timeString = s + " - " + e;
//                         //     }
//                         //     setState(() {});
//                         //     start = value.start;
//                         //     to = value.end;
//                         //   },
//                         // ),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         Languages.of(context)!.time_range,
//                         style: TextStyle(
//                           color: ColorCustom.black,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.start,
//                       ),
//                       Container(
//                         margin: EdgeInsets.only(top: 10),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: ColorCustom.greyBG2),
//                           color: ColorCustom.greyBG2,
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(15.0),
//                           ),
//                         ),
//                         child: InkWell(
//                           onTap: () {
//                             pickTimeStart();
//                           },
//                           child: Row(
//                             children: [
//                               SizedBox(
//                                 width: 10,
//                               ),
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 20,
//                                 color: Colors.black,
//                               ),
//                               Expanded(
//                                 // child: TimeViewCustom(
//                                 //   returnDate: (value) {
//                                 //     DateTime formatedDate = DateFormat('HH:mm').parseLoose(value.startTime.hour.toString()+":"+value.startTime.minute.toString());
//                                 //     DateTime formatedDate2 = DateFormat('HH:mm').parseLoose(value.endTime.hour.toString()+":"+value.endTime.minute.toString());
//                                 //     // timeStart = value.startTime.hour.toString() +
//                                 //     //     ":" +
//                                 //     //     value.startTime.minute.toString();
//                                 //     // timeEnd = value.endTime.hour.toString() +
//                                 //     //     ":" +
//                                 //     //     value.endTime.minute.toString();
//                                 //
//                                 //     timeStart = formatedDate;
//                                 //     timeEnd = formatedDate2;
//                                 //   },
//                                 //   controller: timeController,
//                                 // ),
//                                 child: Container(
//                                   child: Text(
//                                     timeString,
//                                     style: TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   padding: EdgeInsets.all(15),
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.keyboard_arrow_down,
//                                 color: Colors.grey,
//                                 size: 25,
//                               ),
//                               SizedBox(
//                                 width: 10,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Expanded(child: Container()),
//                       Container(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: ColorCustom.blue,
//                             padding: EdgeInsets.all(15),
//                             shape: RoundedRectangleBorder(
//                               borderRadius:
//                                   BorderRadius.circular(10), // <-- Radius
//                             ),
//                           ),
//                           onPressed: () {
//                             submit();
//                           },
//                           child: Text(
//                             Languages.of(context)!.search,
//                             style: TextStyle(color: Colors.white, fontSize: 18),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// extension DateOnlyCompare on DateTime {
//   bool isSameDate(DateTime other) {
//     return year == other.year && month == other.month && day == other.day;
//   }
// }

// Đã tối ưu UI, chia component và chỉnh sửa dễ mở rộng nhưng giữ nguyên logic
// Bạn có thể tách widget thành file riêng nếu cần (ví dụ: SearchDropdownWidget, DateTimePickerWidget...)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/dropdown.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_backup_event_search.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:hino/widget/dropbox_general_search.dart';
import 'package:hino/widget/dropbox_general_search_trip.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class HomeBackupEventPage extends StatefulWidget {
  const HomeBackupEventPage({Key? key}) : super(key: key);

  @override
  _HomeBackupEventPageState createState() => _HomeBackupEventPageState();
}

class _HomeBackupEventPageState extends State<HomeBackupEventPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  Dropdown? dropdown;
  Vehicle? selectVehicle =
      listVehicle.isNotEmpty ? listVehicle.firstOrNull : null;
  DateTime start = DateTime.now();
  DateTime to = DateTime.now();
  DateTime timeStart = DateTime.now();
  DateTime timeEnd = DateTime.now();
  String timeString = "";
  String dateString = "";
  List<Dropdown> listDropdown = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    //_initDropdown();
    _initDateTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initDropdown();
      _isInitialized = true;
    }
  }

  void _initDropdown() {
    listDropdown.clear();
    final lang = Languages.of(context)!;
    listDropdown.addAll([
      Dropdown("1", lang.plate_no),
      Dropdown("2", lang.vehicle_name),
      Dropdown("3", lang.vin_no),
    ]);
  }

  void _initDateTime() {
    final now = DateTime.now();
    timeStart = DateTime(now.year, now.month, now.day);
    timeEnd = now;
    timeString = "00:00 - ${DateFormat('HH:mm').format(timeEnd)}";
    dateString = DateFormat('dd MMM yy', Api.language).format(now);
    _dateController.text = dateString;
  }

  void _refreshUI() => setState(() {});

  void _pickDateStart() async {
    await showDialog(
      context: context,
      builder: (context) => _buildDateDialog(
        title: Languages.of(context)!.start_date,
        onChanged: (selectedDate) {
          start = selectedDate;
          to = selectedDate;
          _updateDateRange();
          _refreshUI();
        },
        onSubmit: () {
          Navigator.pop(context);
          _pickDateEnd();
        },
        initialSelectedDate: start,
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
      ),
    );
  }

  void _pickDateEnd() async {
    await showDialog(
      context: context,
      builder: (context) => _buildDateDialog(
        title: Languages.of(context)!.end_date,
        onChanged: (selectedDate) {
          to = selectedDate;
          _updateDateRange();
          _refreshUI();
        },
        onSubmit: () => Navigator.pop(context),
        initialSelectedDate: to,
        minDate: start,
        maxDate: _getMaxTimeEnd(),
      ),
    );
  }

  Widget _buildDateDialog({
    required String title,
    required ValueChanged<DateTime> onChanged,
    required VoidCallback onSubmit,
    required DateTime initialSelectedDate,
    required DateTime minDate,
    required DateTime maxDate,
  }) {
    return Center(
      child: Container(
        width: 300,
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            SfDateRangePicker(
              initialSelectedDate: initialSelectedDate,
              minDate: minDate,
              maxDate: maxDate,
              onSelectionChanged: (args) {
                if (args.value is DateTime) onChanged(args.value);
              },
              onSubmit: (_) => onSubmit(),
              onCancel: () => Navigator.pop(context),
              showActionButtons: true,
              showNavigationArrow: true,
              selectionMode: DateRangePickerSelectionMode.single,
            ),
          ],
        ),
      ),
    );
  }

  void _updateDateRange() {
    final lang = Api.language;
    final s = DateFormat('dd MMM yy', lang).format(start);
    final e = DateFormat('dd MMM yy', lang).format(to);
    dateString = start.isBefore(to) ? "$s - $e" : s;
    _dateController.text = dateString;

    if (start.isSameDate(DateTime.now()) || start.isAfter(DateTime.now())) {
      timeStart = DateFormat("HH:mm").parse("00:00");
      timeEnd = DateTime.now();
    } else {
      timeStart = DateFormat("HH:mm").parse("00:00");
      timeEnd = DateFormat("HH:mm").parse("23:59");
    }
    timeString =
        "${DateFormat('HH:mm').format(timeStart)} - ${DateFormat('HH:mm').format(timeEnd)}";
  }

  DateTime _getMaxTimeEnd() => start.isSameDate(DateTime.now())
      ? DateTime.now()
      : start.add(const Duration(days: 1));

  void _pickTimeStart() {
    DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      currentTime: timeStart,
      onConfirm: (date) {
        timeStart = date;
        _refreshTimeRange();
        _pickTimeEnd();
      },
    );
  }

  void _pickTimeEnd() {
    DatePicker.showTimePicker(
      context,
      showTitleActions: true,
      currentTime: timeEnd,
      onConfirm: (date) {
        timeEnd = date;
        _refreshTimeRange();
      },
    );
  }

  void _refreshTimeRange() {
    final s = DateFormat('HH:mm').format(timeStart);
    final e = DateFormat('HH:mm').format(timeEnd);
    setState(() {
      timeString = "$s - $e";
    });
  }

  void _submit() {
    if (selectVehicle == null) {
      final msg = Languages.of(context)!.please_select +
          (dropdown?.name ?? Languages.of(context)!.plate_no);
      Utils.showAlertDialog(context, msg);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HomeBackupEventSearchPage(
          imei: selectVehicle!.gps!.imei!,
          start: start,
          end: to,
          timeEnd: timeEnd,
          timeStart: timeStart,
          license: selectVehicle!.info!.licenseplate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BackIOS(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleRow(lang),
                    const SizedBox(height: 10),
                    _buildDropdownSearch(lang),
                    const SizedBox(height: 10),
                    _buildVehicleSearch(lang),
                    const SizedBox(height: 10),
                    _buildDatePicker(lang),
                    const SizedBox(height: 10),
                    _buildTimePicker(lang),
                    const Spacer(),
                    _buildSearchButton(lang),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(Languages lang) => Row(
        children: [
          const Icon(Icons.restore, size: 26, color: Colors.black87),
          const SizedBox(width: 8),
          Text(
            lang.event_log,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      );

  Widget _buildDropdownSearch(Languages lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.search_by,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropboxGeneralSearchViewTrip(
              name: dropdown?.name ?? "",
              onChanged: (value) {
                dropdown = value;
                _refreshUI();
              },
              listData: listDropdown,
            ),
          ),
        ],
      );

  Widget _buildVehicleSearch(Languages lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dropdown?.name ?? lang.plate_no,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: DropboxGeneralSearchView(
              name: "${lang.please_select} ${dropdown?.name ?? lang.plate_no}",
              onChanged: (value) {
                selectVehicle = value;
                _refreshUI();
              },
              listData: listVehicle,
              //dropdownID: dropdown?.id,
            ),
          ),
        ],
      );

  Widget _buildDatePicker(Languages lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.date_range,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDateStart,
            child: _buildInputLikeRow(_dateController.text),
          ),
        ],
      );

  Widget _buildTimePicker(Languages lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.time_range,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickTimeStart,
            child: _buildInputLikeRow(timeString),
          ),
        ],
      );

  Widget _buildInputLikeRow(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ),
      );

  Widget _buildSearchButton(Languages lang) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorCustom.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            lang.search,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

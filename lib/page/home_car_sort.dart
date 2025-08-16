// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:group_button/group_button.dart';
// import 'package:hino/localization/language/languages.dart';
// import 'package:hino/model/truck.dart';
// import 'package:hino/page/home_detail.dart';
// import 'package:hino/utils/color_custom.dart';
// import 'package:hino/utils/responsive.dart';
// import 'package:hino/widget/fancy_fab.dart';

// import 'dart:ui' as ui;

// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';


// int select = 2;

// class HomeCarSortPage extends StatefulWidget {
//   const HomeCarSortPage(
//       {Key? key,
//       this.title,
//       required this.select})
//       : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//   final ValueChanged<int> select;
//   final String? title;

//   @override
//   _PageState createState() => _PageState();
// }

// class _PageState extends State<HomeCarSortPage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Material(
//         child: SafeArea(
//       top: false,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 10,
//           ),
//           Container(
//             child: Text(Languages.of(context)!.sort_by,
//               style: TextStyle(
//                 color: ColorCustom.black,
//                 fontSize: 20,
//               ),
//               textAlign: TextAlign.start,
//             ),
//             margin: EdgeInsets.only(left: 10),
//           ),
//           InkWell(
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Expanded(
//                   child: Text(
//                     widget.title != null ? widget.title! : Languages.of(context)!.unit_ascending,
//                     style: TextStyle(
//                       color: ColorCustom.black,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 Radio(
//                   value: 0,
//                   onChanged: (va) {
//                     // isSwitched = va;
//                     setState(() {
//                       select = va as int;
//                     });
//                     widget.select.call(select);
//                   },
//                   groupValue: select,
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//               ],
//             ),
//             onTap: () {
//               setState(() {
//                 select = 0;
//               });
//               widget.select.call(select);
//             },
//           ),
//           InkWell(
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Expanded(
//                   child: Text(Languages.of(context)!.unit_descending,
//                     style: TextStyle(
//                       color: ColorCustom.black,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 Radio(
//                   value: 1,
//                   onChanged: (va) {
//                     // isSwitched = va;
//                     setState(() {
//                       select = va as int;
//                     });
//                     widget.select.call(select);
//                   },
//                   groupValue: select,
//                 ),
//                 // Switch(
//                 //   value: isSwitched2,
//                 //   onChanged: (value) {
//                 //     setState(() {
//                 //       isSwitched2 = value;
//                 //       widget.alphabet.call(value);
//                 //     });
//                 //   },
//                 // ),
//                 SizedBox(
//                   width: 10,
//                 ),
//               ],
//             ),
//             onTap: () {
//               setState(() {
//                 select = 1;
//               });
//               widget.select.call(select);
//             },
//           ),
//           InkWell(
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Expanded(
//                   child: Text(
//                     widget.title != null ? widget.title! : Languages.of(context)!.alphabet_a_z,
//                     style: TextStyle(
//                       color: ColorCustom.black,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 Radio(
//                   value: 2,
//                   onChanged: (va) {
//                     // isSwitched = va;
//                     setState(() {
//                       select = va as int;
//                     });
//                     widget.select.call(select);
//                   },
//                   groupValue: select,
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//               ],
//             ),
//             onTap: () {
//               setState(() {
//                 select = 2;
//               });
//               widget.select.call(select);
//             },
//           ),
//           InkWell(
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Expanded(
//                   child: Text(
//                     widget.title != null ? widget.title! : Languages.of(context)!.alphabet_z_a,
//                     style: TextStyle(
//                       color: ColorCustom.black,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//                 Radio(
//                   value: 3,
//                   onChanged: (va) {
//                     // isSwitched = va;
//                     setState(() {
//                       select = va as int;
//                     });
//                     widget.select.call(select);
//                   },
//                   groupValue: select,
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//               ],
//             ),
//             onTap: () {
//               setState(() {
//                 select = 3;
//               });
//               widget.select.call(select);
//             },
//           ),
//         ],
//       ),
//     ));
//   }
// }

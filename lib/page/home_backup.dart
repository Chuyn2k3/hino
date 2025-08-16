// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hino/localization/language/languages.dart';
// import 'package:hino/model/truck.dart';
// import 'package:hino/page/home_backup_event.dart';
// import 'package:hino/page/home_backup_snapshot.dart';
// import 'package:hino/page/home_car_filter.dart';
// import 'package:hino/page/home_detail.dart';
// import 'package:hino/utils/color_custom.dart';
// import 'package:hino/utils/responsive.dart';
// import 'package:hino/widget/fancy_fab.dart';

// import 'dart:ui' as ui;

// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// import 'home_backup_playback.dart';
// import 'home_car_sort.dart';

// class HomeBackupPage extends StatefulWidget {
//   const HomeBackupPage({Key? key}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   @override
//   _PageState createState() => _PageState();
// }

// class _PageState extends State<HomeBackupPage> {
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
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: _goToMe,
//       //   label: Text('My location'),
//       //   icon: Icon(Icons.near_me),
//       // ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//                 padding: EdgeInsets.all(10),
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => HomeBackupEventPage()));
//                   },
//                   child: Padding(
//                     child: Text(Languages.of(context)!.tracking_history,
//                       style: TextStyle(
//                         color: ColorCustom.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                     padding: EdgeInsets.all(10),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(width: 1.0, color: Colors.grey),
//                     shape: StadiumBorder(),
//                   ),
//                 )),
//             Container(
//                 padding: EdgeInsets.all(10),
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: (){
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (context) => HomeBackupPlaybackPage()));
//                   },
//                   child: Padding(
//                     child: Text(Languages.of(context)!.cctv_playback,
//                       style: TextStyle(
//                         color: ColorCustom.black,
//                         fontSize: 16,
//                       ),
//                     ),
//                     padding: EdgeInsets.all(10),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(width: 1.0, color: Colors.grey),
//                     backgroundColor: ColorCustom.white,
//                     shape: StadiumBorder(),
//                   ),
//                 )),
//             // Container(
//             //     margin: EdgeInsets.all(10),
//             //     width: double.infinity,
//             //     child: OutlinedButton(
//             //       onPressed: (){
//             //         Navigator.of(context).push(MaterialPageRoute(
//             //             builder: (context) => HomeBackupSnapshotPage()));
//             //       },
//             //       child: Padding(
//             //         child: Text(Languages.of(context)!.camera_playback,
//             //           style: TextStyle(
//             //             color: ColorCustom.black,
//             //             fontSize: 16,
//             //           ),
//             //         ),
//             //         padding: EdgeInsets.all(10),
//             //       ),
//             //       style: OutlinedButton.styleFrom(
//             //         side: BorderSide(width: 1.0, color: Colors.grey),
//             //         backgroundColor: ColorCustom.white,
//             //         shape: StadiumBorder(),
//             //       ),
//             //
//             //     )),
//           ],
//         ),
//       ),
//     );
//   }
// }
/////////////////////////

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/page/home_backup_event.dart';
import 'package:hino/page/home_backup_playback.dart';
import 'package:hino/utils/color_custom.dart';

class HomeBackupPage extends StatefulWidget {
  const HomeBackupPage({Key? key}) : super(key: key);

  @override
  _HomeBackupPageState createState() => _HomeBackupPageState();
}

class _HomeBackupPageState extends State<HomeBackupPage> {
  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: const BorderSide(width: 1.0, color: Colors.grey),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );

    final textStyle = GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: ColorCustom.black,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                Languages.of(context)!.tracking_history,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorCustom.black,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const HomeBackupEventPage()));
                },
                style: buttonStyle,
                child: Text(
                  Languages.of(context)!.tracking_history,
                  style: textStyle,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const HomeBackupPlaybackPage()));
                },
                style: buttonStyle,
                child: Text(
                  Languages.of(context)!.cctv_playback,
                  style: textStyle,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "© Onelink Technology Co., Ltd.",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

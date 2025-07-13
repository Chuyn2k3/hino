import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/noti.dart';
import 'package:hino/model/truck.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/model/vehicle_detail.dart';
import 'package:hino/page/home_realtime.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/utils/timeago.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:hino/widget/fancy_fab.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

import 'home_noti_event.dart';

class HomeNotiMapDetailPage extends StatefulWidget {
  const HomeNotiMapDetailPage({Key? key, required this.noti}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final Noti noti;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeNotiMapDetailPage> {

  // Vehicle? vehicle;

  @override
  void initState() {
    // for(Vehicle v in listVehicle){
    //   if(widget.noti.vehicle){
    //
    //   }
    // }
    super.initState();
  }

  refresh() {
    setState(() {});
  }

  dialPhone(String phone) {
    if (phone.isNotEmpty) {
      launch("tel://" + phone);
    }
  }

  showDetail(String name) {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeNotiEventPage(
        name: name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToMe,
      //   label: Text('My location'),
      //   icon: Icon(Icons.near_me),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackIOS(),
              Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Utils.eventIcon(widget.noti,context),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.noti.vehicle_name!,
                            style: TextStyle(
                                color: ColorCustom.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.noti.vehicle!.info!.licenseprov!,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            widget.noti.speed.toString(),
                            style: TextStyle(
                                color: ColorCustom.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(Languages.of(context)!.km_h,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              )),
                        ],
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: ColorCustom.greyBG2),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorCustom.greyBG2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Icon(
                        //   Icons.account_circle,
                        //   size: 50,
                        //   color: Colors.grey,
                        // ),
                        SvgPicture.asset(
                          "assets/images/icon_profile.svg",
                          color: Colors.grey,
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(Languages.of(context)!.driver_title,
                          style: TextStyle(
                            color: ColorCustom.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(child: Container()),
                        InkWell(
                          onTap: () {
                            showDetail(widget.noti.driver_name!);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorCustom.blue,
                                borderRadius: BorderRadius.circular(100),
                                border:
                                    Border.all(width: 8, color: ColorCustom.blue)),
                            child: Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: () {
                            dialPhone(widget.noti.vehicle!.info!.box_phone!);
                          },
                          child: SvgPicture.asset(
                            widget.noti.vehicle!.info!.box_phone!.isEmpty
                                ? "assets/images/Fix Icon Hino7_1.svg"
                                : "assets/images/Fix Icon Hino7.svg",
                            // color: Colors.grey,
                            width: 40,
                            height: 40,
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                                color: widget.noti.vehicle!.driverCard!
                                    .driver_phone!.isEmpty?Colors
                                    .grey:ColorCustom.primaryColor,
                                borderRadius: BorderRadius.circular(100),
                                border:
                                    Border.all(width: 8, color: Colors.grey)),
                            child: Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            dialPhone(widget.noti.vehicle!.driverCard!
                                .driver_phone!);
                          },
                        ),
                        SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Languages.of(context)!.driver,
                                style: TextStyle(
                                  color: ColorCustom.black,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.noti.driver_name!,
                                style: TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          "assets/images/profile_empty.png",
                          width: 100,
                          height: 100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorCustom.greyBG2),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/place.png",
                          height: 40,
                          width: 40,
                        ),
                        Text(Languages.of(context)!.noti_location_title,
                          style: TextStyle(
                            color: ColorCustom.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Languages.of(context)!.noti_date,
                          style: TextStyle(
                            color: ColorCustom.black,
                            fontSize: 16,
                          ),
                        ),
                        // Text(Utils.convertDateToBase(widget.noti.gpsdate!),
                        //   style: TextStyle(
                        //     color: ColorCustom.black,
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //   ),
                        // ),
                        Text(
                          widget.noti.display_gpsdate!,
                          style: TextStyle(
                            color: ColorCustom.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(Languages.of(context)!.noti_location,
                          style: TextStyle(
                            color: ColorCustom.black,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.noti.location!,
                          style: TextStyle(
                            color: ColorCustom.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

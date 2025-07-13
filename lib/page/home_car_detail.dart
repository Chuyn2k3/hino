import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/member.dart';
import 'package:hino/model/member_group.dart';
import 'package:hino/model/truck.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_car_filter.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/page/home_realtime.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:hino/widget/fancy_fab.dart';

import 'dart:ui' as ui;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/src/provider.dart';

import 'home_car_sort.dart';

class HomeCarDetailPage extends StatefulWidget {
  const HomeCarDetailPage({Key? key, required this.group}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final MemberGroup group;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeCarDetailPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    listSearchDetail.addAll(widget.group.vehicle);
    super.initState();
  }

  refresh() {
    setState(() {});
  }

  List<Vehicle> listSearchDetail = [];

  searchDetail(String value, MemberGroup group) {
    listSearchDetail.clear();
    if (value.isEmpty) {
      listSearchDetail.addAll(group.vehicle);
    } else {
      for (Vehicle v in group.vehicle) {
        if (v.info!.vin_no!.contains(value)) {
          listSearchDetail.add(v);
        }
        if (v.info!.licenseplate!.contains(value)) {
          listSearchDetail.add(v);
        }
        if (v.info!.licenseprov!.contains(value)) {
          listSearchDetail.add(v);
        }
        if (v.info!.vehicle_name!.contains(value)) {
          listSearchDetail.add(v);
        }
      }
      List<Vehicle> result =
          LinkedHashSet<Vehicle>.from(listSearchDetail).toList();
      listSearchDetail.clear();
      listSearchDetail.addAll(result);
    }

    refresh();
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
        child: Column(
          children: [
            BackIOS(),
            Container(
              margin: EdgeInsets.all(10),
              child: TextField(
                onChanged: (value) {
                  searchDetail(value, widget.group);
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  fillColor: ColorCustom.greyBG2,
                  prefixIcon: Icon(Icons.search),
                  hintText: Languages.of(context)!.search,
                  hintStyle: TextStyle(fontSize: 16),
                  // fillColor: colorSearchBg,
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    widget.group.name!,
                    style: TextStyle(
                        color: ColorCustom.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                  decoration: BoxDecoration(
                    color: ColorCustom.blueLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    listSearchDetail.length.toString() +
                        ' ' +
                        Languages.of(context)!.unit,
                    style: TextStyle(
                      color: ColorCustom.blue,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              primary: false,
              itemCount: listSearchDetail.length,
              itemBuilder: (BuildContext context, int index) {
                // Member m = group.members[index];
                Vehicle v = listSearchDetail[index];

                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context, MaterialPageRoute(builder: (_) => MotorbikePage()));
                    context.read<PageProvider>().selectVehicle(v);
                    // selectVehicle = v;
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('/root'));
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: ColorCustom.greyBG2),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Utils.statusCarImage(v.gps!.io_name!, v.gps!.speed),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.info!.vehicle_name != null
                                    ? v.info!.vehicle_name!
                                    : "",
                                style: TextStyle(
                                    color: ColorCustom.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(v.info!.licenseprov!,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Text(
                                v.gps!.speed.toStringAsFixed(0),
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
                              shape: BoxShape.circle,
                              color: ColorCustom.greyBG2),
                        ),
                        // OutlinedButton(
                        //   onPressed: () {},
                        //   child:  Column(
                        //     children: [
                        //       Text(
                        //         v.gps!.speed.toStringAsFixed(0),
                        //         style: TextStyle(
                        //             color: ColorCustom.black,
                        //             fontSize: 16,
                        //             fontWeight: FontWeight.bold),
                        //       ),
                        //       Text('กม/ชม',
                        //           style: TextStyle(
                        //             color: Colors.grey,
                        //             fontSize: 12,
                        //           )),
                        //     ],
                        //   ),
                        //   style: OutlinedButton.styleFrom(
                        //     side: BorderSide(width: 1.0, color: Colors.grey),
                        //     shape: CircleBorder(),
                        //     padding: EdgeInsets.all(5),
                        //   ),
                        // ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

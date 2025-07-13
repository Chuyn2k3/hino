import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:group_button/group_button.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/dropdown.dart';
import 'package:hino/model/event_group.dart';
import 'package:hino/model/history.dart';
import 'package:hino/model/member.dart';
import 'package:hino/model/trip.dart';
import 'package:hino/model/truck.dart';
import 'package:hino/page/home_backup_event_search_map.dart';
import 'package:hino/page/home_backup_event_search_video.dart';
import 'package:hino/page/home_car_filter.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/utils/ScreenArguments.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:hino/widget/dropbox_general_search.dart';
import 'package:hino/widget/fancy_fab.dart';
import 'package:intl/intl.dart';

import 'dart:ui' as ui;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_car_sort.dart';

class HomePlaybackEventSearchPage extends StatefulWidget {
  const HomePlaybackEventSearchPage({Key? key, required this.imei})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String imei;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomePlaybackEventSearchPage> {
  @override
  void initState() {
    getData(context);
    super.initState();
  }

  List<PlaybackHistory> listHistory = [];

  getData(BuildContext context) {
    String monthyear = DateTime.now().month < 10
        ? "0${DateTime.now().month}${DateTime.now().year}"
        : DateTime.now().month.toString() + DateTime.now().year.toString();
    Api.get(
            context,
            "${Api.cctv_vehicle}imei=${widget.imei}&limit=10&page=1&monthyear=$monthyear")
        .then((value) => {
              if (value != null)
                {
                  if (value.containsKey("result"))
                    {
                      listHistory = List.from(value['result']['snapshot'])
                          .map((a) => PlaybackHistory.fromJson(a))
                          .toList(),
                      isLoad = false,
                      refresh()
                    }
                  else
                    {
                      isLoad = false,
                      refresh(),
                      Utils.showAlertDialog(
                          context, "Không tìm thấy thông tin"),
                    }
                }
              else
                {}
            });
  }

  bool isLoad = true;

  refresh() {
    setState(() {});
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
      backgroundColor: Colors.black,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToMe,
      //   label: Text('My location'),
      //   icon: Icon(Icons.near_me),
      // ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackIOS(),
                    Expanded(
                      child: ListView(
                        children: [
                          ...listHistory.map((e) => Row(children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12.0),
                                          bottom: Radius.circular(12.0)),
                                      child: Image.network(
                                          "${Api.BaseUrlBuilding}fleet${e.url}",
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40.0,
                                          cacheWidth: MediaQuery.of(context)
                                                  .size
                                                  .width
                                                  .round() -
                                              40,
                                          cacheHeight: 180,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                            child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ));
                                      }),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 7.0),
                                        width:
                                            MediaQuery.of(context).size.width -
                                                40.0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.take_photo_time,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Kênh ${e.channel_no}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.download,
                                                  color: Colors.black),
                                              onPressed: () {
                                                // Implement download functionality
                                              },
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ]))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              isLoad ? CircularProgressIndicator() : Container()
            ],
          ),
        ),
      ),
    );
  }
}

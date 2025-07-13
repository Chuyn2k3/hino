import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hino/model/cctv_date.dart';
import 'package:hino/model/cctv_vehicle.dart';
import 'package:hino/page/home_backup_snapshot_gallery.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/dropbox_general_search_string.dart';

import '../api/api.dart';
import '../localization/language/languages.dart';
import '../widget/back_ios.dart';
import '../widget/dropbox_general_search_date.dart';
import 'home_backup_snapshot_gallery2.dart';

class HomeBackupSnapshotPage extends StatefulWidget {
  const HomeBackupSnapshotPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeBackupSnapshotPage> {
  var date = "";
  CctvVehicle? vehicleID;
  bool isLoading = false;
  bool isLoading2 = false;

  @override
  void initState() {
    getVehicle(context);

    super.initState();
  }

  refresh() {
    isLoading = false;
    isLoading2 = false;
    setState(() {});
  }

  List<CctvVehicle> list = [];

  getVehicle(BuildContext context) {
    // Api.get(context, Api.cctv_vehicle + Api.profile!.userId.toString())
    setState(() {
      isLoading = true;
    });
    Api.get(context, Api.cctv_vehicle + Api.profile!.userId.toString())
        .then((value) => {
              if (value != null)
                {
                  list = List.from(value['result'])
                      .map((a) => CctvVehicle.fromJson(a))
                      .toList(),
                  refresh()
                }
              else
                {}
            });
  }

  CctvDate? cctvDate;

  getDate(BuildContext context) {
    setState(() {
      isLoading2 = true;
    });
    // https://api-center.onelink-iot.com/prod/fleet/mdvr/playback/calendar/info?user_id=6120&vehicle_id=31503&start=2022-11-01&st=1
    DateTime now = DateTime.now();
    Api.get(
            context,
            Api.cctv_date +
                Api.profile!.userId.toString() +
                "&vehicle_id=" +
                vehicleID!.vehicleId.toString() +
                "&start=" +
                now.year.toString() +
                "-" +
                now.month.toString() +
                "-01&st=" +
                device)
        .then((value) => {
              if (value != null) {initGetDate(value)} else {}
            });
  }

  initGetDate(var value) {
    try {
      cctvDate = CctvDate.fromJson(value["result"]);
    } catch (e) {
      Utils.showAlertDialog(context, value["message"]);
    }

    refresh();
  }

  int select = -1;
  String device = "1";

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
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              BackIOS(),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.restore,
                      size: 30,
                      color: Colors.grey,
                    ),
                    Text(
                      Languages.of(context)!.camera_playback,
                      style: TextStyle(
                        color: ColorCustom.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorCustom.greyBG2),
                          color: ColorCustom.greyBG2,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        child: DropboxGeneralSearchViewString(
                          name: "อุปกรณ์",
                          onChanged: (value) {
                            if (value == "Main Stream") {
                              device = "1";
                            } else {
                              device = "0";
                            }
                          },
                          listData: ["Main Stream", "Sub Stream"],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),*/
                      Text(
                        Languages.of(context)!.vehicle_group,
                        style: TextStyle(
                          color: ColorCustom.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      Expanded(
                        child: Stack(children: [
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorCustom.greyBG2),
                              color: ColorCustom.greyBG2,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: false,
                              itemCount: list.length,
                              itemBuilder: (BuildContext context, int index) {
                                CctvVehicle cctv = list[index];
                                // Vehicle v = widget.listVehicle[index];

                                return InkWell(
                                  onTap: () {
                                    select = index;
                                    vehicleID = cctv;
                                    refresh();
                                    getDate(context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: 20, right: 20, top: 10),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.videocam,
                                          size: 30,
                                          color: cctv.status == 0
                                              ? Colors.grey
                                              : Colors.green,
                                        ),
                                        Expanded(
                                          child: Text(
                                            cctv.licensePlateNo!,
                                            style: TextStyle(
                                              color: ColorCustom.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        select == index
                                            ? Icon(
                                                Icons.check_circle,
                                                size: 30,
                                                color: Colors.green,
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container()
                        ]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        Languages.of(context)!.date_range,
                        style: TextStyle(
                          color: ColorCustom.black,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      isLoading2
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container(
                              margin: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: ColorCustom.greyBG2),
                                color: ColorCustom.greyBG2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                              ),
                              child: DropboxGeneralSearchDateView(
                                name: Languages.of(context)!.noti_date,
                                onChanged: (value) {
                                  date = value.date!;
                                },
                                listData:
                                    cctvDate != null ? cctvDate!.listDate : [],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: ColorCustom.blue,
                    padding: EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // <-- Radius
                    ),
                  ),
                  onPressed: () {
                    if (date.isNotEmpty) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomeBackupSnapshotGalleryPage2(
                                date: date,
                                cctvVehicle: vehicleID!,
                              )));
                    }
                  },
                  child: Text(
                    "ค้นหา",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

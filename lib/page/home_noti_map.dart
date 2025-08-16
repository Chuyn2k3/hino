import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home/home.dart';
import 'package:hino/feature/home_noti/home_noti.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/model/factory.dart';
import 'package:hino/model/factory_latlng.dart';
import 'package:hino/model/member.dart';
import 'package:hino/model/noti.dart';
import 'package:hino/model/truck.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_car.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/page/home_news.dart';
import 'package:hino/page/home_noti_event.dart';
import 'package:hino/page/home_noti_map_detail.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/ScreenArguments.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:hino/widget/fancy_fab.dart';
import 'package:image/image.dart' as IMG;

import 'dart:ui' as ui;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/src/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../main.dart';
import '../model/last_key.dart';
import 'home.dart';
import 'home_noti.dart';
import 'home_realtime.dart';

bool isOpenNoti = false;

class HomeNotiMapPage extends StatefulWidget {
  const HomeNotiMapPage({Key? key, this.noti, this.unix, this.license})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  // static const routeName = '/noti_map';

  final String? unix;
  final String? license;
  final Noti? noti;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeNotiMapPage> {
  Uint8List? markerIcon;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool isPinFactory = false;
  ScreenshotController screenshotController = ScreenshotController();

  Noti? noti;

  @override
  void initState() {
    notiController.stream.listen((event) {
      print(noti_count);
      refresh();
    });
    // final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    if (widget.noti == null) {
      if (listVehicle.isEmpty) {
        getDataVehicle(context);
      } else {
        getData(context, []);
      }
    } else {
      noti = widget.noti;
      initData();
    }
    isOpenNoti = true;
    super.initState();
  }

  @override
  void dispose() {
    isOpenNoti = false;
    super.dispose();
  }

  getDataVehicle(BuildContext context) {
    isLoading = true;
    refresh();
    Api.get(context, Api.realtime).then((value) => {
          if (value != null)
            {
              listVehicle = List.from(value['vehicles'])
                  .map((a) => Vehicle.fromJson(a))
                  .toList(),
              getData(context, []),
            }
          else
            {}
        });
  }

  MarkerId? mID = MarkerId("event_id");

  initData() {
    addPinFactory();
    // _createMarkerImageFromAsset(context);
    Timer(Duration(milliseconds: 500), () {
      screenshotController.capture().then((Uint8List? image) {
        if (image != null) {
          markerIcon = image;
          _markers.add(Marker(
              // onTap: () {
              //   vehicleClick = v;
              //   setState(() {
              //     isShowDetail = true;
              //     isShowDetailFactory = false;
              //     isShowDetailFactoryFull = false;
              //   });
              // },
              // rotation:
              //     v.gps!.course == 0 ? 270 : (v.gps!.course! - 270),
              //   rotation: v.gps!.course!,
              //   anchor: const Offset(0.5, 0.5),
              icon: BitmapDescriptor.fromBytes(image),
              markerId: mID!,
              position: LatLng(noti!.lat!, noti!.lng!),
              infoWindow: InfoWindow(
                  title: Api.language == "vi"
                      ? Utils.eventTitle(noti!.event_id!)
                      : Utils.eventTitleEn(noti!.event_id!))));
          refresh();
        }
      }).catchError((onError) {
        print(onError);
      });
    });
    Timer(Duration(milliseconds: 700), () {
      _controller.future.then((value) => {
            value.showMarkerInfoWindow(mID!),
          });
    });
  }

  List<Noti> listDataNoti = [];
  bool isLoading = false;

  getData(BuildContext context, List<LastEvaluatedKey> listLast) {
    isLoading = true;
    refresh();
    var param;
    if (listLast.isNotEmpty) {
      param = jsonEncode(<dynamic, dynamic>{
        "user_id": Api.profile?.userId,
        "per_page": 500,
        "event_list": [1001, 10000, 10001],
        "LastEvaluatedKey": listLast,
      });
    } else {
      param = jsonEncode(<dynamic, dynamic>{
        "user_id": Api.profile?.userId,
        "per_page": 500,
        "event_list": [1001, 10000, 10001],
      });
    }
    Api.post(context, Api.notify, param).then((value) => {
          if (value != null)
            {
              loadMore(value),
              listDataNoti.addAll(List.from(value['result'])
                  .map((a) => Noti.fromJson(a))
                  .toList()),
            }
          else
            {
              Utils.showAlertDialogEmpty(context),
            },
        });
  }

  loadMore(dynamic value) {
    List<LastEvaluatedKey> listLast = List.from(value['LastEvaluatedKey'])
        .map((a) => LastEvaluatedKey.fromJson(a))
        .toList();
    if (listLast.isNotEmpty) {
      getData(context, listLast);
    } else {
      isLoading = false;
      refresh();
      getNoti();
    }
  }

  getNoti() {
    print("getNoti   " +
        widget.license.toString() +
        "   " +
        widget.unix.toString());
    if (widget.license != null) {
      for (Noti no in listDataNoti) {
        print(widget.license.toString() + "   " + no.license.toString());
        if (no.license == widget.license) {
          noti = no;
          initData();
          refresh();
          break;
        }
      }
    } else if (widget.unix != null) {
      for (Noti no in listDataNoti) {
        if (no.unix == widget.unix) {
          noti = no;
          initData();
          refresh();
          break;
        }
      }
    }

    if (noti == null) {
      Utils.showAlertDialogEmpty(context);
    }
  }

  Future<Uint8List> getBytesFromCanvas(int width, int height) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.red.shade200;
    final Radius radius = Radius.circular(150.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: noti!.speed.toString(),
      style: TextStyle(fontSize: 60.0, color: Colors.red),
    );
    painter.layout();
    painter.paint(
        canvas,
        Offset((width * 0.5) - painter.width * 0.5,
            (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }

  List<Vehicle> listData = [];
  List<Marker> _markers = <Marker>[];
  Set<Marker> markers2 = Set();

  refresh() {
    try {
      setState(() {});
    } catch (e) {}
  }

  Completer<GoogleMapController> _controller = Completer();

  BitmapDescriptor? _markerIcon;
  BitmapDescriptor? _markerIcon2;
  BitmapDescriptor? _markerIcon3;

  // Future _createMarkerImageFromAsset(BuildContext context) async {
  //   getBytesFromCanvas(100, 100).then((value) => {
  //         _markers.add(Marker(
  //             // onTap: () {
  //             //   vehicleClick = v;
  //             //   setState(() {
  //             //     isShowDetail = true;
  //             //     isShowDetailFactory = false;
  //             //     isShowDetailFactoryFull = false;
  //             //   });
  //             // },
  //             // rotation:
  //             //     v.gps!.course == 0 ? 270 : (v.gps!.course! - 270),
  //             //   rotation: v.gps!.course!,
  //             //   anchor: const Offset(0.5, 0.5),
  //             icon: BitmapDescriptor.fromBytes(value),
  //             markerId: MarkerId(noti!.vin_no!),
  //             position: LatLng(noti!.lat!, noti!.lng!),
  //             infoWindow: InfoWindow(title: Utils.eventTitle(noti!.event_id!)))),
  //         refresh()
  //       });
  // }
  showNoti() {
    isDialOpen.value = false;
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeNotiPage(),
    );
  }

  showNews() {
    isDialOpen.value = false;
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeNewsPage(),
    );
  }

  Set<Marker> markersFactory = Set();

  addPinFactory() async {
    markersFactory.clear();
    for (Factory v in listFactory) {
      // listFactoryMarker
      //     .add(new Place(latLng: LatLng(v.lat, v.lng), factory: v));
      markersFactory.add(Marker(
        markerId: MarkerId(v.id.toString()),
        position: LatLng(v.lat, v.lng),
        onTap: () {
          markerFactoryClick(v);
        },
        icon: await getPinFactory(v),
        // icon: await getMarkerIcon(v!.gps!.io_name!, v!.info!.licenseplate!),
      ));
    }
  }

  Map<PolylineId, Polyline> _mapPolylines = {};
  Factory? factoryClick;
  final PolylineId polylineId = PolylineId("polyline_id_factory");

  markerFactoryClick(Factory fac) {
    factoryClick = fac;
    _mapPolylines[polylineId] =
        Polyline(polylineId: polylineId, visible: false);
    circles = null;
    if (fac.coordinateList.isEmpty) {
      print("radius " + fac.radius.toString());
      setRadius(
          LatLng(fac.lat, fac.lng), fac.id.toString(), fac.radius!.toDouble());
    } else {
      print("coordinateList " + fac.coordinateList.toString());
      setLineFactory(fac.coordinateList);
    }
    _controller.future.then((value) => {
          value.animateCamera(CameraUpdate.newLatLngZoom(
              LatLng(factoryClick!.lat, factoryClick!.lng), 16))
        });
    refresh();
    // mapController!.animateCamera(CameraUpdate.newLatLngZoom(
    //     LatLng(factoryClick!.lat, factoryClick!.lng), 16));
  }

  void setLineFactory(List<LatLng> list) {
    // final String polylineIdVal = 'polyline_id_$_polylineIdCounter2';
    // _polylineIdCounter2++;

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.purple,
      width: 2,
      points: list,
    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }

  Set<Circle>? circles;
  Set<Circle> circlesDef = Set.from([
    Circle(
      circleId: CircleId(""),
      center: LatLng(0, 0),
      radius: 0,
    )
  ]);

  setRadius(LatLng latLng, String id, double radiusA) {
    circles = Set.from([
      Circle(
        fillColor: ColorCustom.blue.withOpacity(0.3),
        strokeWidth: 0,
        circleId: CircleId(id),
        center: latLng,
        radius: radiusA,
      )
    ]);
  }

  Future<BitmapDescriptor> getPinFactory(Factory f) async {
    Uint8List bytes = (await NetworkAssetBundle(Uri.parse(f.url!)).load(f.url!))
        .buffer
        .asUint8List();

    return BitmapDescriptor.fromBytes(resizeImage(bytes));
    // for (MarkerIconFactory f in listIconFac) {
    //   print(id.toString() +" "+ f.name.toString());
    //   if (id == f.name) {
    //     return BitmapDescriptor.fromBytes(f.icon!);
    //   }
    // }
    // return _markerIconFactory!;
  }

  Uint8List resizeImage(Uint8List data) {
    Uint8List resizedData = data;
    IMG.Image img = IMG.decodeImage(data)!;
    IMG.Image resized =
        IMG.copyResize(img, width: img.width * 2, height: img.height * 2);
    resizedData = IMG.encodePng(resized) as Uint8List;
    return resizedData;
  }

  Set<Marker> addMarker() {
    if (isPinFactory) {
      return Set<Marker>.of(_markers)..addAll(markersFactory);
    } else {
      return Set<Marker>.of(_markers);
    }
  }

  bool traffic = false;
  MapType mode = MapType.normal;
  LatLng? _lastMapPosition;

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
          child: noti != null
              ? Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          GoogleMap(
                            mapToolbarEnabled: false,
                            trafficEnabled: traffic,
                            mapType: mode,
                            myLocationEnabled: false,
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: false,
                            circles:
                                this.circles != null ? circles! : circlesDef,
                            polylines: Set<Polyline>.of(_mapPolylines.values),
                            initialCameraPosition: CameraPosition(
                              zoom: 12,
                              target: LatLng(noti!.lat!, noti!.lng!),
                            ),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            onCameraMove: (value) {
                              _lastMapPosition = value.target;
                            },
                            markers: addMarker(),
                          ),
                          // Container(
                          //   margin: EdgeInsets.all(10),
                          //   child: FancyFab(
                          //       onPressed: () {}, tooltip: "", icon: Icons.eleven_mp),
                          // ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            margin: EdgeInsets.all(10),
                            child: SpeedDial(
                              activeChild: SvgPicture.asset(
                                "assets/images/Fix Icon Hino19.svg",
                              ),
                              renderOverlay: false,
                              child: SvgPicture.asset(
                                "assets/images/Fix Icon Hino20.svg",
                              ),
                              // icon: Icons.handyman,
                              backgroundColor: Colors.white,
                              foregroundColor: ColorCustom.blue,
                              // activeIcon: Icons.close,
                              activeForegroundColor: Colors.red,
                              closeDialOnPop: true,
                              openCloseDial: isDialOpen,
                              children: [
                                SpeedDialChild(
                                  onTap: () {
                                    isPinFactory
                                        ? isPinFactory = false
                                        : isPinFactory = true;

                                    if (!isPinFactory) {
                                      _mapPolylines[polylineId] = Polyline(
                                          polylineId: polylineId,
                                          visible: false);
                                      circles = null;
                                    } else {
                                      if (factoryClick != null) {
                                        markerFactoryClick(factoryClick!);
                                      }
                                    }

                                    _controller.future.then((value) => {
                                          if (_lastMapPosition == null)
                                            {
                                              value.moveCamera(
                                                  CameraUpdate.newLatLng(LatLng(
                                                      noti!.lat!, noti!.lng!)))
                                            }
                                          else
                                            {
                                              value.moveCamera(
                                                  CameraUpdate.newLatLng(
                                                      _lastMapPosition!))
                                            }
                                        });

                                    refresh();
                                  },
                                  child: SvgPicture.asset(
                                    "assets/images/Fix Icon Hino26.svg",
                                    color: isPinFactory
                                        ? ColorCustom.blue
                                        : Colors.grey,
                                  ),
                                ),
                                SpeedDialChild(
                                  onTap: () {
                                    if (mode == MapType.normal) {
                                      mode = MapType.satellite;
                                    } else if (mode == MapType.satellite) {
                                      mode = MapType.terrain;
                                    } else {
                                      mode = MapType.normal;
                                    }
                                    refresh();
                                  },
                                  child: SvgPicture.asset(
                                    "assets/images/Fix Icon Hino27.svg",
                                    color: mode == MapType.satellite ||
                                            mode == MapType.terrain
                                        ? ColorCustom.blue
                                        : Colors.grey,
                                  ),
                                ),
                                SpeedDialChild(
                                  onTap: () {
                                    if (traffic) {
                                      traffic = false;
                                    } else {
                                      traffic = true;
                                    }
                                    refresh();
                                  },
                                  child: SvgPicture.asset(
                                    "assets/images/Fix Icon Hino12.svg",
                                    color: traffic
                                        ? ColorCustom.blue
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            alignment: Alignment.bottomRight,
                            margin: EdgeInsets.all(10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (noti!.vehicle != null) {
                                      context
                                          .read<PageProvider>()
                                          .selectVehicle(noti!.vehicle);
                                      // selectVehicle = v;
                                      Navigator.of(context).popUntil(
                                          ModalRoute.withName('/root'));
                                      // Navigator.of(context).popUntil((route) => route.isFirst);
                                    }
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    color: ColorCustom.blue,
                                    size: 30,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: CircleBorder(),
                                    padding: EdgeInsets.all(13),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FloatingActionButton(
                                      onPressed: () {
                                        showNoti();
                                      },
                                      child: noti_count > 0
                                          ? SvgPicture.asset(
                                              "assets/images/Fix Icon Hino21.svg",
                                            )
                                          : SvgPicture.asset(
                                              "assets/images/Fix Icon Hino22.svg",
                                            ),
                                      backgroundColor: Colors.white,
                                      heroTag: "1",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            alignment: Alignment.topRight,
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              onPressed: () {
                                showNews();
                              },
                              child: Icon(
                                Icons.email,
                                color: Colors.grey,
                              ),
                              heroTag: "3",
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            )),
                        padding: EdgeInsets.only(
                            left: 5, right: 5, bottom: 10, top: 5),
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/images/line.png",
                              width: 40,
                              height: 5,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Screenshot(
                                  controller: screenshotController,
                                  child: Utils.eventIcon(noti!, context),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        noti!.vehicle_name!,
                                        style: TextStyle(
                                            color: ColorCustom.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      /* Text(
                                        noti!.vehicle!=null?noti!.vehicle!.info!
                                          .licenseprov!:"",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),*/
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      // Utils.convertDateToBase(
                                      //     noti!.gpsdate.toString()),
                                      noti!.display_gpsdate!,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        showBarModalBottomSheet(
                          expand: true,
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => HomeNotiMapDetailPage(
                            noti: noti!,
                          ),
                        );
                      },
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}

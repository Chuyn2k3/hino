import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:group_button/group_button.dart';
import 'package:hino/api/api.dart';
import 'package:hino/main.dart';
import 'package:hino/model/EventHolder.dart';
import 'package:hino/model/factory.dart';
import 'package:hino/model/history.dart';
import 'package:hino/model/trip.dart';
import 'package:hino/model/truck.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/page/home_realtime.dart';
import 'package:hino/utils/ScreenArguments.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:hino/widget/fancy_fab.dart';

import 'dart:ui' as ui;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:image/image.dart' as IMG;

import 'home.dart';
import 'home_news.dart';
import 'home_noti.dart';
import 'info.dart';

class HomeBackupEventSearchMapPage extends StatefulWidget {
  const HomeBackupEventSearchMapPage(
      {Key? key,
      required this.list,
      required this.vid,
      required this.timeStart,
      required this.timeEnd})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final List<Trip> list;
  final String vid;
  final String timeStart;
  final String timeEnd;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeBackupEventSearchMapPage> {
  final markers = <MarkerId, Marker>{};

  // final markersStart = <MarkerId, Marker>{};
  // final markersStop = <MarkerId, Marker>{};
  final controller = Completer<GoogleMapController>();

  var kSantoDomingo;
  var kMarkerId;

  var kMarkerIdStart;
  var kMarkerIdStop;

  // Marker? markerStart;
  // Marker? markerStop;
  // List<Marker> listMarker = [];
  List<EventHolder> kLocations = [];
  int duration = 1000;

  Timer? timer;
  int index = 0;

  bool isLoad = false;
  bool isForward = true;
  Set<Marker> markers2 = Set();
  Vehicle? vehicle;
  ui.Image? imageOri;

  @override
  void initState() {
    notiController.stream.listen((event) {
      print(noti_count);
      refresh();
    });
    for (Vehicle v in listVehicle) {
      if (v.info!.vid.toString() == widget.vid) {
        vehicle = v;
        break;
      }
    }
    getImageFromPath(vehicle!).then((value) => {imageOri = value});
    loadPin();
    _createMarkerImageFromAsset(context);
    addPinFactory();

    var kStartPosition =
        LatLng(widget.list[0].data[15]!, widget.list[0].data[16]!);
    kSantoDomingo = CameraPosition(target: kStartPosition, zoom: 15);
    kMarkerId = MarkerId('MarkerId1');
    kMarkerIdStart = MarkerId('start');
    kMarkerIdStop = MarkerId('stop');

    int i = 0;
    for (Trip h in widget.list) {
      if (h.data[2] == 7 ||
          h.data[2] == 9 ||
          h.data[2] == 14 ||
          h.data[2] == 21 ||
          h.data[2] == 1010 ||
          h.data[2] == 1011) {
        print(h.data[2]);
        var m = MarkerId("event_" + i.toString());
        markers[m] = Marker(
            markerId: m,
            position: LatLng(h.data[15], h.data[16]),
            infoWindow: InfoWindow(
                title: Api.language == "vi"
                    ? Utils.eventTitle(h.data[2])
                    : Utils.eventTitleEn(h.data[2])),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueOrange));

        i++;
      }
    }

    //  var stream = Stream.periodic(
    //         Duration(milliseconds: duration), (count) => kLocations[count])
    //     .take(kLocations.length);
    // stream.forEach((value){
    //   if(!isPlay){
    //     sleep(Duration(seconds:1000));
    //   }else{
    //     newLocationUpdate(value);
    //   }
    //
    // });

    getData2(context);

    super.initState();
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    // Tải SVG string
    final String svgString =
        await DefaultAssetBundle.of(context).loadString(assetName);

    // Lấy thông tin pixel ratio
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    const double targetWidth = 35;
    const double targetHeight = 35;
    final double width = targetWidth * devicePixelRatio;
    final double height = targetHeight * devicePixelRatio;

    // Sử dụng SvgPicture để vẽ vào canvas
    final svgRoot = await svg.fromSvgString(svgString, '');

    final ui.Picture picture = svgRoot.toPicture(size: Size(width, height));
    final ui.Image image = await picture.toImage(width.toInt(), height.toInt());

    final ByteData? bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = bytes!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(pngBytes);
  }

  List<Trip> data = [];

  getData2(BuildContext context) {
    List list = [];
    isLoad = true;
    String param = "?user_id=" +
        Api.profile!.userId.toString() +
        "&vid=" +
        widget.vid +
        "&start=" +
        widget.timeStart +
        "&end=" +
        widget.timeEnd;
    Api.get(context, Api.trip_detail + param).then((value) => {
          if (value != null) {setData(value)} else {},
          isLoad = false,
          refresh()
        });
  }

  refresh() {
    try {
      setState(() {});
    } catch (e) {}
  }

  BitmapDescriptor? pinStart;
  BitmapDescriptor? pinStop;

  loadPin() async {
    pinStart = await _bitmapDescriptorFromSvgAsset(
        context, "assets/images/pin_start.svg");
    pinStop = await _bitmapDescriptorFromSvgAsset(
        context, "assets/images/pin_stop.svg");
    print("load pin " + pinStart.toString());
  }

  setData(List list) {
    for (var a in list) {
      kLocations.add(EventHolder(l: LatLng(a[2], a[3]), c: a[6], d: a[0]));
    }
    displayDateEnd = list[list.length - 1][0];
    _add();
    markers[kMarkerIdStart] = Marker(
        markerId: kMarkerIdStart,
        position: kLocations[0].latlng,
        icon: pinStart == null
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : pinStart!);
    markers[kMarkerIdStop] = Marker(
        markerId: kMarkerIdStop,
        position: kLocations[kLocations.length - 1].latlng,
        icon: pinStop == null
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
            : pinStop!);
    newLocationUpdate(kLocations[index]);
    setTimer();

    controller.future.then((value) => {
          value.moveCamera(CameraUpdate.newLatLngBounds(
              boundsFromLatLngList(kLocations), 50))
        });

    setState(() {});
  }

  setTimer() {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer.periodic(Duration(milliseconds: duration), (Timer t) {
      print(duration);
      if (isPlay) {
        if (index <= kLocations.length - 1) {
          newLocationUpdate(kLocations[index]);
          index++;
        } else {
          reset();
        }
      }
    });
  }

  reset() {
    isPlay = false;
    // index = 0;
    refresh();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  bool isFocus = false;
  String displayDateStart = "";
  String displayDateEnd = "";

  void newLocationUpdate(EventHolder e) async {
    if (duration == 1000) {
      speed = 1;
    }
    if (isFocus) {
      controller.future.then((value) =>
          {value.moveCamera(CameraUpdate.newLatLngZoom(e.latlng, 16))});
    }
    displayDateStart = e.date;

    var marker = Marker(
        markerId: kMarkerId,
        position: e.latlng,
        // ripple: true,
        // rotation: e.course,
        anchor: const Offset(0.5, 0.5),
        // icon: _markerIcon!,
        icon: await getMarkerIcon(vehicle!, e.course),
        // infoWindow: InfoWindow(
        //     title: vehicle?.info!.licenseplate, anchor: Offset(0.5, 0.5)),
        onTap: () {
          controller.future.then((value) =>
              {value.moveCamera(CameraUpdate.newLatLngZoom(e.latlng, 16))});
          Timer(Duration(milliseconds: 200), () {
            isFocus = true;
          });

          _mapPolylines[polylineId] =
              Polyline(polylineId: polylineId, visible: false);
          circles = null;
          refresh();
        });

    // if (isLicense) {
    //   controller.future
    //       .then((value) => {value.showMarkerInfoWindow(kMarkerId)});
    // } else {
    //   controller.future
    //       .then((value) => {value.hideMarkerInfoWindow(kMarkerId)});
    // }

    setState(() => markers[kMarkerId] = marker);
  }

  Future<BitmapDescriptor> getMarkerIcon(Vehicle v, double crose) async {
    ui.Image image = await rotatedImage(imageOri!, crose);
    if (!isLicense) {
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List uint8List = byteData!.buffer.asUint8List();
      // iconTest = BitmapDescriptor.fromBytes(uint8List);

      return BitmapDescriptor.fromBytes(uint8List);
    }

    Size size = Size(image.height.toDouble(), image.height.toDouble());
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // final Radius radius = Radius.circular(size.width / 2);
    //
    final Paint tagPaint = Paint()..color = ColorCustom.white;
    final double tagWidth = 120.0;
    print(size.width);

    // canvas.drawRect(Rect.fromLTWH(size.width/4, 0.0, tagWidth, 50), tagPaint);

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: "  " + v.info!.vehicle_name! + "  ",
      style: TextStyle(
          fontSize: 40.0, color: Colors.black, backgroundColor: Colors.white),
    );

    textPainter.layout();
    // textPainter.paint(
    //     canvas,
    //     Offset(size.width - tagWidth / 2 - textPainter.width / 2,
    //         tagWidth / 2 - textPainter.height / 2));
    var pos = (size.width / 2) - (textPainter.width / 2);
    textPainter.paint(canvas, Offset(pos, 0.5));
    final pathGreen = Path();
    pathGreen.moveTo(size.width / 2, textPainter.height + 15);
    pathGreen.lineTo(110, textPainter.height);
    pathGreen.lineTo(140, textPainter.height);
    pathGreen.close();
    print(pos);
    print(textPainter.width);

    canvas.drawPath(pathGreen, tagPaint);
    // Oval for the image
    Rect oval = Rect.fromLTWH(0, 0, size.width, size.height);

    // Add path for oval image
    // canvas.clipPath(Path()..addOval(oval));

    // Add image

    print("GET MARKER ICON CUSTOMISE CALLED" + image.height.toString());
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.none);
    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();
    // iconTest = BitmapDescriptor.fromBytes(uint8List);

    return BitmapDescriptor.fromBytes(uint8List);
  }

  Future<ui.Image> rotatedImage(ui.Image image, double angle) {
    var pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    double radians = angle * pi / 180;
    final translateX = image.height / 2;
    final translateY = image.height / 2;
    canvas.translate(translateX, translateY);
    canvas.rotate(radians);
    canvas.translate(-translateX, -translateY);
    canvas.drawImage(image, Offset.zero, Paint());

    return pictureRecorder.endRecording().toImage(image.height, image.height);
  }

  Future<ui.Image> getImageFromPath(Vehicle v) async {
    //String fullPathOfImage = await getFileData(imagePath);

    //File imageFile = File(fullPathOfImage);
    // ByteData bytes = await rootBundle.load(imagePath);
    // Uint8List imageBytes = bytes.buffer.asUint8List();

    Uint8List? imageBytes =
        await getBytesFromAsset('assets/images/GREEN4.png', 250);
    //Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });
    //print("COMPLETERR DONE Full path of image is"+imagePath);
    return completer.future;
  }

  BitmapDescriptor? _markerIcon;

  Future _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      _markerIcon = BitmapDescriptor.fromBytes(
          await getBytesFromAsset('assets/images/truck_pin_green.png', 100));
      setState(() {});
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;

  void _add() {
    List<LatLng> listLatlng = [];
    for (EventHolder e in kLocations) {
      listLatlng.add(e.latlng);
    }
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: ColorCustom.blue,
      width: 5,
      points: listLatlng,
    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }

  LatLngBounds boundsFromLatLngList(List<EventHolder> list) {
    assert(list.isNotEmpty);
    double? x0, x1 = 0, y0 = 0, y1 = 0;
    for (int i = 0; i < list.length; i++) {
      LatLng latLng = list[i].latlng;
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  showInfo() {
    isDialOpen.value = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InfoPage(count: 0);
        });
  }

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

  Factory? factoryClick;
  final PolylineId polylineId = PolylineId("polyline_id_factory");

  markerFactoryClick(Factory fac) {
    factoryClick = fac;
    _mapPolylines[polylineId] =
        Polyline(polylineId: polylineId, visible: false);
    circles = null;
    isFocus = false;
    if (fac.coordinateList.isEmpty) {
      setRadius(
          LatLng(fac.lat, fac.lng), fac.id.toString(), fac.radius!.toDouble());
    } else {
      setLineFactory(fac.coordinateList);
    }
    refresh();
    controller.future.then((value) => {
          value.moveCamera(CameraUpdate.newLatLngZoom(
              LatLng(factoryClick!.lat, factoryClick!.lng), 16))
        });
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
      return markers.values.toSet()..addAll(markersFactory);
    } else {
      return markers.values.toSet();
    }
  }

  bool isPlay = true;

  Set<Marker> markersSet = Set();
  int speed = 1;
  double zoom = 0;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  bool traffic = false;
  MapType mode = MapType.normal;
  bool isPinFactory = false;
  bool isLicense = true;
  LatLng? _lastMapPosition;

  bool isDrag = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    GoogleMap(
                      onTap: (v) {
                        isDrag = true;
                      },
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: mode,
                      initialCameraPosition: kSantoDomingo,
                      trafficEnabled: traffic,
                      circles: this.circles != null ? circles! : circlesDef,
                      polylines: Set<Polyline>.of(_mapPolylines.values),
                      // onMapCreated: (gController) => controller.complete(
                      //     gController),
                      onMapCreated: (gController) {
                        controller.complete(gController);
                      },
                      onCameraMove: (v) {
                        _lastMapPosition = v.target;
                        // if (isDrag) {
                        //   isFocus = false;
                        // }
                        // print(isFocus);

                        if (zoom != v.zoom) {
                          zoom = v.zoom;
                          isFocus = false;
                          refresh();
                        }
                      },
                      markers: addMarker(),
                      // Complete the future GoogleMapController
                    ),
                    isLoad
                        ? Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          )
                        : Container(),
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
                              if (mode == MapType.normal) {
                                mode = MapType.satellite;
                              } else if (mode == MapType.satellite) {
                                mode = MapType.terrain;
                              } else {
                                mode = MapType.normal;
                              }
                              refresh();
                            },
                            // child: Icon(
                            //   Icons.layers,
                            //   color: mode == MapType.normal
                            //       ? Colors.grey
                            //       : ColorCustom.blue,
                            // ),
                            child: SvgPicture.asset(
                              "assets/images/Fix Icon Hino27.svg",
                              color: mode == MapType.satellite ||
                                      mode == MapType.terrain
                                  ? ColorCustom.blue
                                  : Colors.grey,
                            ),
                          ),
                          // SpeedDialChild(
                          //   onTap: () {
                          //     if (isLicense) {
                          //       isLicense = false;
                          //     } else {
                          //       isLicense = true;
                          //     }
                          //     // isLoaded = false;
                          //     refresh();
                          //     eneblePlate();
                          //   },
                          //   child: Icon(
                          //     Icons.live_help,
                          //     color: isLicense ? ColorCustom.blue : Colors.grey,
                          //   ),
                          // ),
                          SpeedDialChild(
                            onTap: () {
                              isPinFactory
                                  ? isPinFactory = false
                                  : isPinFactory = true;
                              if (!isPinFactory) {
                                _mapPolylines[polylineId] = Polyline(
                                    polylineId: polylineId, visible: false);
                                circles = null;
                              } else {
                                if (factoryClick != null) {
                                  markerFactoryClick(factoryClick!);
                                }
                              }

                              controller.future.then((value) => {
                                    if (_lastMapPosition == null)
                                      {
                                        value.moveCamera(CameraUpdate.newLatLng(
                                            kSantoDomingo))
                                      }
                                    else
                                      {
                                        value.moveCamera(CameraUpdate.newLatLng(
                                            _lastMapPosition!))
                                      }
                                  });
                              refresh();
                            },
                            // child: Icon(
                            //   Icons.cottage,
                            //   color: isPinFactory ? ColorCustom.blue : Colors.grey,
                            // ),
                            child: SvgPicture.asset(
                              "assets/images/Fix Icon Hino26.svg",
                              color:
                                  isPinFactory ? ColorCustom.blue : Colors.grey,
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
                            // child: Icon(
                            //   Icons.traffic,
                            //   color: traffic ? ColorCustom.blue : Colors.grey,
                            // ),

                            child: SvgPicture.asset(
                              "assets/images/Fix Icon Hino12.svg",
                              color: traffic ? ColorCustom.blue : Colors.grey,
                            ),
                          ),
                          SpeedDialChild(
                            onTap: () {
                              isLicense = !isLicense;
                              // if (vehicle != null) {
                              //   if (isLicense) {
                              //     controller.future.then((value) =>
                              //         {value.showMarkerInfoWindow(kMarkerId)});
                              //   } else {
                              //     controller.future.then((value) =>
                              //         {value.hideMarkerInfoWindow(kMarkerId)});
                              //   }
                              // }
                              newLocationUpdate(kLocations[index]);
                              refresh();
                            },
                            child: SvgPicture.asset(
                              "assets/images/Fix Icon Hino13.svg",
                              color: isLicense ? ColorCustom.blue : Colors.grey,
                            ),
                          ),
                          SpeedDialChild(
                            onTap: () {
                              showInfo();
                            },
                            child: SvgPicture.asset(
                              "assets/images/Fix Icon Hino14.svg",
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      margin: EdgeInsets.all(10),
                      child: Column(
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
              // FlutterSlider(
              //   values: [index.toDouble()],
              //   max: kLocations.length.toDouble(),
              //   min: 0,
              //
              //   rangeSlider: false,
              //   onDragCompleted: (handlerIndex, lowerValue, upperValue) {
              //     index = lowerValue.toInt();
              //     newLocationUpdate(kLocations[index]);
              //     refresh();
              //   },
              //   // onDragging: (handlerIndex, lowerValue, upperValue) {
              //   //   index = lowerValue;
              //   //   newLocationUpdate(kLocations[index]);
              //   //  refresh();
              //   // },
              // ),
              Container(
                width: double.infinity,
                child: SfSlider(
                  min: 0.0,
                  max: kLocations.length.toDouble() > 0
                      ? kLocations.length.toDouble()
                      : 1,
                  value: index.toDouble(),
                  interval: 1,
                  showTicks: false,
                  showLabels: false,
                  enableTooltip: false,
                  minorTicksPerInterval: 1,
                  onChanged: (dynamic value) {
                    index = value.toInt();
                    newLocationUpdate(kLocations[index]);
                    refresh();
                  },
                ),
              ),

              Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      Text(
                        Utils.convertDatePlayback(displayDateStart),
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                      Expanded(child: Container()),
                      Text(
                        Utils.convertDatePlayback(displayDateEnd),
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ],
                  )),
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   duration > 1000 ? "x" + speed.toString() : "",
                    //   style: TextStyle(color: Colors.black, fontSize: 12),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // isForward = false;
                    //     duration *= 2;
                    //     speed = (speed / 2).round();
                    //     setTimer();
                    //     if (duration == 1000) {
                    //       speed = 1;
                    //     }
                    //
                    //     setState(() {});
                    //   },
                    //   child: Icon(Icons.fast_rewind),
                    //   style: ElevatedButton.styleFrom(
                    //     shape: CircleBorder(),
                    //     padding: EdgeInsets.all(5),
                    //   ),
                    // ),
                    Expanded(child: Container()),
                    Expanded(
                      flex: 3,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // isForward = false;
                              // duration *= 2;
                              // speed = speed*2;
                              // setTimer();
                              // if(duration==1000){
                              //   speed = 1;
                              // }
                              if (index > 0) {
                                index--;
                              }
                              newLocationUpdate(kLocations[index]);
                              setState(() {});
                            },
                            child: Icon(Icons.skip_previous),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (isPlay) {
                                isPlay = false;
                              } else {
                                isPlay = true;
                              }
                              setState(() {});
                            },
                            child: Icon(
                              isPlay ? Icons.stop : Icons.play_arrow,
                              size: 40,
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // isForward = true;
                              // duration = (duration / 2).round();
                              // if(duration==1000){
                              //   speed = 1;
                              // }
                              // speed = speed*2;
                              // setTimer();
                              if (index < kLocations.length) {
                                index++;
                              }
                              newLocationUpdate(kLocations[index]);
                              setState(() {});
                            },
                            child: Icon(Icons.skip_next),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (speed < 8) {
                            duration = (duration / 2).round();
                            if (duration == 1000) {
                              speed = 1;
                            }
                            speed = speed * 2;
                          } else {
                            speed = 1;
                            duration = 1000;
                          }
                          setTimer();
                          // if (index < kLocations.length) {
                          //   index++;
                          // }
                          // newLocationUpdate(kLocations[index]);
                          setState(() {});
                        },
                        child: Text(
                          speed.toString() + "x",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: ColorCustom.blue, fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 1.0, color: ColorCustom.blue),
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(1),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       // isForward = true;
                    //       if (speed < 8) {
                    //         duration = (duration / 2).round();
                    //         if (duration == 1000) {
                    //           speed = 1;
                    //         }
                    //         speed = speed * 2;
                    //       } else {
                    //         speed = 1;
                    //         duration = 1000;
                    //       }
                    //       setTimer();
                    //       // if (index < kLocations.length) {
                    //       //   index++;
                    //       // }
                    //       // newLocationUpdate(kLocations[index]);
                    //       setState(() {});
                    //     },
                    //     child: Text(
                    //       speed.toString() + "x",
                    //       style: TextStyle(color: Colors.white, fontSize: 12),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

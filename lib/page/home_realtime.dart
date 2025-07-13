import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/factory.dart';
import 'package:hino/model/marker_icon.dart';
import 'package:hino/model/marker_icon_factory.dart';
import 'package:hino/model/place.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_car.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/page/home_news.dart';
import 'package:hino/page/info.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/marker_license.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:image/image.dart' as IMG;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/src/provider.dart';

import 'home.dart';
import 'home_noti.dart';

// List<Place> listPlace = [];
List<Vehicle> listVehicle = [];

List<Factory> listFactory = [];
// List<Place> listFactoryMarker = [];

bool isAdvertise = true;

class HomeRealtimePage extends StatefulWidget {
  const HomeRealtimePage({
    Key? key,
  }) : super(key: key);

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

class _PageState extends State<HomeRealtimePage> {
  Set<Marker> markersFactory = Set();
  List<Place> listVehicleMarker = [];
  Uint8List? markerIcon;
  late ClusterManager _manager;

  // late ClusterManager _manager2;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  Timer? timer;

  @override
  void initState() {
    // _createMarkerImageFromAsset(context);
    notiController.stream.listen((event) {
      print(noti_count);
      refresh();
    });
    // createCustomMarkerBitmap("test");
    // getMarkerIcon("assets/images/truck_pin_green.png", Size(120, 120)).then((value) => {
    //   _markerIcon = value
    // });
    // getMarkerIcon("assets/images/truck_pin_green.png", Size(120, 120)).then((value) => {
    //   _markerIcon = value
    // });
    // getMarkerIcon("assets/images/truck_pin_green.png", Size(120, 120)).then((value) => {
    //   _markerIcon = value
    // });

    _manager = _initClusterManager();
    // _manager2 = _initClusterManager2();
    if (listVehicle.isEmpty) {
      isLoading = true;
      setState(() {});
      getData(context);
    } else {
      updatePinRefresh();
      // _manager = _initClusterManager();
      // isLoaded = true;
      // refresh();
    }
    // if (listFactory.isEmpty) {
    getDataFactory(context);
    // }
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      listVehicleMarker.clear();
      getData(context);
      if (isPinFactory) {
        // listFactoryMarker.clear();
        // getDataFactory(context);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(listVehicleMarker, _updateMarkers,
        markerBuilder: _markerBuilder, stopClusteringZoom: 9.0);
  }

  // ClusterManager _initClusterManager2() {
  //   return ClusterManager<Place>(listFactoryMarker, _updateMarkers2,
  //       markerBuilder: _markerBuilder2, stopClusteringZoom: 12.0);
  // }

  void _updateMarkers(Set<Marker> markers) {
    // print('Updated ${markers.length} markers');
    this.markers = markers;
    refresh();
  }

  // void _updateMarkers2(Set<Marker> markers) {
  //   // print('Updated ${markers.length} markers');
  //   this.markers2 = markers;
  //   refresh();
  // }

  markerVehicleClick(Vehicle v) {
    isZoom = true;
    vehicleClick = v;
    kLocations.clear();
    _mapPolylines[polylineId] =
        Polyline(polylineId: polylineId, visible: false);

    circles = null;

    setRadius(LatLng(vehicleClick!.gps!.lat!, vehicleClick!.gps!.lng!),
        vehicleClick!.info!.vid!.toString(), 80);
    if (mapController != null) {
      if (isLicense) {
        mapController
            ?.showMarkerInfoWindow(MarkerId(vehicleClick!.info!.licenseplate!));
      } else {
        mapController
            ?.hideMarkerInfoWindow(MarkerId(vehicleClick!.info!.licenseplate!));
      }

      mapController!.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(vehicleClick!.gps!.lat!, vehicleClick!.gps!.lng!), 16));
    }

    setState(() {
      isShowDetail = true;
      isShowDetailFactory = false;
      isShowDetailFactoryFull = false;
    });
  }

  markerFactoryClick(Factory fac) {
    isZoom = true;
    factoryClick = fac;
    _mapPolylines[polylineId] =
        Polyline(polylineId: polylineId, visible: false);
    circles = null;
    print("coordinateList " + factoryClick!.coordinateList.toString());
    print("radius " + factoryClick!.radius.toString());
    if (factoryClick!.coordinateList.isEmpty) {
      setRadius(LatLng(factoryClick!.lat, factoryClick!.lng),
          factoryClick!.id.toString(), factoryClick!.radius!.toDouble());
    } else {
      setLineFactory(factoryClick!.coordinateList);
    }
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(factoryClick!.lat, factoryClick!.lng), 16));
    setState(() {
      isShowDetail = false;
      isShowDetailFactory = true;
      isShowDetailFactoryFull = false;
    });
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        if (cluster.items.length == 1) {
          Vehicle? v;
          cluster.items.forEach((p) => {
                v = p.vehicle,
              });

          return Marker(
            // markerId: MarkerId(cluster.getId()),
            markerId: MarkerId(v!.info!.licenseplate!),
            position: cluster.location,
            onTap: () {
              markerVehicleClick(v!);
            },
            // rotation: v!.gps!.course!,
            anchor: const Offset(0.5, 0.5),
            // infoWindow: InfoWindow(
            //     title: v!.info!.vehicle_name, anchor: Offset(0.5, 0.5)),
            // icon: getMapIcon(v!)!,
            icon: await MarkerLicense.getMarkerIcon(
                v!, isLicense, getMapIconByte(v!)),
          );
        } else {
          return Marker(
            markerId: MarkerId(cluster.getId()),
            position: cluster.location,
            anchor: const Offset(0.5, 0.5),
            icon: await _getMarkerBitmap(cluster, cluster.isMultiple ? 125 : 75,
                text: cluster.isMultiple ? cluster.count.toString() : null),
          );
        }
      };

  // Future<Marker> Function(Cluster<Place>) get _markerBuilder2 =>
  //     (cluster) async {
  //       if (cluster.items.length == 1) {
  //         Factory? fac;
  //         cluster.items.forEach((p) => {
  //               fac = p.factory,
  //             });
  //         return Marker(
  //           markerId: MarkerId(cluster.getId()),
  //           position: cluster.location,
  //           anchor: const Offset(0.5, 0.5),
  //           onTap: () {
  //             markerFactoryClick(fac!);
  //           },
  //           icon: await _getMarkerBitmap3(
  //               cluster, cluster.isMultiple ? 125 : 75,
  //               text: cluster.isMultiple ? cluster.count.toString() : null),
  //         );
  //       } else {
  //         return Marker(
  //           markerId: MarkerId(cluster.getId()),
  //           position: cluster.location,
  //           anchor: const Offset(0.5, 0.5),
  //           icon: await _getMarkerBitmap3(
  //               cluster, cluster.isMultiple ? 125 : 75,
  //               text: cluster.isMultiple ? cluster.count.toString() : null),
  //         );
  //       }
  //     };

  bool isLicense = false;

  // Future<BitmapDescriptor> getMarkerIcon(Vehicle v) async {
  //   ui.Image imageOri = await getImageFromPath(v);
  //   ui.Image image = await rotatedImage(imageOri, v.gps!.course!);
  //   if (!isLicense) {
  //     final ByteData? byteData =
  //     await image.toByteData(format: ui.ImageByteFormat.png);
  //     final Uint8List uint8List = byteData!.buffer.asUint8List();
  //     // iconTest = BitmapDescriptor.fromBytes(uint8List);
  //
  //     return BitmapDescriptor.fromBytes(uint8List);
  //   }
  //
  //
  //
  //   Size size = Size(image.height.toDouble(), image.height.toDouble());
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //
  //   // final Radius radius = Radius.circular(size.width / 2);
  //   //
  //   final Paint tagPaint = Paint()..color = ColorCustom.white;
  //   final double tagWidth = 120.0;
  //   print(size.width);
  //
  //   // canvas.drawRect(Rect.fromLTWH(size.width/4, 0.0, tagWidth, 50), tagPaint);
  //
  //   // Add tag text
  //   TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   textPainter.text = TextSpan(
  //     text: "  "+v.info!.vehicle_name!+"  ",
  //     style: TextStyle(fontSize: 40.0, color: Colors.black,backgroundColor: Colors.white),
  //   );
  //
  //   textPainter.layout();
  //   // textPainter.paint(
  //   //     canvas,
  //   //     Offset(size.width - tagWidth / 2 - textPainter.width / 2,
  //   //         tagWidth / 2 - textPainter.height / 2));
  //   var pos = (size.width/2)-(textPainter.width/2);
  //   textPainter.paint(canvas, Offset(pos, 0.5));
  //   final pathGreen = Path();
  //   pathGreen.moveTo(size.width/2, textPainter.height+15);
  //   pathGreen.lineTo(110, textPainter.height);
  //   pathGreen.lineTo(140, textPainter.height );
  //   pathGreen.close();
  //   print(pos);
  //   print(textPainter.width);
  //
  //   canvas.drawPath(pathGreen, tagPaint);
  //   // Oval for the image
  //   Rect oval = Rect.fromLTWH(0, 0, size.width, size.height );
  //
  //   // Add path for oval image
  //   // canvas.clipPath(Path()..addOval(oval));
  //
  //   // Add image
  //
  //   print("GET MARKER ICON CUSTOMISE CALLED" + image.height.toString());
  //   paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.none);
  //   // Convert canvas to image
  //   final ui.Image markerAsImage = await pictureRecorder
  //       .endRecording()
  //       .toImage(size.width.toInt(), size.height.toInt());
  //
  //   // Convert image to bytes
  //   final ByteData? byteData =
  //       await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
  //   final Uint8List uint8List = byteData!.buffer.asUint8List();
  //   // iconTest = BitmapDescriptor.fromBytes(uint8List);
  //
  //   return BitmapDescriptor.fromBytes(uint8List);
  // }
  //
  // Future<ui.Image> rotatedImage(ui.Image image, double angle) {
  //   var pictureRecorder = ui.PictureRecorder();
  //   Canvas canvas = Canvas(pictureRecorder);
  //   double radians = angle * pi / 180;
  //   final translateX = image.height / 2;
  //   final translateY = image.height / 2;
  //   canvas.translate(translateX, translateY);
  //   canvas.rotate(radians);
  //   canvas.translate(-translateX, -translateY);
  //   canvas.drawImage(image, Offset.zero, Paint());
  //
  //   return pictureRecorder.endRecording().toImage(image.height, image.height);
  // }
  //
  // Future<ui.Image> getImageFromPath(Vehicle v) async {
  //   //String fullPathOfImage = await getFileData(imagePath);
  //
  //   //File imageFile = File(fullPathOfImage);
  //   // ByteData bytes = await rootBundle.load(imagePath);
  //   // Uint8List imageBytes = bytes.buffer.asUint8List();
  //
  //   Uint8List? imageBytes = getMapIconByte(v);
  //   //Uint8List imageBytes = imageFile.readAsBytesSync();
  //
  //   final Completer<ui.Image> completer = new Completer();
  //
  //   ui.decodeImageFromList(imageBytes!, (ui.Image img) {
  //     return completer.complete(img);
  //   });
  //   //print("COMPLETERR DONE Full path of image is"+imagePath);
  //   return completer.future;
  // }

  BitmapDescriptor? iconTest;

  // Future<BitmapDescriptor> _getMarkerBitmap3(Cluster<Place> cluster, int size,
  //     {String? text}) async {
  //   // if (kIsWeb) size = (size / 2).floor();
  //
  //   final PictureRecorder pictureRecorder = PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   Paint paint1 = Paint()..color = ColorCustom.blue;
  //   final Paint paint2 = Paint()..color = Colors.white;
  //
  //   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  //   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
  //   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);
  //
  //   if (text != null) {
  //     TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  //     painter.text = TextSpan(
  //       text: text,
  //       style: TextStyle(
  //           fontSize: size / 3,
  //           color: Colors.white,
  //           fontWeight: FontWeight.normal),
  //     );
  //     painter.layout();
  //     painter.paint(
  //       canvas,
  //       Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
  //     );
  //     final img = await pictureRecorder.endRecording().toImage(size, size);
  //     final data =
  //         await img.toByteData(format: ImageByteFormat.png) as ByteData;
  //
  //     return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  //   } else {
  //     var a;
  //     cluster.items.forEach((p) => {
  //           if (p.factory != null)
  //             {a = getPinFactory(p.factory!)}
  //           else
  //             {a = getMapIcon(p.vehicle!)}
  //         });
  //     return a;
  //   }
  // }

  Future<BitmapDescriptor> getPinFactory(Factory f) async {
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(f.url!);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    return BitmapDescriptor.fromBytes(resizeImage(markerImageBytes));

    // Uint8List bytes = (await NetworkAssetBundle(Uri.parse(f.url!)).load(f.url!))
    //     .buffer
    //     .asUint8List();
    //
    // return BitmapDescriptor.fromBytes(resizeImage(bytes));
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

  Future<BitmapDescriptor> _getMarkerBitmap(Cluster<Place> cluster, int size,
      {String? text}) async {
    // if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    Paint paint1 = Paint()..color = Colors.blue;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
      final img = await pictureRecorder.endRecording().toImage(size, size);
      final data =
          await img.toByteData(format: ImageByteFormat.png) as ByteData;

      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    } else {
      var a;
      cluster.items.forEach((p) => {
            if (p.factory != null) {a = getPinFactory(p.factory!)}
            // else
            //   {a = getMapIcon(p.vehicle!)}
          });
      return a;
    }
  }

  Set<Marker> markers = Set();

  getData(BuildContext context) {
    Api.get(context, Api.realtime).then((value) => {
          isLoading = false,
          if (value != null)
            {
              listVehicle = List.from(value['vehicles'])
                  .map((a) => Vehicle.fromJson(a))
                  .toList(),
              updatePinRefresh(),
            }
          else
            {}
        });
  }

  // bool isLoaded = false;

  getDataFactory(BuildContext context) {
    Api.get(context, Api.factory).then((value) => {
          if (value != null)
            {
              listFactory = List.from(value['data'])
                  .map((a) => Factory.fromJson(a))
                  .toList(),
              addPinFactory(),
              // for (Factory v in listFactory)
              //   {
              //     listFactoryMarker
              //         .add(new Place(latLng: LatLng(v.lat, v.lng), factory: v))
              //   },

              // loadPinFactory(listFactory),
              // _manager2.setItems(listFactoryMarker),
              refresh()
            }
          else
            {}
        });
  }

  updatePinRefresh() {
    listVehicleMarker.clear();
    for (Vehicle v in listVehicle) {
      if (isShowDetail &&
          vehicleClick != null &&
          vehicleClick!.info!.vid == v.info!.vid!) {
        vehicleClick = v;

        setRadius(LatLng(vehicleClick!.gps!.lat!, vehicleClick!.gps!.lng!),
            vehicleClick!.info!.vid!.toString(), 80);
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(vehicleClick!.gps!.lat!, vehicleClick!.gps!.lng!), 16));
        kLocations
            .add(LatLng(vehicleClick!.gps!.lat!, vehicleClick!.gps!.lng!));

        setLine();
      }

      // if(isLicense){
      //   _customInfoWindowController.addInfoWindow!(
      //     Column(
      //       children: [
      //         Text(
      //           v.info!.licenseplate!,
      //           style: TextStyle(
      //               color: Colors.black,
      //               fontSize: 14),
      //         ),
      //       ],
      //     ),
      //     LatLng(vehicleClick!.gps!.lat!, vehicleClick!.gps!.lng!),
      //   );
      // }else{
      //   _customInfoWindowController.hideInfoWindow!();
      // }

      listVehicleMarker
          .add(new Place(latLng: LatLng(v.gps!.lat!, v.gps!.lng!), vehicle: v));
    }

    markers.clear();
    _manager.setItems(listVehicleMarker);
    // _manager2.setItems(listFactoryMarker);
    // refresh();
  }

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

    // markers2.addAll(listFactoryMarker);

    // _manager2.setItems(listFactoryMarker);
  }

  // Future<Timer> eneblePlate() async {
  //   return new Timer(Duration(seconds: 1), onDoneControl2);
  // }
  //
  // onDoneControl2() {
  //   _manager = _initClusterManager();
  //   // isLoaded = true;
  //   refresh();
  // }

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

  refresh() {
    try {
      setState(() {});
    } catch (e) {}
  }

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;

  List<LatLng> kLocations = [];
  Map<PolylineId, Polyline> _mapPolylines = {};
  int _polylineIdCounter = 1;

  int _polylineIdCounter2 = 150000;

  void setLine() {
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.green,
      width: 5,
      points: kLocations,
    );

    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
  }

  final PolylineId polylineId = PolylineId("polyline_id_factory");

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

  // BitmapDescriptor? _markerIcon;
  // BitmapDescriptor? _markerIcon2;
  // BitmapDescriptor? _markerIcon3;
  // BitmapDescriptor? _markerIcon4;

  List<MarkerIconFactory> listIconFac = [];

  loadPinFactory(List<Factory> list) async {
    print(list);
    for (Factory f in list) {
      if (f.url != null) {
        Uint8List bytes =
            (await NetworkAssetBundle(Uri.parse(f.url!)).load(f.url!))
                .buffer
                .asUint8List();
        listIconFac.add(MarkerIconFactory(bytes, f.id!));
        // print("Add");
      }
    }
    refresh();
  }

  // BitmapDescriptor? getMapIcon(Vehicle v) {
  //   switch (v.gps!.io_name!.toLowerCase()) {
  //     case "driving":
  //       var a = "GREEN" + Utils.mapIconVehicle(v.info!.class_type!);
  //       for (MarkerIcon b in listIcon) {
  //         if (b.name!.contains(a)) {
  //           return b.icon;
  //         }
  //       }
  //       return _markerIcon;
  //     case "ign.off":
  //       var a = "RED" + Utils.mapIconVehicle(v.info!.class_type!);
  //       for (MarkerIcon b in listIcon) {
  //         if (b.name!.contains(a)) {
  //           return b.icon;
  //         }
  //       }
  //       return _markerIcon2;
  //     case "parking":
  //       var a = "RED" + Utils.mapIconVehicle(v.info!.class_type!);
  //       for (MarkerIcon b in listIcon) {
  //         if (b.name!.contains(a)) {
  //           return b.icon;
  //         }
  //       }
  //       return _markerIcon2;
  //     case "idling":
  //       var a = "YELLOW" + Utils.mapIconVehicle(v.info!.class_type!);
  //       for (MarkerIcon b in listIcon) {
  //         if (b.name!.contains(a)) {
  //           return b.icon;
  //         }
  //       }
  //       return _markerIcon3;
  //     case "offline":
  //       var a = "WHITE" + Utils.mapIconVehicle(v.info!.class_type!);
  //       for (MarkerIcon b in listIcon) {
  //         if (b.name!.contains(a)) {
  //           return b.icon;
  //         }
  //       }
  //       return _markerIcon4;
  //     case "over_speed":
  //       var a = "VIOLET" + Utils.mapIconVehicle(v.info!.class_type!);
  //       for (MarkerIcon b in listIcon) {
  //         if (b.name!.contains(a)) {
  //           return b.icon;
  //         }
  //       }
  //       return _markerIcon;
  //   }
  //   return _markerIcon;
  // }

  Uint8List getMapIconByte(Vehicle v) {
    switch (v.gps!.io_name!.toLowerCase()) {
      case "driving":
        var a = "GREEN" + Utils.mapIconVehicle(v.info!.vehicle_type!);
        for (MarkerIcon b in listIcon) {
          if (b.name!.contains(a)) {
            return b.iconByte!;
          }
        }
        break;
      case "ign.off":
        var a = "RED" + Utils.mapIconVehicle(v.info!.vehicle_type!);
        for (MarkerIcon b in listIcon) {
          if (b.name!.contains(a)) {
            return b.iconByte!;
          }
        }
        break;
      case "parking":
        var a = "RED" + Utils.mapIconVehicle(v.info!.vehicle_type!);
        for (MarkerIcon b in listIcon) {
          if (b.name!.contains(a)) {
            return b.iconByte!;
          }
        }
        break;
      case "idling":
        var a = "YELLOW" + Utils.mapIconVehicle(v.info!.vehicle_type!);
        for (MarkerIcon b in listIcon) {
          if (b.name!.contains(a)) {
            return b.iconByte!;
          }
        }
        break;
      case "offline":
        var a = "WHITE" + Utils.mapIconVehicle(v.info!.vehicle_type!);
        for (MarkerIcon b in listIcon) {
          if (b.name!.contains(a)) {
            return b.iconByte!;
          }
        }
        break;
      case "over_speed":
        var a = "VIOLET" + Utils.mapIconVehicle(v.info!.vehicle_type!);
        for (MarkerIcon b in listIcon) {
          if (b.name!.contains(a)) {
            return b.iconByte!;
          }
        }
        break;
      default:
        return listIcon[0].iconByte!;
      // var a = "WHITE" + Utils.mapIconVehicle(2);
      // for (MarkerIcon b in listIcon) {
      //   if (b.name!.contains(a)) {
      //     return b.iconByte!;
      //   }
      // }
    }
    return listIcon[0].iconByte!;
  }

  BitmapDescriptor? _markerIconFactory;

  bool isShowDetail = false;

  showDetail() {
    isDialOpen.value = false;
    return InkWell(
      onTap: () {
        // Navigator.of(context)
        //     .push(MaterialPageRoute(builder: (context) => HomeDetailPage()));
        isDialOpen.value = false;
        showBarModalBottomSheet(
            expand: true,
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                HomeDetailPage(vehicle: vehicleClick ?? Vehicle()));
      },
      child: Container(
        color: Colors.white,
        // decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(15.0),
        //       topRight: Radius.circular(15.0),
        //     )),
        padding: EdgeInsets.all(5),
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
                Utils.statusCarImage(
                    vehicleClick!.gps!.io_name!, vehicleClick!.gps!.speed),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleClick!.info!.vehicle_name!,
                        style: TextStyle(
                            color: ColorCustom.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(vehicleClick!.info!.licenseprov!,
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
                        vehicleClick!.gps!.speed.toStringAsFixed(0),
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
            )
          ],
        ),
      ),
    );
  }

  bool isShowDetailFactory = false;

  showDetailFactory() {
    isDialOpen.value = false;
    kLocations.clear();
    return InkWell(
        onTap: () {
          setState(() {
            isShowDetailFactory = false;
            isShowDetail = false;
            isShowDetailFactoryFull = true;
          });
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(5),
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Image.asset(
                "assets/images/icon_factory.png",
                height: 60,
                width: 60,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factoryClick!.name!,
                      style: TextStyle(
                          color: ColorCustom.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                        factoryClick!.lat.toString() +
                            "," +
                            factoryClick!.lng.toString(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  bool isShowDetailFactoryFull = false;

  showDetailFactoryFull() {
    isDialOpen.value = false;
    return Container(
      color: Colors.white,
      // decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.only(
      //       topLeft: Radius.circular(15.0),
      //       topRight: Radius.circular(15.0),
      //     )),
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Image.asset(
                "assets/images/icon_factory.png",
                height: 60,
                width: 60,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      factoryClick!.name!,
                      style: TextStyle(
                          color: ColorCustom.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                        factoryClick!.lat.toString() +
                            "," +
                            factoryClick!.lng.toString(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ],
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
                    Icon(
                      Icons.travel_explore,
                      size: 30,
                      color: Colors.grey,
                    ),
                    Text(
                      Languages.of(context)!.geofence_des,
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
                    Text(
                      Languages.of(context)!.geofence_location,
                      style: TextStyle(
                        color: ColorCustom.black,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      factoryClick!.location_name_3! +
                          " " +
                          factoryClick!.location_name_2! +
                          " " +
                          factoryClick!.location_name_1!,
                      style: TextStyle(
                        color: ColorCustom.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      Languages.of(context)!.geofence_unit,
                      style: TextStyle(
                        color: ColorCustom.black,
                        fontSize: 16,
                      ),
                    ),
                    InkWell(
                      child: Text(
                        factoryClick!.vid_list.length.toString() +
                            " " +
                            Languages.of(context)!.unit +
                            " >",
                        style: TextStyle(
                          color: ColorCustom.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        showCarList();
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextEditingController searchController = new TextEditingController();

  getCarByFactory(List<Vehicle> listSearch) {
    for (Vehicle v in listVehicle) {
      for (int vid in factoryClick!.vid_list) {
        if (vid == v.info!.vid) {
          listSearch.add(v);
        }
      }
    }
  }

  showCarList() {
    var val = "";
    List<Vehicle> listSearch = [];
    List<Vehicle> listCar = [];
    isDialOpen.value = false;
    getCarByFactory(listCar);
    listSearch.addAll(listCar);
    // listSearch.addAll(listVehicle);
    showBarModalBottomSheet(
        expand: true,
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setModalState /*You can rename this!*/) {
            return Column(
              children: [
                BackIOS(),
                Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      listSearch.clear();
                      if (value.isEmpty) {
                        listSearch.addAll(listCar);
                      } else {
                        for (Vehicle v in listCar) {
                          if (v.info!.vin_no!.contains(value)) {
                            listSearch.add(v);
                          }
                          if (v.info!.licenseplate!.contains(value)) {
                            listSearch.add(v);
                          }
                          if (v.info!.licenseprov!.contains(value)) {
                            listSearch.add(v);
                          }
                          if (v.info!.vehicle_name!.contains(value)) {
                            listSearch.add(v);
                          }
                        }

                        List<Vehicle> result =
                            LinkedHashSet<Vehicle>.from(listSearch).toList();
                        listSearch.clear();
                        listSearch.addAll(result);
                      }
                      setModalState(() {});
                    },
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
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        Languages.of(context)!.geofence_unit,
                        style: TextStyle(
                          color: ColorCustom.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 3, bottom: 3),
                      decoration: BoxDecoration(
                        color: ColorCustom.blueLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        listSearch.length.toString() +
                            ' ' +
                            Languages.of(context)!.unit,
                        style: TextStyle(
                          color: ColorCustom.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10),
                    shrinkWrap: false,
                    itemCount: listSearch.length,
                    itemBuilder: (BuildContext context, int index) {
                      Vehicle vehicle = listSearch[index];

                      return GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (_) =>
                          //             HomeCarSummaryPage(vehicle: vehicle)));
                          context.read<PageProvider>().selectVehicle(vehicle);
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
                              Utils.statusCarImage(
                                  vehicle.gps!.io_name!, vehicle.gps!.speed),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicle.info!.vehicle_name!,
                                      style: TextStyle(
                                          color: ColorCustom.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(vehicle.info!.licenseprov!,
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
                                      vehicle.gps!.speed.toStringAsFixed(0),
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
                              //         vehicle.gps!.speed.toStringAsFixed(0),
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
                  ),
                ),
              ],
            );
          });
        });
  }

  bool isShowInfo = false;

  showInfo() {
    isDialOpen.value = false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return InfoPage(count: listVehicle.length);
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

  showCar() {
    isDialOpen.value = false;
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeCarPage(),
    );
  }

  // showCarSummary(Vehicle vehicle) {
  //   showBarModalBottomSheet(
  //     expand: true,
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => HomeCarSummaryPage(
  //       vehicle: vehicle,
  //     ),
  //   );
  // }

  showNews() {
    isDialOpen.value = false;
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeNewsPage(),
    );
  }

  Vehicle? vehicleClick;
  Factory? factoryClick;

  bool traffic = false;
  MapType mode = MapType.normal;
  bool isPinFactory = false;
  bool isZoom = false;

  Set<Marker> addMarker() {
    if (isPinFactory) {
      return markers..addAll(markersFactory);
    } else {
      return markers;
    }
  }

  LatLng? _lastMapPosition;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Vehicle? v = context.watch<PageProvider>().is_select_vehicle;
    if (v != null) {
      _controller.future.then((value) => {
            markerVehicleClick(v),
            context.read<PageProvider>().selectVehicle(null)
          });
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  trafficEnabled: traffic,
                  mapType: mode,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  polylines: Set<Polyline>.of(_mapPolylines.values),
                  mapToolbarEnabled: false,
                  initialCameraPosition: CameraPosition(
                    zoom: 5.5,
                    target: LatLng(21.027763, 105.834160),
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                    mapController = controller;
                    _manager != null
                        ? _manager.setMapId(controller.mapId)
                        : null;
                    // _manager2 != null
                    //     ? _manager2.setMapId(controller.mapId)
                    //     : null;
                  },
                  onCameraMove: (value) {
                    _lastMapPosition = value.target;
                    // print(value.zoom);
                    // print(value.target);
                    if (value.zoom == 5.5) {
                      isZoom = false;
                    } else {
                      isZoom = true;
                    }

                    _manager.onCameraMove(value);
                    // if (_manager2 != null) {
                    //   _manager2.onCameraMove(value);
                    // }
                  },
                  onCameraIdle: () {
                    _manager.updateMap();
                    // _manager2.updateMap();
                  },
                  circles: circles != null ? circles! : circlesDef,
                  markers: addMarker(),
                  // markers: Set<Marker>.of(_markersTruck),
                ),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(),
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
                            // listFactoryMarker.clear();
                            // addPinFactory();
                            _mapPolylines[polylineId] = Polyline(
                                polylineId: polylineId, visible: false);
                            circles = null;
                            isShowDetailFactory = false;
                            isShowDetailFactoryFull = false;
                            refresh();
                          } else {
                            if (factoryClick != null) {
                              markerFactoryClick(factoryClick!);
                            }
                          }
                          if (_lastMapPosition == null) {
                            mapController!.moveCamera(CameraUpdate.newLatLng(
                                const LatLng(21.027763, 105.834160)));
                          } else {
                            mapController!.moveCamera(
                                CameraUpdate.newLatLng(_lastMapPosition!));
                          }

                          refresh();
                        },
                        // child: Icon(
                        //   Icons.cottage,
                        //   color: isPinFactory ? ColorCustom.blue : Colors.grey,
                        // ),
                        child: SvgPicture.asset(
                          "assets/images/Fix Icon Hino26.svg",
                          color: isPinFactory ? ColorCustom.blue : Colors.grey,
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
                          updatePinRefresh();
                          // if (vehicleClick != null) {
                          //   if (isLicense) {
                          //     mapController?.showMarkerInfoWindow(
                          //         MarkerId(vehicleClick!.info!.licenseplate!));
                          //   } else {
                          //     mapController?.hideMarkerInfoWindow(
                          //         MarkerId(vehicleClick!.info!.licenseplate!));
                          //   }
                          // }
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
                      const SizedBox(
                        height: 10,
                      ),
                      FloatingActionButton(
                        foregroundColor: listVehicle.isNotEmpty
                            ? ColorCustom.blue
                            : Colors.transparent,
                        backgroundColor: listVehicle.isNotEmpty
                            ? ColorCustom.blue
                            : Colors.transparent,
                        onPressed: () {
                          if (listVehicle.isNotEmpty) {
                            showCar();
                          }
                        },
                        heroTag: "2",
                        child: listVehicle.isNotEmpty
                            ? SvgPicture.asset("assets/images/icon_car.svg")
                            : SvgPicture.asset("assets/images/icon_car2.svg"),
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
                    child: const Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    heroTag: "3",
                  ),
                ),
                isZoom
                    ? Container(
                        margin: EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            // listVehicleMarker.clear();
                            // listFactoryMarker.clear();
                            kLocations.clear();
                            // isLoaded = false;

                            isShowInfo = false;
                            isShowDetail = false;
                            isShowDetailFactory = false;
                            isShowDetailFactoryFull = false;
                            // refresh();
                            // getData(context);
                            // updatePinRefresh();
                            mapController!.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    const LatLng(21.027763, 105.834160), 5.5));
                            isZoom = false;
                            refresh();
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 30,
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          isShowDetail ? showDetail() : Container(),
          isShowDetailFactory ? showDetailFactory() : Container(),
          isShowDetailFactoryFull ? showDetailFactoryFull() : Container(),
        ],
      ),
    );
  }
}

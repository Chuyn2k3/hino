import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart'
    as cm;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home/home.dart';
import 'package:hino/feature/home_car/home_car.dart';
import 'package:hino/feature/home_noti/home_noti.dart';
import 'package:hino/feature/home_realtime/widget/vehicle_marker_widget.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/factory.dart';
import 'package:hino/model/marker_icon.dart';
import 'package:hino/model/place.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/page/home_news.dart';
import 'package:hino/page/info.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:image/image.dart' as IMG;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/src/provider.dart';
import 'dart:ui' as ui;

List<Vehicle> listVehicle = [];
List<Factory> listFactory = [];
bool isAdvertise = true;

class HomeRealtimePage extends StatefulWidget {
  const HomeRealtimePage({super.key});

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeRealtimePage> {
  // Core state
  Set<Marker> markers = {};
  Set<Marker> markersFactory = {};
  List<Place> listVehicleMarker = [];
  late cm.ClusterManager _manager;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  // API optimization
  Timer? _apiTimer;
  Timer? _debounce;
  List<Vehicle> _lastVehicleList = [];
  bool _isApiLoading = false;

  // Map state
  GoogleMapController? mapController;
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _lastMapPosition;

  // UI state
  bool isLoading = false;
  bool isShowDetail = false;
  bool isShowDetailFactory = false;
  bool isShowDetailFactoryFull = false;
  bool isLicense = false;
  bool traffic = false;
  bool isPinFactory = false;
  bool isZoom = false;
  MapType mode = MapType.normal;

  // Selected items
  Vehicle? vehicleClick;
  Factory? factoryClick;

  // Map drawing
  List<LatLng> kLocations = [];
  final Map<PolylineId, Polyline> _mapPolylines = {};
  Set<Circle>? circles;
  final Set<Circle> circlesDef = {
    const Circle(circleId: CircleId(""), center: LatLng(0, 0), radius: 0)
  };
  final PolylineId polylineId = const PolylineId("polyline_id_factory");
  int _polylineIdCounter = 1;
  Timer? _zoomDebounce;
  List<Vehicle> cachedRealtimeVehicles = [];
  DateTime? lastRealtimeFetch;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  Timer? _searchDebounce;
  int _maxCacheSize = 200;
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    notiController.stream.listen((event) {
      _safeSetState();
    });

    _manager = _initClusterManager();

    if (listVehicle.isEmpty) {
      _loadInitialData();
    } else {
      _updatePinRefresh();
    }

    _startApiTimer();
  }

  void _startApiTimer() {
    _apiTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchAndUpdateData();
    });
  }

  Future<void> _loadInitialData() async {
    if (_isApiLoading) return;

    setState(() {
      isLoading = true;
      _isApiLoading = true;
    });

    try {
      final value = await Api.get(context, Api.realtime);
      if (value != null && mounted) {
        listVehicle = List.from(value['vehicles'])
            .map((a) => Vehicle.fromJson(a))
            .toList();
        _lastVehicleList = List.from(listVehicle);
        _updatePinRefresh();
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          _isApiLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAndUpdateData() async {
    if (_isApiLoading || !mounted) return;

    _isApiLoading = true;
    try {
      final value = await Api.get(context, Api.realtime);
      if (value != null && mounted) {
        List<Vehicle> newList = List.from(value['vehicles'])
            .map((a) => Vehicle.fromJson(a))
            .toList();

        if (!_isVehicleListEqual(newList, _lastVehicleList)) {
          listVehicle = newList;
          _lastVehicleList = List.from(newList);
          _updatePinRefresh();
          _safeSetState();
        }
      }
    } finally {
      _isApiLoading = false;
    }
  }

  bool _isVehicleListEqual(List<Vehicle> a, List<Vehicle> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].info?.vid != b[i].info?.vid ||
          a[i].gps?.lat != b[i].gps?.lat ||
          a[i].gps?.lng != b[i].gps?.lng) {
        return false;
      }
    }
    return true;
  }

  void _safeSetState() {
    if (mounted) {
      setState(() {});
    }
  }

  // ClusterManager _initClusterManager() {
  //   return ClusterManager<Place>(
  //     listVehicleMarker,
  //     _updateMarkers,
  //     markerBuilder: _markerBuilder,
  //     stopClusteringZoom: 9.0,
  //   );
  // }
  cm.ClusterManager _initClusterManager() {
    return cm.ClusterManager<Place>(
      listVehicleMarker,
      _updateMarkers,
      markerBuilder: _markerBuilder,
      stopClusteringZoom:
          14.0, // Tăng từ 9.0 lên 12.0 để phù hợp với logic biển số
    );
  }

  void _updateMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
    _safeSetState();
  }

  /// 1️⃣ Chuyển widget sang BitmapDescriptor (có cache)
  Future<BitmapDescriptor> _getBitmapDescriptorFromWidget(
    String cacheKey,
    Widget widget, {
    required BuildContext context,
    Size? targetSize,
  }) async {
    // Check cache first
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }

    // Create a GlobalKey for RepaintBoundary
    final repaintBoundary = GlobalKey();

    // Create OverlayEntry
    final overlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: RepaintBoundary(
            key: repaintBoundary,
            child: widget,
          ),
        ),
      ),
    );

    // Ensure context has an Overlay
    if (!context.mounted || Overlay.of(context) == null) {
      debugPrint('Error: Invalid context or no Overlay found.');
      throw Exception('Invalid context or no Overlay available.');
    }

    // Insert overlay
    Overlay.of(context).insert(overlay);

    // Wait for the widget to render (increase delay for reliability)
    await Future.delayed(const Duration(milliseconds: 100));

    // Check if RepaintBoundary has a valid context
    if (repaintBoundary.currentContext == null) {
      overlay.remove();
      debugPrint('Error: RepaintBoundary context is null.');
      throw Exception(
          'Failed to render widget: RepaintBoundary context is null.');
    }

    // Get the RenderRepaintBoundary
    final boundary = repaintBoundary.currentContext!.findRenderObject();
    if (boundary == null || boundary is! RenderRepaintBoundary) {
      overlay.remove();
      debugPrint('Error: Failed to find RenderRepaintBoundary.');
      throw Exception('Failed to find RenderRepaintBoundary.');
    }

    // Capture the image
    final image = await boundary.toImage(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    overlay.remove();

    if (byteData == null) {
      debugPrint('Error: Failed to capture widget image.');
      throw Exception('Failed to capture widget image.');
    }

    // Process the image
    Uint8List bytes = byteData.buffer.asUint8List();
    if (targetSize != null) {
      final img = IMG.decodeImage(bytes);
      if (img != null) {
        final resized = IMG.copyResize(img,
            width: targetSize.width.toInt(), height: targetSize.height.toInt());
        bytes = Uint8List.fromList(IMG.encodePng(resized));
      } else {
        debugPrint('Warning: Failed to decode image for resizing.');
      }
    }

    // Create and cache the marker
    final marker = BitmapDescriptor.fromBytes(bytes);
    _addToCache(cacheKey, marker); // Use the existing LRU cache method
    return marker;
  }

  /// 2️⃣ Tạo marker hiển thị icon hoặc biển số
  Future<BitmapDescriptor> _createMarkerWithLicense(
    Vehicle v, {
    required bool showLicense,
    required BuildContext context,
  }) async {
    if (v.info == null || v.info!.licenseplate == null) {
      return BitmapDescriptor.fromBytes(_getMapIconByte(v));
    }

    final String cacheKey =
        '${v.info!.licenseplate}_${showLicense ? "license" : "icon"}';
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }

    if (!showLicense) {
      final marker = BitmapDescriptor.fromBytes(_getMapIconByte(v));
      _addToCache(cacheKey, marker);
      return marker;
    }

    final Uint8List iconBytes = _getMapIconByte(v);
    final String licenseText = v.info!.licenseplate!;

    final markerWidget = VehicleMarkerWidget(
      iconBytes: iconBytes,
      licensePlate: licenseText,
    );

    final marker = await _getBitmapDescriptorFromWidget(
      cacheKey,
      markerWidget,
      context: context,
      targetSize: const Size(350, 320),
    );

    return marker;
  }

  /// 3️⃣ Hàm builder cho marker
  Future<Marker> Function(cm.Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        if (cluster.items.length == 1) {
          final v = cluster.items.first.vehicle!;
          double currentZoom = 5.5;

          if (mapController != null) {
            try {
              currentZoom = await mapController!.getZoomLevel();
            } catch (_) {}
          }

          final bool showLicense = currentZoom >= 8.0;

          return Marker(
            rotation: v.gps?.course ?? 0.0,
            markerId: MarkerId(v.info!.licenseplate!),
            position: cluster.location,
            onTap: () => _markerVehicleClick(v),
            anchor: const Offset(0.5, 0.5),
            icon: await _createMarkerWithLicense(
              v,
              showLicense: showLicense,
              context: context,
            ),
          );
        } else {
          return Marker(
            markerId: MarkerId(cluster.getId()),
            position: cluster.location,
            anchor: const Offset(0.5, 0.5),
            icon: await _getMarkerBitmap(
              cluster,
              cluster.isMultiple ? 125 : 75,
              text: cluster.isMultiple ? cluster.count.toString() : null,
            ),
          );
        }
      };
  void _addToCache(String key, BitmapDescriptor marker) {
    if (_markerIconCache.length >= _maxCacheSize) {
      _markerIconCache
          .remove(_markerIconCache.keys.first); // Xoá marker cũ nhất
    }
    _markerIconCache[key] = marker;
  }

  void _markerVehicleClick(Vehicle v) {
    _resetMapState();
    vehicleClick = v;
    _setRadius(LatLng(v.gps!.lat!, v.gps!.lng!), v.info!.vid!.toString(), 80);
    _animateToVehicle(v);
    _updateUIState(showDetail: true);
  }

  void _markerFactoryClick(Factory fac) {
    _resetMapState();
    factoryClick = fac;

    if (fac.coordinateList.isEmpty) {
      _setRadius(
          LatLng(fac.lat, fac.lng), fac.id.toString(), fac.radius!.toDouble());
    } else {
      _setLineFactory(fac.coordinateList);
    }

    mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(fac.lat, fac.lng), 16));
    _updateUIState(showDetailFactory: true);
  }

  void _resetMapState() {
    isZoom = true;
    kLocations.clear();
    _mapPolylines[polylineId] =
        Polyline(polylineId: polylineId, visible: false);
    circles = null;
  }

  void _animateToVehicle(Vehicle v) {
    if (mapController != null) {
      final markerId = MarkerId(v.info!.licenseplate!);
      // Kiểm tra markerId có trong markers không
      if (markers.any((m) => m.markerId == markerId)) {
        if (isLicense) {
          mapController?.showMarkerInfoWindow(markerId);
        } else {
          mapController?.hideMarkerInfoWindow(markerId);
        }
      }
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(v.gps!.lat!, v.gps!.lng!), 16),
      );
    }
  }

  void _updateUIState({
    bool showDetail = false,
    bool showDetailFactory = false,
    bool showDetailFactoryFull = false,
  }) {
    setState(() {
      isShowDetail = showDetail;
      isShowDetailFactory = showDetailFactory;
      isShowDetailFactoryFull = showDetailFactoryFull;
    });
  }

  void _updatePinRefresh() async {
    if (!mounted) return;
    listVehicleMarker.clear();

    for (Vehicle v in listVehicle) {
      if (isShowDetail &&
          vehicleClick != null &&
          vehicleClick!.info!.vid == v.info!.vid!) {
        vehicleClick = v;
        _setRadius(
            LatLng(v.gps!.lat!, v.gps!.lng!), v.info!.vid!.toString(), 80);
        mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(v.gps!.lat!, v.gps!.lng!), 16));
        kLocations.add(LatLng(v.gps!.lat!, v.gps!.lng!));
        _setLine();
      }
      listVehicleMarker
          .add(Place(latLng: LatLng(v.gps!.lat!, v.gps!.lng!), vehicle: v));
    }

    // markers.clear();
    // _manager.setItems([]);
    // await Future.delayed(const Duration(milliseconds: 50)); // Delay nhỏ
    _manager.setItems(listVehicleMarker);
    // if (mounted) {
    //   setState(() {});
    // }
  }

  void _setRadius(LatLng latLng, String id, double radiusA) {
    circles = {
      Circle(
        fillColor: ColorCustom.blue.withOpacity(0.3),
        strokeWidth: 0,
        circleId: CircleId(id),
        center: latLng,
        radius: radiusA,
      )
    };
  }

  void _setLine() {
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

  void _setLineFactory(List<LatLng> list) {
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

  Uint8List _getMapIconByte(Vehicle v) {
    String iconName;
    switch (v.gps!.io_name!.toLowerCase()) {
      case "driving":
        iconName = "GREEN${Utils.mapIconVehicle(v.info!.vehicle_type!)}";
        break;
      case "ign.off":
      case "parking":
        iconName = "RED${Utils.mapIconVehicle(v.info!.vehicle_type!)}";
        break;
      case "idling":
        iconName = "YELLOW${Utils.mapIconVehicle(v.info!.vehicle_type!)}";
        break;
      case "offline":
        iconName = "WHITE${Utils.mapIconVehicle(v.info!.vehicle_type!)}";
        break;
      case "over_speed":
        iconName = "VIOLET${Utils.mapIconVehicle(v.info!.vehicle_type!)}";
        break;
      default:
        return listIcon[0].iconByte!;
    }

    for (MarkerIcon b in listIcon) {
      if (b.name!.contains(iconName)) {
        return b.iconByte!;
      }
    }
    return listIcon[0].iconByte!;
  }

  Future<BitmapDescriptor> _getMarkerBitmap(cm.Cluster<Place> cluster, int size,
      {String? text}) async {
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
          fontWeight: FontWeight.normal,
        ),
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
      for (var p in cluster.items) {
        if (p.factory != null) {
          a = _getPinFactory(p.factory!);
        }
      }
      return a;
    }
  }

  Future<BitmapDescriptor> _getPinFactory(Factory f) async {
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(f.url!);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    return BitmapDescriptor.fromBytes(_resizeImage(markerImageBytes));
  }

  Uint8List _resizeImage(Uint8List data) {
    IMG.Image img = IMG.decodeImage(data)!;
    IMG.Image resized =
        IMG.copyResize(img, width: img.width * 2, height: img.height * 2);
    return IMG.encodePng(resized);
  }

  Set<Marker> _getDisplayMarkers() {
    return isPinFactory ? (markers..addAll(markersFactory)) : markers;
  }

  void _toggleMapMode() {
    setState(() {
      if (mode == MapType.normal) {
        mode = MapType.satellite;
      } else if (mode == MapType.satellite) {
        mode = MapType.terrain;
      } else {
        mode = MapType.normal;
      }
    });
  }

  void _toggleFactory() {
    setState(() {
      isPinFactory = !isPinFactory;
      if (!isPinFactory) {
        _mapPolylines[polylineId] =
            Polyline(polylineId: polylineId, visible: false);
        circles = null;
        isShowDetailFactory = false;
        isShowDetailFactoryFull = false;
      } else if (factoryClick != null) {
        _markerFactoryClick(factoryClick!);
      }
    });

    final position = _lastMapPosition ?? const LatLng(21.027763, 105.834160);
    mapController?.moveCamera(CameraUpdate.newLatLng(position));
  }

  void _toggleLicense() {
    setState(() {
      isLicense = !isLicense;
    });
    print('Manual toggle license: $isLicense');
    _updatePinRefresh();
  }

  void _resetToOverview() {
    setState(() {
      kLocations.clear();
      isShowDetail = false;
      isShowDetailFactory = false;
      isShowDetailFactoryFull = false;
      isZoom = false;
    });
    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(const LatLng(21.027763, 105.834160), 5.5));
  }

  void _searchAndFocusVehicle(String text) {
    if (text.isEmpty) return;

    final v = listVehicle.firstWhere(
      (v) =>
          v.info!.licenseplate!.toLowerCase().contains(text.toLowerCase()) ||
          v.info!.vehicle_name!.toLowerCase().contains(text.toLowerCase()),
      orElse: () => Vehicle(),
    );

    if (v.info != null && v.gps != null) {
      _markerVehicleClick(v);
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(v.gps!.lat!, v.gps!.lng!), 16),
      );
    }
  }

  Widget _buildDetailView() {
    if (!isShowDetail || vehicleClick == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        isDialOpen.value = false;
        showBarModalBottomSheet(
          expand: true,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              HomeDetailPage(vehicle: vehicleClick ?? Vehicle()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight * 2.5,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container(
            //   width: 40,
            //   height: 4,
            //   margin: const EdgeInsets.only(bottom: 10),
            //   decoration: BoxDecoration(
            //     color: Colors.grey.shade400,
            //     borderRadius: BorderRadius.circular(2),
            //   ),
            // ),
            Row(
              children: [
                // icon trạng thái xe
                Utils.statusCarImage(
                  vehicleClick!.gps!.io_name!,
                  vehicleClick!.gps!.speed,
                ),
                const SizedBox(width: 12),

                // thông tin xe
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleClick!.info!.vehicle_name ?? "-",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorCustom.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicleClick!.info!.licenseprov ?? "",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // tốc độ hiển thị trong circle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorCustom.blue.withOpacity(0.08),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vehicleClick!.gps!.speed.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorCustom.blue,
                        ),
                      ),
                      Text(
                        Languages.of(context)!.km_h,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      margin: const EdgeInsets.only(top: kTextTabBarHeight * 1.2, left: 16),
      alignment: Alignment.topLeft,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _resetToOverview,
          backgroundColor: Colors.transparent,
          elevation: 0,
          heroTag: "back",
          child: const Icon(Icons.arrow_back, color: Colors.grey, size: 24),
        ),
      ),
    );
  }

  Widget _buildFactoryDetail() {
    if (factoryClick == null) return Container();

    return InkWell(
      onTap: () => _updateUIState(showDetailFactoryFull: true),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorCustom.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset("assets/images/icon_factory.png",
                  height: 40, width: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    factoryClick!.name!,
                    style: const TextStyle(
                      color: ColorCustom.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${factoryClick!.lat},${factoryClick!.lng}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFactoryDetailFull() {
    if (factoryClick == null) return Container();

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ColorCustom.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset("assets/images/icon_factory.png",
                      height: 40, width: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        factoryClick!.name!,
                        style: const TextStyle(
                          color: ColorCustom.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${factoryClick!.lat},${factoryClick!.lng}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorCustom.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.travel_explore,
                          size: 24, color: ColorCustom.blue),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Languages.of(context)!.geofence_des,
                      style: const TextStyle(
                        color: ColorCustom.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Languages.of(context)!.geofence_location,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${factoryClick!.location_name_3!} ${factoryClick!.location_name_2!} ${factoryClick!.location_name_1!}",
                      style: const TextStyle(
                        color: ColorCustom.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Languages.of(context)!.geofence_unit,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorCustom.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${factoryClick!.vid_list.length} ${Languages.of(context)!.unit} >",
                        style: const TextStyle(
                          color: ColorCustom.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDial() {
    return Container(
      alignment: Alignment.bottomLeft,
      margin: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight * 3, left: 16),
      child: SpeedDial(
        activeChild: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SvgPicture.asset("assets/images/Fix Icon Hino19.svg"),
        ),
        renderOverlay: false,
        backgroundColor: Colors.white,
        foregroundColor: ColorCustom.blue,
        activeForegroundColor: Colors.red,
        closeDialOnPop: true,
        openCloseDial: isDialOpen,
        children: [
          SpeedDialChild(
            onTap: _toggleMapMode,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                "assets/images/Fix Icon Hino27.svg",
                color: mode == MapType.satellite || mode == MapType.terrain
                    ? ColorCustom.blue
                    : Colors.grey,
              ),
            ),
          ),
          SpeedDialChild(
            onTap: _toggleFactory,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                "assets/images/Fix Icon Hino26.svg",
                color: isPinFactory ? ColorCustom.blue : Colors.grey,
              ),
            ),
          ),
          SpeedDialChild(
            onTap: () => setState(() => traffic = !traffic),
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                "assets/images/Fix Icon Hino12.svg",
                color: traffic ? ColorCustom.blue : Colors.grey,
              ),
            ),
          ),
          SpeedDialChild(
            onTap: _toggleLicense,
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                "assets/images/Fix Icon Hino13.svg",
                color: isLicense ? ColorCustom.blue : Colors.grey,
              ),
            ),
          ),
          SpeedDialChild(
            onTap: () {
              isDialOpen.value = false;
              showDialog(
                context: context,
                builder: (context) => InfoPage(count: listVehicle.length),
              );
            },
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: SvgPicture.asset("assets/images/Fix Icon Hino14.svg",
                  color: Colors.grey),
            ),
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [ColorCustom.blue, ColorCustom.blue.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: ColorCustom.blue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SvgPicture.asset("assets/images/Fix Icon Hino20.svg"),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      alignment: Alignment.bottomRight,
      margin: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight * 2.5, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () {
                isDialOpen.value = false;
                showBarModalBottomSheet(
                  expand: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const HomeNotiPage(),
                );
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              heroTag: "1",
              child: noti_count > 0
                  ? SvgPicture.asset("assets/images/Fix Icon Hino21.svg")
                  : SvgPicture.asset("assets/images/Fix Icon Hino22.svg"),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: listVehicle.isNotEmpty
                  ? LinearGradient(
                      colors: [
                        ColorCustom.blue,
                        ColorCustom.blue.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: listVehicle.isNotEmpty
                      ? ColorCustom.blue.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: FloatingActionButton(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: listVehicle.isNotEmpty
                  ? () {
                      isDialOpen.value = false;
                      showBarModalBottomSheet(
                        expand: true,
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const HomeCarPage(),
                      );
                    }
                  : null,
              heroTag: "2",
              child: listVehicle.isNotEmpty
                  ? SvgPicture.asset("assets/images/icon_car.svg")
                  : SvgPicture.asset("assets/images/icon_car2.svg"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsButton() {
    return Container(
      margin: const EdgeInsets.only(
        //  top: kTextTabBarHeight * 1.2,
        right: 12,
        left: 12,
      ),
      alignment: Alignment.topRight,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            isDialOpen.value = false;
            showBarModalBottomSheet(
              expand: true,
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => const HomeNewsPage(),
            );
          },
          heroTag: "3",
          child: const Icon(Icons.email, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(
          //top: kTextTabBarHeight *0.2,
          // right: 16,
          ),
      alignment: Alignment.topRight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Tìm biển số xe...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        onChanged: (value) {
          if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 1500), () {
            _searchAndFocusVehicle(value);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _apiTimer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Vehicle? v = context.watch<PageProvider>().is_select_vehicle;
    if (v != null) {
      _controller.future.then((value) {
        _markerVehicleClick(v);
        context.read<PageProvider>().selectVehicle(null);
      });
    }

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
                  initialCameraPosition: const CameraPosition(
                    zoom: 5.5,
                    target: LatLng(21.027763, 105.834160),
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                    mapController = controller;
                    _manager.setMapId(controller.mapId);
                  },
                  onCameraMove: (value) {
                    _lastMapPosition = value.target;
                    double zoom = value.zoom;
                    bool shouldShowLicense = zoom >= 8.0;

                    if (_zoomDebounce?.isActive ?? false)
                      _zoomDebounce!.cancel();
                    _zoomDebounce =
                        Timer(const Duration(milliseconds: 300), () {
                      if (shouldShowLicense != isLicense) {
                        setState(() {
                          isLicense = shouldShowLicense;
                        });
                        _updatePinRefresh();
                      }
                      _manager.onCameraMove(value);
                    });
                  },
                  onCameraIdle: () {
                    _manager.updateMap();
                  },
                  circles: circles ?? circlesDef,
                  markers: _getDisplayMarkers(),
                ),
                // _buildSearchBar(),
                Positioned(
                  top: kTextTabBarHeight * (isZoom ? 2.5 : 1.2),
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 8,
                      ),
                      //const Spacer(flex: 1),
                      Expanded(child: _buildSearchBar()),
                      //const Spacer(flex: 2),
                      _buildNewsButton(),
                    ],
                  ),
                ),
                if (isLoading) const Center(child: CircularProgressIndicator()),
                _buildSpeedDial(),
                _buildActionButtons(),

                if (isZoom) _buildBackButton(),
              ],
            ),
          ),
          _buildDetailView(),
          if (isShowDetailFactory) _buildFactoryDetail(),
          if (isShowDetailFactoryFull) _buildFactoryDetailFull(),
        ],
      ),
    );
  }
}

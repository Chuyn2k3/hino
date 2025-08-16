// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:provider/provider.dart';
// import 'package:radar_chart/radar_chart.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:hino/api/api.dart';
// import 'package:hino/localization/language/languages.dart';
// import 'package:hino/model/driver.dart';
// import 'package:hino/model/driver_detail.dart';
// import 'package:hino/model/Eco.dart';
// import 'package:hino/model/Safety.dart';
// import 'package:hino/provider/page_provider.dart';
// import 'package:hino/utils/utils.dart';
// import 'package:hino/utils/color_custom.dart';
// import 'package:hino/widget/back_ios.dart';
// import 'home_noti_event.dart';

// class HomeDriverDetailPage extends StatefulWidget {
//   final Driver driver;
//   const HomeDriverDetailPage({Key? key, required this.driver}) : super(key: key);

//   @override
//   State<HomeDriverDetailPage> createState() => _HomeDriverDetailPageState();
// }

// class _HomeDriverDetailPageState extends State<HomeDriverDetailPage> {
//   DriverDetail? driverDetailToday;
//   DriverDetail? driverDetailGraph;
//   double sumEco = 0;
//   double sumSafety = 0;
//   List<String> ecoFeatures = [], safetyFeatures = [];
//   List<double> ecoAvg = [], ecoPoints = [], safetyAvg = [], safetyPoints = [];

//   @override
//   void initState() {
//     super.initState();
//     _initData();
//   }

//   Future<void> _initData() async {
//     await _fetchDriverDetail(Utils.getDateCreate(), assignToday: true);
//     await _fetchDriverDetail(Utils.getDateBackYear(), assignToday: false);
//   }

//   Future<void> _fetchDriverDetail(String startDate, {required bool assignToday}) async {
//     final res = await Api.get(
//       context,
//       "${Api.driver_detail}${widget.driver.personalId}&start_date=$startDate&stop_date=${Utils.getDateCreate()}",
//     );
//     if (res != null) {
//       final detail = DriverDetail.fromJson(res['result']);
//       setState(() {
//         if (assignToday) driverDetailToday = detail;
//         else {
//           driverDetailGraph = detail;
//           _prepareChart(detail);
//         }
//       });
//     }
//   }

//   void _prepareChart(DriverDetail detail) {
//     ecoFeatures.clear();
//     ecoAvg.clear();
//     ecoPoints.clear();
//     safetyFeatures.clear();
//     safetyAvg.clear();
//     safetyPoints.clear();
//     sumEco = 0;
//     sumSafety = 0;

//     for (var eco in detail.eco) {
//       ecoFeatures.add(eco.arg!);
//       ecoAvg.add(eco.avg! / 5);
//       ecoPoints.add(eco.point! / 5);
//       sumEco += eco.avg!;
//     }

//     for (var safe in detail.safety) {
//       safetyFeatures.add(safe.arg!);
//       safetyAvg.add(safe.avg! / 5);
//       safetyPoints.add(safe.point! / 5);
//       sumSafety += safe.avg!;
//     }
//   }

//   void _shareLocation() {
//     final lat = widget.driver.lat;
//     final lng = widget.driver.lng;
//     if (lat != null && lng != null) {
//       final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
//       Share.share(
//         "${Languages.of(context)!.plate_no} ${widget.driver.licensePlateNo}\n$googleUrl",
//       );
//     }
//   }

//   void _showEvents() {
//     showBarModalBottomSheet(
//       context: context,
//       expand: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => HomeNotiEventPage(
//         name: "${widget.driver.firstname} ${widget.driver.lastname}",
//       ),
//     );
//   }

//   Widget _buildSectionHeader({IconData? icon, required String title, Widget? action}) {
//     return Row(
//       children: [
//         if (icon != null) Icon(icon, size: 40, color: Colors.grey),
//         if (icon != null) const SizedBox(width: 8),
//         Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         const Spacer(),
//         if (action != null) action,
//       ],
//     );
//   }

//   Widget _statItem(String label, String value) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(label, style: const TextStyle(fontSize: 16)),
//       Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//     ]);
//   }

//   Widget _radarChart({
//     required List<String> features,
//     required List<double> avg,
//     required List<double> pts,
//     required double sumValues,
//     required Color avgColor,
//     required Color ptsColor,
//   }) {
//     if (features.isEmpty) return const SizedBox.shrink();

//     return RadarChart(
//       length: features.length,
//       radius: 100,
//       initialAngle: -pi / 2,
//       backgroundColor: Colors.white,
//       borderStroke: 2,
//       borderColor: Colors.grey.shade300,
//       radialStroke: 1,
//       radialColor: Colors.grey.shade300,
//       vertices: features
//           .map((f) => RadarVertex(radius: 15, text: Text(f, style: const TextStyle(fontSize: 10))))
//           .toList(),
//       radars: [
//         RadarTile(values: pts, backgroundColor: ptsColor.withOpacity(0.5)),
//         RadarTile(values: avg, borderStroke: 2, borderColor: avgColor),
//       ],
//     );
//   }

//   Widget _legendDot(Color color, String label) => Row(
//         children: [
//           Icon(Icons.fiber_manual_record, color: color, size: 15),
//           const SizedBox(width: 4),
//           Text(label, style: const TextStyle(fontSize: 12)),
//         ],
//       );

//   @override
//   Widget build(BuildContext context) {
//     final dr = widget.driver;
//     final det = driverDetailToday;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(10),
//           child: Column(children: [
//             BackIOS(),
//             // PROFILE CARD
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 5),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Row(children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundImage:
//                         dr.photoUrl!.isNotEmpty ? NetworkImage(dr.photoUrl!) : null,
//                     child: dr.photoUrl!.isEmpty
//                         ? Image.asset('assets/images/profile_empty.png')
//                         : null,
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Text('${dr.prefix} ${dr.firstname} ${dr.lastname}',
//                           style: const TextStyle(fontWeight: FontWeight.bold)),
//                       Utils.swipeCard(dr, context),
//                       if (dr.display_datetime_swipe?.isNotEmpty ?? false)
//                         Text(dr.display_datetime_swipe!),
//                     ]),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                         color: ColorCustom.greyBG, borderRadius: BorderRadius.circular(50)),
//                     child: Column(children: [
//                       Text(Utils.numberFormatInt(dr.score!), style: const TextStyle(fontWeight: FontWeight.bold)),
//                       Text(Languages.of(context)!.score,
//                           style: const TextStyle(color: Colors.grey, fontSize: 10)),
//                     ]),
//                   )
//                 ]),
//               ),
//             ),

//             // DRIVER STATS
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 5),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(children: [
//                   _buildSectionHeader(
//                     title: Languages.of(context)!.driver_title,
//                     action: IconButton(
//                       icon: Icon(Icons.notifications, color: ColorCustom.blue),
//                       onPressed: _showEvents,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(children: [
//                     Expanded(
//                         child: _statItem(
//                             Languages.of(context)!.driver_distance,
//                             det != null
//                                 ? '${Utils.numberFormat(det.distance!)} ${Languages.of(context)!.km}'
//                                 : '--')),
//                     Expanded(
//                         child: _statItem(
//                             Languages.of(context)!.driver_duration,
//                             det != null
//                                 ? '${det.total_time!} ${Languages.of(context)!.h}'
//                                 : '--')),
//                   ]),
//                 ]),
//               ),
//             ),

//             // LOCATION INFO
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 5),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   _buildSectionHeader(
//                     icon: Icons.travel_explore,
//                     title: Languages.of(context)!.location_title,
//                     action: Row(children: [
//                       if (dr.licensePlateNo!.isNotEmpty)
//                         IconButton(
//                           icon: Image.asset('assets/images/google-maps.png', width: 40, height: 40),
//                           onPressed: () {
//                             final vehicle = Utils.getVehicleByLicense(dr.licensePlateNo!);
//                             if (vehicle != null) {
//                               context
//                                   .read<PageProvider>()
//                                   .selectVehicle(vehicle);
//                               Navigator.popUntil(context, ModalRoute.withName('/root'));
//                             }
//                           },
//                         ),
//                       IconButton(
//                         icon: Icon(Icons.share, color: ColorCustom.blue),
//                         onPressed: _shareLocation,
//                       ),
//                     ]),
//                   ),
//                   const SizedBox(height: 10),
//                   _statItem(Languages.of(context)!.plate_no, dr.licensePlateNo!),
//                   _statItem(Languages.of(context)!.last_update,
//                       dr.vehicle?.gps?.display_gpsdate ?? '--'),
//                   _statItem(Languages.of(context)!.location,
//                       '${dr.adminLevel3Name} ${dr.adminLevel2Name} ${dr.adminLevel1Name}'),
//                 ]),
//               ),
//             ),

//             // ECO RADAR
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 5),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(children: [
//                   _buildSectionHeader(title:
//                       "${Languages.of(context)!.dashboardGraph2} (${((sumEco * 100) / 30).round()}/100)"),
//                   const SizedBox(height: 10),
//                   _radarChart(
//                     features: ecoFeatures,
//                     avg: ecoAvg,
//                     pts: ecoPoints,
//                     sumValues: sumEco,
//                     avgColor: ColorCustom.dashboard_save_avg,
//                     ptsColor: ColorCustom.dashboard_save_point,
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _legendDot(ColorCustom.dashboard_save_avg, Languages.of(context)!.avg),
//                       const SizedBox(width: 20),
//                       _legendDot(ColorCustom.dashboard_save_point, Languages.of(context)!.score),
//                     ],
//                   ),
//                 ]),
//               ),
//             ),

//             // SAFETY RADAR
//             Card(
//               margin: const EdgeInsets.symmetric(vertical: 5),
//               child: Padding(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(children: [
//                   _buildSectionHeader(title:
//                       "${Languages.of(context)!.dashboardGraph3} (${((sumSafety * 100) / 30).round()}/100)"),
//                   const SizedBox(height: 10),
//                   _radarChart(
//                     features: safetyFeatures,
//                     avg: safetyAvg,
//                     pts: safetyPoints,
//                     sumValues: sumSafety,
//                     avgColor: ColorCustom.dashboard_safe_avg,
//                     ptsColor: ColorCustom.dashboard_safe_point,
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _legendDot(ColorCustom.dashboard_safe_avg, Languages.of(context)!.avg),
//                       const SizedBox(width: 20),
//                       _legendDot(ColorCustom.dashboard_safe_point, Languages.of(context)!.score),
//                     ],
//                   ),
//                 ]),
//               ),
//             ),

//           ]),
//         ),
//       ),
//     );
//   }
// }

// class RadarVertex extends StatelessWidget {
//   final double radius;
//   final Widget? text;

//   const RadarVertex({Key? key, required this.radius, this.text}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return CircleAvatar(radius: radius, backgroundColor: Colors.white, child: text);
//   }
// }

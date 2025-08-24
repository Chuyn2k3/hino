import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/event_group.dart';
import 'package:hino/model/history.dart';
import 'package:hino/model/trip.dart';
import 'package:hino/page/home_backup_event_search_map.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/timeline_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeBackupEventSearchPage extends StatefulWidget {
  const HomeBackupEventSearchPage({
    Key? key,
    required this.start,
    required this.end,
    required this.imei,
    required this.license,
    required this.timeStart,
    required this.timeEnd,
  }) : super(key: key);

  final DateTime start;
  final DateTime end;
  final String imei;
  final DateTime timeStart;
  final DateTime timeEnd;
  final String license;

  @override
  _HomeBackupEventSearchPageState createState() =>
      _HomeBackupEventSearchPageState();
}

class _HomeBackupEventSearchPageState extends State<HomeBackupEventSearchPage> {
  String? start;
  String? timeStart;
  String? end;
  String? timeEnd;
  int difference = 0;
  bool isLoad = true;
  List<History> listHistory = [];
  List<Trip> data = [];
  List<EventGroup> listEvent2 = [];
  String param = "";
  String vid = "";

  @override
  void initState() {
    super.initState();
    start = DateFormat('yyyy-MM-dd').format(widget.start);
    timeStart = DateFormat('HH:mm:ss').format(widget.timeStart);
    end = DateFormat('yyyy-MM-dd').format(widget.end);
    timeEnd = DateFormat('HH:mm:ss').format(widget.timeEnd);
    getData2(context);
  }

  Future<void> getData2(BuildContext context) async {
    final vehicle = Utils.getVehicleByLicense(widget.license);
    vid = vehicle?.info?.vid?.toString() ?? "";
    param =
        "?user_id=${Api.profile!.userId}&vid=$vid&start=$start $timeStart&end=$end $timeEnd";
    final value = await Api.get(context, Api.trip + param);
    if (value != null && value["result"] != null) {
      final list = value["result"] as List;
      setData(list);
      if (list.length <= 1) {
        Utils.showAlertDialogEmpty(context);
      }
    } else {
      setState(() => isLoad = false);
      Utils.showAlertDialogEmpty(context);
    }
  }

  void setData(List<dynamic> list) {
    isLoad = false;
    data.clear();
    for (var item in list) {
      if (item[13].isNotEmpty) {
        final trip = Trip()..data = item;
        data.add(trip);
      }
    }
    group2();
    setState(() {});
  }

  void group2() {
    listEvent2.clear();
    int start = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i].data[2] == 2000) {
        final group = EventGroup()..date = "";
        group.trips.addAll(data.sublist(start, i + 1));
        listEvent2.add(group);
        start = i + 1;
      }
    }
  }

  String calTime(List<Trip> trips) {
    final startTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parseLoose(trips[0].data[0]);
    final endTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parseLoose(trips[0].data[1]);
    final duration = endTime.difference(startTime);
    final parts = duration.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String calDistance(List<Trip> trips) {
    double sum = 0;
    for (int i = 0; i < trips.length - 1; i++) {
      sum += (trips[i].data[9] is double
              ? trips[i].data[9]
              : trips[i].data[9] as int)
          .toDouble();
    }
    return "${Utils.numberFormat(sum)} ${Languages.of(context)!.km}";
  }

  String calFuel(List<Trip> trips) {
    double sum = 0;
    for (int i = 0; i < trips.length - 1; i++) {
      sum += (trips[i].data[10] is double
              ? trips[i].data[10]
              : trips[i].data[10] as int)
          .toDouble();
    }
    return "${Utils.numberFormat(sum)} ${Languages.of(context)!.lite}";
  }

  String calFuelCon(List<Trip> trips) {
    double sum = 0;
    for (int i = 0; i < trips.length - 1; i++) {
      sum += (trips[i].data[11] is double
              ? trips[i].data[11]
              : trips[i].data[11] as int)
          .toDouble();
    }
    return "${Utils.numberFormat(sum)} ${Languages.of(context)!.km_l}";
  }

  String displayDate(
      DateTime start, DateTime end, DateTime timeStart, DateTime timeEnd) {
    return "${DateFormat('dd MMM yy', Api.language).format(start)} ${DateFormat('HH:mm').format(timeStart)} - ${DateFormat('dd MMM yy', Api.language).format(end)} ${DateFormat('HH:mm').format(timeEnd)}";
  }

  Future<void> launchMap(double lat, double long) async {
    final googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BaseScaffold(
      appBar: CustomAppbar.basic(
        onTap: () => Navigator.pop(context),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Date
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorCustom.blue,
                        ColorCustom.blue.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          displayDate(widget.start, widget.end,
                              widget.timeStart, widget.timeEnd),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // List
                Expanded(
                  child: listEvent2.isEmpty && !isLoad
                      ? Center(
                          child: Text(
                            Languages.of(context)!.no_data,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: listEvent2.length,
                          itemBuilder: (context, index) {
                            final event = listEvent2[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    16), // Increased border radius for modern look
                              ),
                              elevation: 2, // Softer shadow
                              clipBehavior: Clip
                                  .antiAlias, // Ensures content doesn't overflow rounded corners
                              child: InkWell(
                                // Add tap feedback for the entire card
                                onTap: () {
                                  setState(
                                      () => event.isExpand = !event.isExpand);
                                },
                                splashColor: Colors.blueAccent.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header row with event type and map button
                                      Row(
                                        children: [
                                          // Event type icon with color coding
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: event.trips[0].data[2] == 1
                                                  ? Colors.green
                                                      .withOpacity(0.1)
                                                  : event.trips[0].data[2] ==
                                                          2000
                                                      ? Colors.red
                                                          .withOpacity(0.1)
                                                      : Colors.grey
                                                          .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              event.trips[0].data[2] == 1
                                                  ? Icons.directions_car
                                                  : event.trips[0].data[2] ==
                                                          2000
                                                      ? Icons.stop_circle
                                                      : Icons.help,
                                              color: event.trips[0].data[2] == 1
                                                  ? Colors.green
                                                  : event.trips[0].data[2] ==
                                                          2000
                                                      ? Colors.red
                                                      : Colors.grey,
                                              size: 28,
                                              semanticLabel: event
                                                          .trips[0].data[2] ==
                                                      1
                                                  ? Languages.of(context)!
                                                      .event_driving
                                                  : event.trips[0].data[2] ==
                                                          2000
                                                      ? Languages.of(context)!
                                                          .event_stopping
                                                      : Languages.of(context)!
                                                          .unknown,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              event.trips[0].data[2] == 1
                                                  ? Languages.of(context)!
                                                      .event_driving
                                                  : event.trips[0].data[2] ==
                                                          2000
                                                      ? Languages.of(context)!
                                                          .event_stopping
                                                      : Languages.of(context)!
                                                          .unknown,
                                              style: const TextStyle(
                                                fontSize:
                                                    18, // Larger font for title
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Map button with tooltip
                                          IconButton(
                                            icon: const Icon(
                                              Icons.map,
                                              color: Colors.blueAccent,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              final s = event.trips[0].data[0];
                                              final e = event
                                                  .trips[event.trips.length - 1]
                                                  .data[1];
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      HomeBackupEventSearchMapPage(
                                                    list: event.trips,
                                                    vid: vid,
                                                    timeStart: s,
                                                    timeEnd: e,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Timeline + Location
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 30,
                                            height: 100,
                                            child: TimelineWidget(
                                              startColor:
                                                  event.trips[0].data[2] == 1
                                                      ? Colors.green
                                                      : event.trips[0]
                                                                  .data[2] ==
                                                              2000
                                                          ? Colors.red
                                                          : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  event.trips[0].data[3],
                                                  style: const TextStyle(
                                                    fontSize:
                                                        16, // Slightly larger for location
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  event.trips.last.data[3],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Expand details with animation
                                      AnimatedCrossFade(
                                        duration: const Duration(
                                            milliseconds:
                                                400), // Smoother transition
                                        crossFadeState: event.isExpand
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        firstChild: GridView(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                screenWidth > 600 ? 3 : 2,
                                            childAspectRatio:
                                                screenWidth > 600 ? 4 : 3,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                          ),
                                          children: [
                                            _infoTile(
                                              Languages.of(context)!
                                                  .event_date_time,
                                              "${Utils.convertDateToBaseReal(event.trips[0].data[21])} - ${Utils.convertDateToBaseReal(event.trips[0].data[22])}",
                                              icon: Icons.calendar_today,
                                            ),
                                            _infoTile(
                                              Languages.of(context)!
                                                  .event_duration,
                                              calTime(event.trips),
                                              icon: Icons.timer,
                                            ),
                                            _infoTile(
                                              Languages.of(context)!
                                                  .event_obd_start,
                                              Utils.numberFormat(
                                                  event.trips[0].data[19]),
                                              icon: Icons.speed,
                                            ),
                                            _infoTile(
                                              Languages.of(context)!
                                                  .event_obd_end,
                                              Utils.numberFormat(
                                                  event.trips.last.data[20]),
                                              icon: Icons.speed,
                                            ),
                                            _infoTile(
                                              Languages.of(context)!
                                                  .event_distance,
                                              calDistance(event.trips),
                                              icon: Icons.straighten,
                                            ),
                                            _infoTile(
                                              Languages.of(context)!.event_fuel,
                                              calFuel(event.trips),
                                              icon: Icons.local_gas_station,
                                            ),
                                            _infoTile(
                                              Languages.of(context)!
                                                  .event_fuel_consumption,
                                              calFuelCon(event.trips),
                                              icon: Icons.water_drop,
                                            ),
                                            _infoTile(
                                              Languages.of(context)!
                                                  .event_driver,
                                              (event.trips[0].data[4] as String)
                                                      .isEmpty
                                                  ? Languages.of(context)!
                                                      .unidentified_driver
                                                  : event.trips[0].data[4],
                                              icon: Icons.person,
                                            ),
                                          ],
                                        ),
                                        secondChild: const SizedBox.shrink(),
                                      ),
                                      // Expand button with modern design
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            setState(() => event.isExpand =
                                                !event.isExpand);
                                          },
                                          icon: Icon(
                                            event.isExpand
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                            color: Colors.blueAccent,
                                          ),
                                          label: Text(
                                            event.isExpand
                                                ? Languages.of(context)!.less
                                                : Languages.of(context)!.more,
                                            style: const TextStyle(
                                                color: Colors.blueAccent),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                                color: Colors.blueAccent
                                                    .withOpacity(0.5)),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (isLoad)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, {IconData? icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 2),
            child: Icon(
              icon,
              size: 18,
              color: Colors.grey[600],
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/Eco.dart';
import 'package:hino/model/driver.dart';
import 'package:hino/model/driver_detail.dart';
import 'package:hino/model/safety.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:provider/provider.dart';
import 'package:radar_chart/radar_chart.dart';
import 'package:share_plus/share_plus.dart';

class HomeDriverDetailPage extends StatefulWidget {
  const HomeDriverDetailPage({Key? key, required this.driver})
      : super(key: key);

  final Driver driver;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeDriverDetailPage> {
  DriverDetail? driverDetail;
  double sumPoint = 0, sumPoint2 = 0;

  List<String> features = [], features2 = [];
  List<double> avg = [], point = [], avg2 = [], point2 = [];

  @override
  void initState() {
    super.initState();
    getDataDriver();
    getDataGraph();
  }

  void getDataDriver() async {
    final res = await Api.get(
      context,
      "${Api.driver_detail}${widget.driver.personalId!}&start_date=${Utils.getDateCreate()}&stop_date=${Utils.getDateCreate()}",
    );
    if (res != null) {
      setState(() => driverDetail = DriverDetail.fromJson(res["result"]));
    }
  }

  void getDataGraph() async {
    final res = await Api.get(
      context,
      "${Api.driver_detail}${widget.driver.personalId!}&start_date=${Utils.getDateBackYear()}&stop_date=${Utils.getDateCreate()}",
    );
    if (res != null) {
      initChart(DriverDetail.fromJson(res["result"]));
    }
  }

  void initChart(DriverDetail detail) {
    sumPoint = 0;
    sumPoint2 = 0;
    features = detail.eco.map((e) => e.arg!).toList();
    avg = detail.eco.map((e) => e.avg! / 5).toList().cast<double>();
    point = detail.eco.map((e) => e.point! / 5).toList().cast<double>();
    sumPoint = detail.eco.fold(0, (sum, e) => sum + e.avg!);

    features2 = detail.safety.map((e) => e.arg!).toList();
    avg2 = detail.safety.map((e) => e.avg! / 5).toList().cast<double>();
    point2 = detail.safety.map((e) => e.point! / 5).toList().cast<double>();
    sumPoint2 = detail.safety.fold(0, (sum, e) => sum + e.avg!);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppbar.basic(
        onTap: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            _buildDriverCard(),
            _buildDriverDetailCard(),
            _buildLocationCard(),
            _buildRadarChartCard(
              title:
                  "${Languages.of(context)!.dashboardGraph2} (${((sumPoint * 100) / 30).toStringAsFixed(0)}/100)",
              icon: "assets/images/Fix Icon Hino29.svg",
              avg: avg,
              point: point,
              features: features,
              avgColor: ColorCustom.dashboard_save_avg,
              pointColor: ColorCustom.dashboard_save_point,
            ),
            _buildRadarChartCard(
              title:
                  "${Languages.of(context)!.dashboardGraph3} (${((sumPoint2 * 100) / 30).toStringAsFixed(0)}/100)",
              icon: "assets/images/Fix Icon Hino30.svg",
              avg: avg2,
              point: point2,
              features: features2,
              avgColor: ColorCustom.dashboard_safe_avg,
              pointColor: ColorCustom.dashboard_safe_point,
            ),
          ],
        ),
      ),
    );
  }

  /// ----------------- WIDGET BUILDER -----------------

  Widget _buildDriverCard() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: widget.driver.photoUrl != null &&
                  widget.driver.photoUrl!.isNotEmpty
              ? NetworkImage(widget.driver.photoUrl!)
              : const AssetImage("assets/images/profile_empty.png")
                  as ImageProvider,
          radius: 30,
        ),
        title: Text(
          "${widget.driver.prefix ?? ''} ${widget.driver.firstname ?? ''} ${widget.driver.lastname ?? ''}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Utils.swipeCard(widget.driver, context),
            if (widget.driver.display_datetime_swipe?.isNotEmpty ?? false)
              Text(widget.driver.display_datetime_swipe!),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Utils.numberFormatInt(widget.driver.score ?? 0),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              Languages.of(context)!.score,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverDetailCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset("assets/images/icon_profile.svg",
                    width: 32, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  Languages.of(context)!.driver_title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    title: Languages.of(context)!.driver_distance,
                    value: driverDetail != null
                        ? "${Utils.numberFormat(driverDetail!.distance!)} ${Languages.of(context)!.km}"
                        : "",
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    title: Languages.of(context)!.driver_duration,
                    value: driverDetail != null
                        ? "${driverDetail!.total_time!} ${Languages.of(context)!.h}"
                        : "",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset("assets/images/icon_gps.svg",
                    width: 32, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  Languages.of(context)!.location_title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoItem(
              title: Languages.of(context)!.plate_no,
              value: widget.driver.licensePlateNo ?? "",
            ),
            _buildInfoItem(
              title: Languages.of(context)!.last_update,
              value: widget.driver.vehicle?.gps?.display_gpsdate ?? "",
            ),
            _buildInfoItem(
              title: Languages.of(context)!.location,
              value:
                  "${widget.driver.adminLevel3Name ?? ''} ${widget.driver.adminLevel2Name ?? ''} ${widget.driver.adminLevel1Name ?? ''}",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarChartCard({
    required String title,
    required String icon,
    required List<String> features,
    required List<double> avg,
    required List<double> point,
    required Color avgColor,
    required Color pointColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(icon, width: 32, color: Colors.grey),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            if (avg.isNotEmpty)
              RadarChart(
                length: avg.length,
                radius: 100,
                initialAngle: -(pi / 2),
                backgroundColor: Colors.white,
                borderStroke: 2,
                borderColor: Colors.grey.shade300,
                radialStroke: 1,
                radialColor: Colors.grey.shade300,
                vertices: [
                  for (int i = 0; i < features.length; i++)
                    RadarVertex(
                      radius: 15,
                      text: Text(features[i],
                          style: const TextStyle(fontSize: 10)),
                    ),
                ],
                radars: [
                  RadarTile(
                    values: point,
                    backgroundColor: pointColor.withOpacity(0.5),
                  ),
                  RadarTile(
                    values: avg,
                    borderStroke: 2,
                    borderColor: avgColor,
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 12, color: avgColor),
                const SizedBox(width: 4),
                Text(Languages.of(context)!.avg),
                const SizedBox(width: 12),
                Icon(Icons.circle, size: 12, color: pointColor),
                const SizedBox(width: 4),
                Text(Languages.of(context)!.score),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class RadarVertex extends StatelessWidget implements PreferredSizeWidget {
  const RadarVertex({
    super.key,
    required this.radius,
    this.text,
    this.textOffset,
  });

  final double radius;
  final Widget? text;
  final Offset? textOffset;

  @override
  Size get preferredSize => Size.fromRadius(radius);

  @override
  Widget build(BuildContext context) {
    Widget tree = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
    );

    if (text != null) {
      tree = Stack(
        alignment: Alignment.center,
        children: [
          tree,
          text!,
        ],
      );
    }

    return tree;
  }
}

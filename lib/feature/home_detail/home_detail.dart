import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/behavior.dart';
import 'package:hino/model/option_snapshot.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/model/vehicle_detail.dart';
import 'package:hino/page/home_detail_option_gallery.dart';
import 'package:hino/page/home_noti_event.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/timeago.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hino/utils/extension.dart';

class HomeDetailPage extends StatefulWidget {
  final Vehicle vehicle;

  const HomeDetailPage({Key? key, required this.vehicle}) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeDetailPage> {
  Vehicle? vehicle;
  VehicleDetail? vehicleDetail;
  bool isLoading = false;

  @override
  void initState() {
    vehicle = widget.vehicle;
    getData(context);
    super.initState();
  }

  launchMap(double lat, double long) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    if (await canLaunch(googleUrl))
      await launch(googleUrl);
    else
      throw 'Could not open the map.';
  }

  launchShare(String info, double lat, double long) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';
    Share.share(info + '\n' + googleUrl);
  }

  _launchCaller(String phone) async {
    var url = "tel:$phone";
    if (await canLaunch(url))
      await launch(url);
    else
      throw 'Could not launch $url';
  }

  getData(BuildContext context) {
    setState(() => isLoading = true);
    Api.get(context, Api.vid_detail + widget.vehicle.info!.vid.toString()).then(
        (value) => {vehicleDetail = VehicleDetail.fromJson(value), refresh()});
  }

  showDetail(String name) {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HomeNotiEventPage(name: name),
    );
  }

  refresh() {
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackIOS(),
              Container(
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    Utils.statusCarImage(widget.vehicle?.gps?.io_name ?? "",
                        widget.vehicle?.gps?.speed),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(vehicle?.info?.vehicle_name ?? "",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(vehicle?.info?.licenseprov ?? "",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: ColorCustom.greyBG2),
                      child: Column(
                        children: [
                          Text(vehicle?.gps?.speed.toStringAsFixed(0) ?? "",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          Text(Languages.of(context)!.km_h,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: ColorCustom.greyBG2),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/images/icon_profile.svg",
                            color: Colors.grey, width: 40, height: 40),
                        const SizedBox(width: 8),
                        Text(Languages.of(context)!.driver_title,
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        Expanded(child: Container()),
                        InkWell(
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorCustom.blue,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: 8, color: ColorCustom.blue)),
                            child: const Icon(Icons.notifications,
                                color: Colors.white),
                          ),
                          onTap: () =>
                              showDetail(vehicle?.driverCard?.name ?? ""),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Languages.of(context)!.driver,
                                  style: const TextStyle(
                                      color: ColorCustom.black, fontSize: 16)),
                              Text(
                                  vehicle!.driverCard!.name!.isEmpty
                                      ? Languages.of(context)!
                                          .unidentified_driver
                                      : vehicle!.driverCard!.name!,
                                  style: const TextStyle(
                                      color: ColorCustom.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Row(
                                children: [
                                  Icon(Icons.credit_card,
                                      size: 20,
                                      color: vehicle!.driverCard!
                                                  .status_swipe_card !=
                                              0
                                          ? Colors.green
                                          : Colors.grey),
                                  Text(
                                      vehicle!.driverCard!.status_swipe_card !=
                                              0
                                          ? Languages.of(context)!.swipe_card
                                          : Languages.of(context)!
                                              .no_swipe_card,
                                      style: const TextStyle(
                                          color: ColorCustom.black,
                                          fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  if (vehicleDetail != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: ColorCustom.greyBG2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset("assets/images/icon_gps.svg",
                                  color: Colors.grey, width: 40, height: 40),
                              const SizedBox(width: 8),
                              Text(Languages.of(context)!.location_title,
                                  style: const TextStyle(
                                      color: ColorCustom.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Expanded(child: Container()),
                              Container(
                                decoration: BoxDecoration(
                                    color: ColorCustom.blue,
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 8, color: ColorCustom.blue)),
                                child: InkWell(
                                    child: const Icon(Icons.refresh,
                                        color: Colors.white),
                                    onTap: () => getData(context)),
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                child: Image.asset(
                                    "assets/images/google-maps.png",
                                    height: 40,
                                    width: 40),
                                onTap: () => launchMap(vehicleDetail!.gps!.lat!,
                                    vehicleDetail!.gps!.lng!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Languages.of(context)!.last_update,
                                  style: const TextStyle(
                                      color: ColorCustom.black, fontSize: 16)),
                              Text(vehicleDetail!.gps!.formattedGpsDate,
                                  style: const TextStyle(
                                      color: ColorCustom.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(Languages.of(context)!.location,
                                  style: const TextStyle(
                                      color: ColorCustom.black, fontSize: 16)),
                              Text(
                                  "${vehicleDetail!.gps?.lat.toString() ?? ''}, ${vehicleDetail!.gps?.lng.toString() ?? ''}",
                                  style: const TextStyle(
                                      color: ColorCustom.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(Languages.of(context)!.specific_location,
                                  style: const TextStyle(
                                      color: ColorCustom.black, fontSize: 16)),
                              Text(
                                  "${vehicleDetail?.gps?.location?.admin_level1_name ?? ''} ${vehicleDetail?.gps?.location?.admin_level2_name ?? ''} ${vehicleDetail?.gps?.location?.admin_level3_name ?? ''}",
                                  style: const TextStyle(
                                      color: ColorCustom.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  overflow: TextOverflow.clip,
                                  maxLines: 3),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Text(
                                          vehicleDetail!.info!.geofence_name!,
                                          style: const TextStyle(
                                              color: ColorCustom.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: ColorCustom.blueLight,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Text(
                                        TimeAgo.timeAgoSinceDate(
                                            vehicleDetail!.gps!.gpsdate!),
                                        style: const TextStyle(
                                            color: ColorCustom.blue,
                                            fontSize: 14)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: ColorCustom.greyBG2),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/car_status.png",
                            height: 40, width: 40),
                        Text(Languages.of(context)!.status_vehicle,
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Expanded(child: Container()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Languages.of(context)!.mile,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text(
                            "${Utils.numberFormat(double.parse(vehicle!.info!.odo!))} ${Languages.of(context)!.km}",
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(Languages.of(context)!.fuel,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text("${vehicle!.gps!.fuel_per.toString()}%",
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(Languages.of(context)!.fuel_km,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text(
                            "${vehicle!.gps!.fuel_rate.toString()} ${Languages.of(context)!.km_l}",
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 20),
                        Text(Languages.of(context)!.gps,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text("${vehicle!.gps!.sattellite_per.toString()} %",
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(Languages.of(context)!.gsm,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text("${vehicle!.gps!.gsm_per.toString()} %",
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(Languages.of(context)!.dtc_engine,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text(
                            vehicleDetail?.sensor?.canbus?.dtcEngine == "0"
                                ? Languages.of(context)!.off
                                : Languages.of(context)!.on,
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
              if (vehicleDetail != null &&
                  vehicleDetail!.optionSnapshots.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorCustom.greyBG2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, size: 50, color: Colors.grey),
                          Text(Languages.of(context)!.option,
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Text(Languages.of(context)!.snapshot,
                                      style: const TextStyle(
                                          color: ColorCustom.black,
                                          fontSize: 16))),
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            HomeDetailOptionGalleryPage(
                                                optionSnapshots: vehicleDetail!
                                                    .optionSnapshots))),
                                child: Text(
                                    "${Languages.of(context)!.option_total} >",
                                    style: const TextStyle(
                                        color: ColorCustom.blue, fontSize: 16)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 4,
                            childAspectRatio: 4 / 3,
                            controller:
                                ScrollController(keepScrollOffset: false),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: vehicleDetail!.optionSnapshots
                                .map((OptionSnapshot value) {
                              return Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 80,
                                height: 80,
                                color: ColorCustom.greyBG,
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              HomeDetailOptionGalleryPage(
                                                  optionSnapshots:
                                                      vehicleDetail!
                                                          .optionSnapshots))),
                                  child: Image.network(value.url!),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                          Text(Languages.of(context)!.mvdr,
                              style: const TextStyle(
                                  color: ColorCustom.black, fontSize: 16)),
                          const SizedBox(height: 10),
                          Text(Languages.of(context)!.temperatures,
                              style: const TextStyle(
                                  color: ColorCustom.black, fontSize: 16)),
                          Text(
                              vehicleDetail != null
                                  ? "${vehicleDetail!.sensor!.temperature!.sensor1!}°C, ${vehicleDetail!.sensor!.temperature!.sensor2!}°C, ${vehicleDetail!.sensor!.temperature!.sensor3!}°C, ${vehicleDetail!.sensor!.temperature!.sensor4!}°C"
                                  : "",
                              style: const TextStyle(
                                  color: ColorCustom.blue, fontSize: 16)),
                          const Text('PTO',
                              style: TextStyle(
                                  color: ColorCustom.black, fontSize: 16)),
                          Text(
                              vehicleDetail != null
                                  ? vehicleDetail!.sensor!.option!.pto!
                                  : "",
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(Languages.of(context)!.door,
                              style: const TextStyle(
                                  color: ColorCustom.black, fontSize: 16)),
                          Text(
                              vehicleDetail != null
                                  ? vehicleDetail!.sensor!.option!.door_sensor!
                                  : "",
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(Languages.of(context)!.safety_belt,
                              style: const TextStyle(
                                  color: ColorCustom.black, fontSize: 16)),
                          Text(
                              vehicleDetail != null
                                  ? vehicleDetail!.sensor!.option!.safety_belt!
                                  : "",
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              if (vehicleDetail != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorCustom.greyBG2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.speed, size: 30, color: Colors.grey),
                            SizedBox(width: 8),
                            Text("Thông số",
                                style: TextStyle(
                                    color: ColorCustom.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ],
                        ),
                        Row(children: [
                          const Expanded(
                              child: Text("Mức dung dịch Urea",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.AdBlueTankLevel ?? '-'}%",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Giờ vận hành động cơ",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.EngineHour ?? '-'} h",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Mức nhiên liệu trong bình",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.FuelLevel ?? '-'}%",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Bàn đạp ga",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.accelerator ?? '-'}%",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("ODO",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.odo?.toKmString(
                                    showUnit: false,
                                    decimals: 0,
                                  ) ?? '-'} km",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Tốc độ",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.speed ?? '-'} km/h",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Vòng quay động cơ (RPM)",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text("${vehicleDetail!.new_canbus?.rpm ?? '-'}",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Phanh",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              vehicleDetail!.new_canbus?.Brake == "1"
                                  ? "ON"
                                  : "OFF",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Tải động cơ",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.EngineLoad ?? '-'}%",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Nhiệt độ chất làm mát",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text("${vehicleDetail!.new_canbus?.Temp ?? '-'} °C",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("L clutch",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              vehicleDetail!.new_canbus?.Cluth == "1"
                                  ? "ON"
                                  : "OFF",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Mức tiêu thụ nhiên liệu hiện tại",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.FuelConsumption_Lper100km ?? '-'} L./100km",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                        Row(children: [
                          const Expanded(
                              child: Text("Tổng lượng nhiên liệu sử dụng",
                                  style: TextStyle(
                                      color: ColorCustom.black, fontSize: 16))),
                          Text(
                              "${vehicleDetail!.new_canbus?.TotalFuelUse ?? '-'} L",
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16))
                        ]),
                      ]),
                ),
              if (vehicleDetail != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorCustom.greyBG2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_police,
                              size: 30, color: Colors.grey),
                          Text(Languages.of(context)!.dlt_regulation,
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (Behavior b in vehicleDetail!.listDlt)
                            Row(
                              children: [
                                Expanded(
                                    child: Text(Utils.mapDltName(b.name),
                                        style: const TextStyle(
                                            color: ColorCustom.black,
                                            fontSize: 16))),
                                Text(Utils.numberFormatInt(b.value),
                                    style: const TextStyle(
                                        color: ColorCustom.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (vehicleDetail != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(color: ColorCustom.greyBG2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.speed, size: 30, color: Colors.grey),
                          Text(Languages.of(context)!.driving_behavior,
                              style: const TextStyle(
                                  color: ColorCustom.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (Behavior b in vehicleDetail!.listBehavior)
                            Row(
                              children: [
                                Expanded(
                                    child: Text(Utils.mapDrivingName(b.name),
                                        style: const TextStyle(
                                            color: ColorCustom.black,
                                            fontSize: 16))),
                                Text(Utils.numberFormatInt(b.value),
                                    style: const TextStyle(
                                        color: ColorCustom.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border: Border.all(color: ColorCustom.greyBG2),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/car_status.png",
                            height: 40, width: 40),
                        Text(Languages.of(context)!.vehicle_title,
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Languages.of(context)!.plate_no,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text(vehicle!.info!.licenseplate!,
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(Languages.of(context)!.vin_no,
                            style: const TextStyle(
                                color: ColorCustom.black, fontSize: 16)),
                        Text(vehicle!.info!.vin_no.toString(),
                            style: const TextStyle(
                                color: ColorCustom.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

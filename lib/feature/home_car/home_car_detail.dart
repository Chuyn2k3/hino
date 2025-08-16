import 'package:flutter/material.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/member_group.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:provider/provider.dart';

class HomeCarDetailPage extends StatefulWidget {
  const HomeCarDetailPage({Key? key, required this.group}) : super(key: key);

  final MemberGroup group;

  @override
  State<HomeCarDetailPage> createState() => _HomeCarDetailPageState();
}

class _HomeCarDetailPageState extends State<HomeCarDetailPage> {
  List<Vehicle> listSearchDetail = [];

  @override
  void initState() {
    super.initState();
    listSearchDetail = List.from(widget.group.vehicle);
  }

  void _searchDetail(String value) {
    if (value.isEmpty) {
      listSearchDetail = List.from(widget.group.vehicle);
    } else {
      final query = value.toLowerCase();
      listSearchDetail = widget.group.vehicle.where((v) {
        final info = v.info!;
        return info.vin_no!.toLowerCase().contains(query) ||
            info.licenseplate!.toLowerCase().contains(query) ||
            info.licenseprov!.toLowerCase().contains(query) ||
            info.vehicle_name!.toLowerCase().contains(query);
      }).toSet().toList(); // loại trùng nếu có
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: BackIOS()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged: _searchDetail,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: ColorCustom.greyBG2,
                    hintText: lang.search,
                    prefixIcon: const Icon(Icons.search),
                    hintStyle: const TextStyle(fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.group.name!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorCustom.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 12),
                      decoration: BoxDecoration(
                        color: ColorCustom.blueLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${listSearchDetail.length} ${lang.unit}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: ColorCustom.blue,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final v = listSearchDetail[index];
                    return GestureDetector(
                      onTap: () {
                        context.read<PageProvider>().selectVehicle(v);
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/root'));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: ColorCustom.greyBG2),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Utils.statusCarImage(
                                v.gps!.io_name!, v.gps!.speed),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.info!.vehicle_name ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: ColorCustom.black,
                                    ),
                                  ),
                                  Text(
                                    v.info!.licenseprov!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorCustom.greyBG2,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    v.gps!.speed.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: ColorCustom.black,
                                    ),
                                  ),
                                  Text(
                                    lang.km_h,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: listSearchDetail.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

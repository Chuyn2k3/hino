import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home_car/home_car_detail.dart';
import 'package:hino/feature/home_car/home_car_filter.dart';
import 'package:hino/feature/home_car/home_car_sort.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/member.dart';
import 'package:hino/model/member_group.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/info.dart';
import 'package:hino/provider/page_provider.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class HomeCarPage extends StatefulWidget {
  const HomeCarPage({super.key});

  @override
  _HomeCarPageState createState() => _HomeCarPageState();
}

class _HomeCarPageState extends State<HomeCarPage> {
  bool isLoading = true, isError = false;
  String searchText = "";

  List<Member> listMember = [];
  List<MemberGroup> listNameGroup = [], listSearchGroup = [];
  List<Vehicle> listSearchVehicle = [];

  @override
  void initState() {
    super.initState();
    listSearchVehicle = List.from(listVehicle);
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    final value = await Api.get(context, Api.listmember);
    if (value != null) {
      listMember =
          (value['result'] as List).map((e) => Member.fromJson(e)).toList();
      _groupMembers();
      isError = false;
    } else {
      isError = true;
    }
    isLoading = false;
    setState(() {});
  }

  void _groupMembers() {
    final groups = groupBy(listMember, (Member m) => m.fleet_name);
    listNameGroup = groups.entries.map((e) {
      final mg = MemberGroup()..name = e.key;
      mg.members = e.value;
      mg.vehicle =
          listVehicle.where((v) => v.fleet!.fleet_name == e.key).toList();
      return mg;
    }).toList();
    listSearchGroup = List.from(listNameGroup)
      ..sort((a, b) => a.name!.compareTo(b.name!));
  }

  void _updateSearch([String? v]) {
    if (v != null) searchText = v;
    _searchVehicle(searchText);
    setState(() {});
  }

  void _searchVehicle(String q) {
    if (q.isEmpty) {
      listSearchVehicle = List.from(listVehicle);
    } else {
      final s = q.toLowerCase();
      listSearchVehicle = listVehicle.where((v) {
        final info = v.info!;
        return info.vin_no!.toLowerCase().contains(s) ||
            info.licenseplate!.toLowerCase().contains(s) ||
            info.licenseprov!.toLowerCase().contains(s) ||
            info.vehicle_name!.toLowerCase().contains(s);
      }).toList();
    }
  }

  void showCarList(MemberGroup group) {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeCarDetailPage(group: group),
    );
  }

  void showFilter() {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeCarFilterPage(
        filter: (value) {
          final result = listVehicle.where((v) {
            final speedOk = !value.isSpeed ||
                (v.gps!.speed >= value.minSpeed &&
                    v.gps!.speed <= value.maxSpeed);
            final fuelOk = !value.isFuel || v.gps!.fuel_per! >= value.fuel;
            final statusOk = !value.isStatus ||
                value.status.contains(v.gps!.io_name!.toLowerCase());
            return speedOk && fuelOk && statusOk;
          }).toList();

          listSearchVehicle = result;
          for (var m in listSearchGroup) {
            m.vehicle.clear();
            m.vehicle
                .addAll(result.where((v) => m.name == v.fleet!.fleet_name));
          }
          setState(() {});
        },
      ),
    );
  }

  void showSort(BuildContext context) {
    showMaterialModalBottomSheet(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeCarSortPage(
        select: (i) {
          switch (i) {
            case 0:
              listSearchGroup
                  .sort((a, b) => a.vehicle.length.compareTo(b.vehicle.length));
              break;
            case 1:
              listSearchGroup
                  .sort((a, b) => b.vehicle.length.compareTo(a.vehicle.length));
              break;
            case 2:
              listSearchGroup.sort((a, b) => a.name!.compareTo(b.name!));
              break;
            case 3:
              listSearchGroup.sort((a, b) => b.name!.compareTo(a.name!));
              break;
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _buildSearchBar() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        onChanged: _updateSearch,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: Languages.of(context)!.search,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: ColorCustom.blue, size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
                color: ColorCustom.blue, width: 1), // viền mặc định
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
                color: ColorCustom.blue, width: 1.5), // viền khi focus
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        ),
        style: const TextStyle(fontSize: 14),
      ));

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ActionChip(
          label: Text(
            label,
            style: const TextStyle(fontSize: 12, color: ColorCustom.blue),
          ),
          avatar: Icon(icon, size: 16, color: ColorCustom.blue),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: ColorCustom.blue.withOpacity(0.1)),
          ),
          elevation: 1,
          onPressed: onTap,
        ),
      );

  Widget _buildActionButtons() {
    final total = '${listSearchVehicle.length} ${Languages.of(context)!.unit}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionChip(
              Icons.filter_alt, Languages.of(context)!.filter, showFilter),
          _buildActionChip(Icons.sort_by_alpha, Languages.of(context)!.sort,
              () => showSort(context)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorCustom.blue.withOpacity(0.2)),
            ),
            child: Text(
              total,
              style: const TextStyle(
                color: ColorCustom.blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: ColorCustom.blue));
    }
    if (isError) {
      return Center(
        child: Text(
          Languages.of(context)!.please_try_again,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: listSearchVehicle.length,
      itemBuilder: (context, index) {
        final v = listSearchVehicle[index];
        return GestureDetector(
          onTap: () {
            context.read<PageProvider>().selectVehicle(v);
            Navigator.of(context).popUntil((r) => r.settings.name == '/root');
          },
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(18)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18)
                // gradient: LinearGradient(
                //   colors: [Colors.white, Colors.grey.shade100],
                //   begin: Alignment.topLeft,
                //   end: Alignment.bottomRight,
                // ),
                ,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: ColorCustom.blue.withOpacity(0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon trạng thái
                  Utils.statusCarImage(v.gps!.io_name!, v.gps!.speed),
                  const SizedBox(width: 14),

                  // Thông tin xe
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.info!.vehicle_name!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.pin_drop,
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              v.info!.licenseprov!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          v.info!.licenseplate ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColorCustom.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tốc độ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${v.gps!.speed.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorCustom.blue,
                        ),
                      ),
                      Text(
                        Languages.of(context)!.km_h,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackIOS(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      Languages.of(context)!.vehicle_list,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: ColorCustom.blue,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => InfoPage(count: 0),
                    ),
                    child: SvgPicture.asset(
                      "assets/images/Fix Icon Hino14.svg",
                      color: ColorCustom.blue,
                      width: 20,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildActionButtons(),
              ],
            ),
            _buildSearchBar(),
            Expanded(child: _buildVehicleList()),
          ],
        ),
      ),
    );
  }
}

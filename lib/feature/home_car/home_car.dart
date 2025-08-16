import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _HomeCarPageState extends State<HomeCarPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool isLoading = true, isError = false;
  String searchText = "";

  List<Member> listMember = [];
  List<MemberGroup> listNameGroup = [], listSearchGroup = [];
  List<Vehicle> listSearchVehicle = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 1);
    _tabController.addListener(_onTabChange);
    listSearchVehicle = List.from(listVehicle);
    _fetchMembers();
  }

  void _onTabChange() {
    searchText = "";
    _updateSearch();
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
    if (_tabController.index == 0) {
      _searchFleet(searchText);
    } else {
      _searchVehicle(searchText);
    }
    setState(() {});
  }

  void _searchFleet(String q) {
    if (q.isEmpty) {
      listSearchGroup = List.from(listNameGroup);
    } else {
      listSearchGroup = listNameGroup
          .where((g) => g.name!.toLowerCase().contains(q.toLowerCase()))
          .toList();
    }
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
        padding: const EdgeInsets.all(10),
        child: TextField(
          onChanged: _updateSearch,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorCustom.greyBG2,
            hintText: Languages.of(context)!.search,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );

  Widget _buildActionChip(IconData icon, String label, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.all(10),
        child: ActionChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          avatar: Icon(icon, size: 15),
          backgroundColor: ColorCustom.greyBG,
          onPressed: onTap,
        ),
      );

  Widget _buildActionButtons() {
    final index = _tabController.index;
    final total = index == 0
        ? '${listSearchGroup.length} Fleet'
        : '${listSearchVehicle.length} ${Languages.of(context)!.unit}';

    return Row(
      children: [
        if (index == 1)
          _buildActionChip(
              Icons.filter_alt, Languages.of(context)!.filter, showFilter),
        if (index == 0)
          _buildActionChip(Icons.sort_by_alpha, Languages.of(context)!.sort,
              () => showSort(context)),
        const Spacer(),
        // Container(
        //   margin: const EdgeInsets.only(right: 10),
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: ColorCustom.blueLight,
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        //   child: Text(
        //     total,
        //     style: const TextStyle(color: ColorCustom.blue, fontSize: 14),
        //   ),
        // )
      ],
    );
  }

  Widget _buildFleetTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isError) {
      return Center(child: Text(Languages.of(context)!.please_try_again));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: listSearchGroup.length,
      itemBuilder: (_, i) {
        final grp = listSearchGroup[i];
        return GestureDetector(
          onTap: () => showCarList(grp),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ColorCustom.greyBG2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                    child:
                        Text(grp.name!, style: const TextStyle(fontSize: 16))),
                Text('${grp.vehicle.length} ${Languages.of(context)!.unit}',
                    style: const TextStyle(
                        fontSize: 16,
                        color: ColorCustom.blue,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVehicleTab() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final v = listSearchVehicle[index];
                return GestureDetector(
                  onTap: () {
                    context.read<PageProvider>().selectVehicle(v);
                    Navigator.of(context)
                        .popUntil((r) => r.settings.name == '/root');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: ColorCustom.greyBG2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Utils.statusCarImage(v.gps!.io_name!, v.gps!.speed),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v.info!.vehicle_name!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                v.info!.licenseprov!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              v.gps!.speed.toStringAsFixed(0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              Languages.of(context)!.km_h,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: listSearchVehicle.length,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BackIOS(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => showDialog(
                        context: context, builder: (_) => InfoPage(count: 0)),
                    child: SvgPicture.asset(
                      "assets/images/Fix Icon Hino14.svg",
                      color: ColorCustom.blue,
                    ),
                  ),
                ),
              ],
            ),
            _buildSearchBar(),
            _buildActionButtons(),
            TabBar(
              controller: _tabController,
              tabs: [
                //Tab(text: lang.vehicle_group),
                Tab(text: lang.vehicle_list),
              ],
              indicatorColor: ColorCustom.primaryAssentColor,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: GoogleFonts.kanit(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // _buildFleetTab(),
                  _buildVehicleTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

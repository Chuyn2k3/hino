import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/noti.dart';
import 'package:hino/model/noti_group.dart';
import 'package:hino/page/home_noti_event.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomeNotiPage extends StatefulWidget {
  const HomeNotiPage({Key? key}) : super(key: key);

  @override
  State<HomeNotiPage> createState() => _HomeNotiPageState();
}

class _HomeNotiPageState extends State<HomeNotiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isSearching = false;

  List<Noti> _allNoti = [];
  late List<NotiGroup> _eventGroups, _carGroups, _driverGroups;
  List<NotiGroup> _carFiltered = [];
  List<NotiGroup> _driverFiltered = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);
    _fetchData();
  }

  void _onTabChanged() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _applyFilter();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final resp = await Api.post(
        context,
        Api.notify,
        jsonEncode({
          "user_id": Api.profile?.userId,
          "per_page": 500,
          "event_list": [1001, 10000, 10001]
        }));
    if (resp != null) {
      _allNoti = (resp['result'] as List).map((e) => Noti.fromJson(e)).toList();
      _groupData();
    }
    setState(() => _isLoading = false);
  }

  void _groupData() {
    final lang = Api.language;
    _eventGroups = [
      NotiGroup(name: lang == 'vi' ? 'Quá tốc độ' : 'Over Speed'),
      NotiGroup(name: lang == 'vi' ? 'Bảo dưỡng' : 'Maintenance Remind'),
      NotiGroup(name: lang == 'vi' ? 'Đèn cảnh báo' : 'Engine Lamp'),
    ];

    for (var noti in _allNoti) {
      if (noti.event_id == 1001) _eventGroups[0].notifications.add(noti);
      if (noti.event_id == 10000) _eventGroups[1].notifications.add(noti);
      if (noti.event_id == 10001) _eventGroups[2].notifications.add(noti);
    }

    _carGroups = _createGroup((n) => n.license ?? '');
    _driverGroups = _createGroup((n) => n.driver_name ?? '');

    _applyFilter();
  }

  List<NotiGroup> _createGroup(String Function(Noti) keyFn) {
    return groupBy(_allNoti, keyFn).entries.map((entry) {
      final key = entry.key;
      return NotiGroup(
        name: key,
        notifications: entry.value,
        vehicle: listVehicle.where((v) {
          return v.info?.licenseplate == key || v.driverCard?.name == key;
        }).toList(),
      );
    }).toList();
  }

  void _applyFilter([String query = '']) {
    final q = query.toLowerCase();
    _carFiltered = q.isEmpty
        ? List.from(_carGroups)
        : _carGroups
            .where((g) => g.name?.toLowerCase().contains(q) ?? false)
            .toList();
    _driverFiltered = q.isEmpty
        ? List.from(_driverGroups)
        : _driverGroups
            .where((g) => g.name?.toLowerCase().contains(q) ?? false)
            .toList();
  }

  void _onSearchChanged(String value) {
    _applyFilter(value);
    setState(() {});
  }

  void _openDetail(NotiGroup group) {
    showBarModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => HomeNotiEventPage(listData: group.notifications),
    );
  }

  Widget _buildList(List<NotiGroup> groups, {bool showVehicle = false}) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, idx) {
                final g = groups[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorCustom.primaryAssentColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        g.notifications.length.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: ColorCustom.primaryAssentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      g.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: ColorCustom.black,
                      ),
                    ),
                    subtitle: showVehicle && g.vehicle.isNotEmpty
                        ? Text(
                            g.vehicle.first.info?.licenseprov ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          )
                        : null,
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => _openDetail(g),
                  ),
                );
              },
              childCount: groups.length,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                BackIOS(),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.search,
                    size: 28,
                    color: _tabController.index == 0
                        ? Colors.grey
                        : ColorCustom.blue,
                  ),
                  onPressed: _tabController.index > 0
                      ? () {
                          setState(() => _isSearching = !_isSearching);
                        }
                      : null,
                ),
                const SizedBox(width: 8),
              ],
            ),
            if (_isSearching && _tabController.index > 0)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: lang.search,
                    filled: true,
                    fillColor: ColorCustom.greyBG2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: ColorCustom.primaryAssentColor,
                          labelStyle: GoogleFonts.kanit(),
                          tabs: [
                            Tab(text: lang.noti_event),
                            Tab(text: lang.noti_vehicle),
                            Tab(text: lang.noti_driver),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildList(_eventGroups),
                              _buildList(_carFiltered, showVehicle: true),
                              _buildList(_driverFiltered),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

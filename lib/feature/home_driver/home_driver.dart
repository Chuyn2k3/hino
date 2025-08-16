import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/driver.dart';
import 'package:hino/page/home_driver_detail.dart';
import 'package:hino/page/home_driver_sort.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomeDriverPage extends StatefulWidget {
  const HomeDriverPage({super.key});

  @override
  _HomeDriverPageState createState() => _HomeDriverPageState();
}

class _HomeDriverPageState extends State<HomeDriverPage> {
  List<Driver> _drivers = [], _filtered = [];
  String _lastUpdate = '';
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    final resp = await Api.get(context, Api.listdriver);
    if (resp != null) {
      _drivers = (resp['result'] as List)
          .map((e) => Driver.fromJson(e))
          .toList()
        ..sort((a, b) => b.datetimeSwipe!.compareTo(a.datetimeSwipe!));
      _filtered = List.from(_drivers);
      _lastUpdate = Utils.getDateTimeCreate();
      setState(() {});
    }
  }

  void _search(String q) {
    final lower = q.toLowerCase();
    _filtered = q.isEmpty
        ? List.from(_drivers)
        : _drivers.where((d) {
            return (d.firstname?.toLowerCase().contains(lower) ?? false) ||
                   (d.lastname?.toLowerCase().contains(lower) ?? false) ||
                   (d.score!.toString().contains(q)) ||
                   (d.licensePlateNo?.contains(q) ?? false) ||
                   (d.vehicleName?.toLowerCase().contains(lower) ?? false);
          }).toList();
    setState(() {});
  }

  void _openSort() {
    showMaterialModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => HomeDriverSortPage(select: (i) {
        switch (i) {
          case 0:
            _filtered.sort((a, b) => b.score!.compareTo(a.score!));
            break;
          case 1:
            _filtered.sort((a, b) => a.firstname!.compareTo(b.firstname!));
            break;
          case 2:
            _filtered.sort((a, b) => b.datetimeSwipe!.compareTo(a.datetimeSwipe!));
            break;
        }
        setState(() {});
      }),
    );
  }

  void _openDetail(Driver d) {
    showBarModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) => HomeDriverDetailPage(driver: d),
    );
  }

  Widget _buildScoreBadge(Driver d) {
    final lang = Languages.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorCustom.primaryAssentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorCustom.primaryAssentColor),
      ),
      child: Column(
        children: [
          Text(Utils.numberFormatInt(d.score!),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorCustom.primaryAssentColor)),
          const SizedBox(height: 2),
          Text(lang.score, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: !_isSearching
            ? Text(lang.unit_driver, style: GoogleFonts.kanit(color: Colors.black))
            : TextField(
                controller: _searchCtrl,
                onChanged: _search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: lang.search,
                  hintStyle: const TextStyle(fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: ColorCustom.primaryAssentColor),
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchCtrl.clear();
                _search('');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _fetchDrivers,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text('${lang.last_update} $_lastUpdate',
                      style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: _openSort,
                  icon: const Icon(Icons.sort, size: 16),
                  label: Text(lang.sort, style: const TextStyle(fontSize: 12)),
                ),
                const Spacer(),
                Text(
                  '${lang.total}: ${_filtered.length}',
                  style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(lang.please_try_again,
                        style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final d = _filtered[index];
                      return InkWell(
                        onTap: () => _openDetail(d),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.15)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: ColorCustom.primaryAssentColor,
                                      width: 2),
                                ),
                                child: ClipOval(
                                  child: d.photoUrl?.isNotEmpty == true
                                      ? FadeInImage.assetNetwork(
                                          placeholder:
                                              'assets/images/profile_empty.png',
                                          image: d.photoUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/profile_empty.png',
                                          width: 60,
                                          height: 60,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${d.prefix ?? ''} ${d.firstname ?? ''} ${d.lastname ?? ''}',
                                      style: GoogleFonts.kanit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Utils.swipeCard(d, context),
                                    if (d.display_datetime_swipe
                                            ?.isNotEmpty ==
                                        true)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          d.display_datetime_swipe!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87),
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if ((d.vehicleName?.isNotEmpty ?? false))
                                          Text(
                                            d.vehicleName!,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        if (d.vehicle?.info?.licenseprov
                                                ?.isNotEmpty ??
                                            false)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text(
                                              d.vehicle!.info!.licenseprov!,
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              _buildScoreBadge(d),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

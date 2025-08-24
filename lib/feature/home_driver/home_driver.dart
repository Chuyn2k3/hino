import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/driver.dart';
import 'package:hino/page/home_driver_detail.dart';
import 'package:hino/page/home_driver_sort.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/nfc_helper.dart';
import 'package:hino/utils/utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';

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
            _filtered
                .sort((a, b) => b.datetimeSwipe!.compareTo(a.datetimeSwipe!));
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorCustom.blue.withOpacity(0.8), ColorCustom.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorCustom.blue.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Text(Utils.numberFormatInt(d.score!),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(lang.score,
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
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

    return BaseScaffold(
      appBar: CustomAppbar.basic(
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => const AddDriverPage(), // màn thêm tài xế
                //   ),
                // );
              },
              icon: const Icon(Icons.person_add, size: 18, color: Colors.white),
              label: const Text(
                "Thêm tài xế",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorCustom.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
        isLeading: false,
        widgetTitle: !_isSearching
            ? Text(lang.unit_driver,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600))
            : TextField(
                controller: _searchCtrl,
                onChanged: _search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: lang.search,
                  hintStyle: const TextStyle(fontSize: 14),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.grey, // màu viền mặc định
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.grey, // viền khi chưa focus
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Colors.blue, // viền khi focus
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: ColorCustom.blue,
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Controls row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _fetchDrivers,
                    icon:
                        const Icon(Icons.refresh, size: 18, color: Colors.blue),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _openSort,
                    icon: const Icon(Icons.sort, size: 18, color: Colors.blue),
                    label:
                        Text(lang.sort, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text('${lang.total}: ${_filtered.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: _drivers.isEmpty
                ? _buildShimmerList() // 🔥 show shimmer khi chưa có data
                : _filtered.isEmpty
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
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: d.photoUrl?.isNotEmpty == true
                                        ? FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/profile_empty.png',
                                            image: d.photoUrl!,
                                            width: 64,
                                            height: 64,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 64,
                                            height: 64,
                                            color: Colors.blue[100],
                                            child: Icon(Icons.person,
                                                size: 32,
                                                color: Colors.blue[700]),
                                          ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${d.prefix ?? ''} ${d.firstname ?? ''} ${d.lastname ?? ''}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Utils.swipeCard(d, context),
                                        if (d.display_datetime_swipe
                                                ?.isNotEmpty ==
                                            true)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              d.display_datetime_swipe!,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54),
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if ((d.vehicleName?.isNotEmpty ??
                                                false))
                                              Text(
                                                d.vehicleName!,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black87),
                                              ),
                                            if (d.vehicle?.info?.licenseprov
                                                    ?.isNotEmpty ??
                                                false)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  d.vehicle!.info!.licenseprov!,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black54),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Thay cái này:
// _buildScoreBadge(d),

// Bằng nút Update:
                                  Column(
                                    children: [
                                      // Nút Xem
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  HomeDriverDetailPage(
                                                      driver: d),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ColorCustom.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                        child: const Text(
                                          "Xem",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 6),

                                      // Nút Ghi (NFC)
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (!await NfcHelper.isAvailable()) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      "NFC không khả dụng")),
                                            );
                                            return;
                                          }
                                          final payload =
                                              NfcHelper.buildPayload(
                                            license: d.card_id ??
                                                "", // lấy từ model Driver
                                            name:
                                                d.firstname ?? "${d.lastname}",
                                            extraData: '',
                                          );

                                          await NfcHelper.writeIso15693(
                                              payload);

                                          // Sau khi ghi, bạn có thể gọi API để báo đã ghi xong
                                          // await Api.post(
                                          //   context,
                                          //   Api.saveDriverNfc,
                                          //   body: {
                                          //     "driverId": d.id,
                                          //     "status": "nfc_written",
                                          //   },
                                          // );

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Đã ghi NFC cho tài xế")),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ColorCustom.blue,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text("Ghi",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
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

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6, // số lượng shimmer hiển thị
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 120, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 80, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 150, color: Colors.white),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

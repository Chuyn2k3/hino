import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/driver.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/page/home_driver_detail.dart';
import 'package:hino/page/home_driver_sort.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/iso15693_channel.dart';
import 'package:hino/utils/nfc_helper.dart';
import 'package:hino/utils/utils.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/text_converter.dart';

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
  Set<String> _writingNfcDrivers =
      {}; // Track which drivers are currently writing NFC
  bool _isReadingNfc = false; // Track NFC read operation
  bool _isNfcAvailable = false;
  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
    _fetchDrivers();
  }

  Future<void> _checkNfcAvailability() async {
    bool available = await NfcHelper.isNfcAvailable();
    setState(() {
      _isNfcAvailable = available;
    });
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

  Future<String?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('profile');
    if (jsonString == null) return null;
    print("jsonString $jsonString");
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final profile = Profile.fromJson(jsonData);
    print(profile.userId);
    return profile.userId?.toString();
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

  Future<void> _writeNfcCard(Driver driver) async {
    if (!_isNfcAvailable) {
      _showErrorDialog(
        "NFC không khả dụng",
        "Thiết bị không hỗ trợ NFC hoặc NFC đang bị tắt. Vui lòng kiểm tra cài đặt NFC.",
      );
      return;
    }
    String licenseNumber = driver.personalId ?? "";
    // String driverName =
    //     ((driver.firstname ?? "") + " " + (driver.lastname ?? "")).trim();
    String driverName =
        ((driver.firstname ?? "") + " " + (driver.lastname ?? ""))
            .normalize(); // chuẩn hóa tên
    String nfcDriverName = TextConverter.toAsciiForNfc(driverName);

    String driverId = driver.personalId ?? driver.firstname ?? "";
    //String nfcDriverName = TextConverter.toNfcFormat(driverName);
    String nfcLicenseNumber = TextConverter.toNfcFormat(licenseNumber);
    // Validate data first
    if (nfcDriverName.isEmpty || nfcLicenseNumber.isEmpty) {
      _showErrorDialog("Dữ liệu không hợp lệ",
          "Thông tin tài xế không đầy đủ hoặc chứa ký tự không hợp lệ.");
      return;
    }

    // Show NFC writing dialog
    _showNfcWritingDialog(driver, driverId, nfcLicenseNumber, nfcDriverName);
  }

  void _showNfcWritingDialog(
      Driver driver, String driverId, String licenseNumber, String driverName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nfc,
                  size: 64,
                  color: ColorCustom.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Ghi thẻ NFC",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Tài xế: ${driver.firstname ?? ''} ${driver.lastname ?? ''}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "GPLX: ${driver.personalId ?? 'N/A'}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.touch_app,
                          color: Colors.blue.shade600, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        "Vui lòng đặt mặt trước của thẻ vào vị trí nfc của máy",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _writingNfcDrivers.remove(driverId);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Hủy",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _writingNfcDrivers.remove(driverId);
      });
    });

    setState(() {
      _writingNfcDrivers.add(driverId);
    });

    _startNfcWriting(driverId, licenseNumber, driverName);
  }

  Future<void> _startNfcWriting(
      String driverId, String licenseNumber, String driverName) async {
    try {
      final userId = await getSavedUserId();
      print("userId2 $userId");
      await NfcHelper.writeCard(
        data: DriverCardData(
          licenseNumber: licenseNumber,
          driverName: driverName,
          userId: userId ?? "",
        ),
        onStatus: (status) {
          Navigator.of(context).pop(); // Close dialog
          _showSuccessDialog("Ghi NFC thành công!",
              "Thẻ NFC đã được ghi thông tin tài xế $driverName");
          // Update dialog with status
        },
        onError: (error) {
          Navigator.of(context).pop(); // Close dialog
          _showErrorDialog("Lỗi ghi NFC", error);
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close dialog
      _showErrorDialog("Lỗi ghi NFC", e.toString());
    }
  }

  Future<void> _readNfcCard() async {
    if (!_isNfcAvailable) {
      _showErrorDialog(
        "NFC không khả dụng",
        "Thiết bị không hỗ trợ NFC hoặc NFC đang bị tắt. Vui lòng kiểm tra cài đặt NFC.",
      );
      return;
    }
    _showNfcReadingDialog();
  }

  void _showNfcReadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nfc,
                  size: 64,
                  color: ColorCustom.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Đọc thẻ NFC",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.touch_app,
                          color: Colors.blue.shade600, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        "Vui lòng chạm thẻ vào máy",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isReadingNfc = false;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Hủy",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      setState(() {
        _isReadingNfc = false;
      });
    });

    setState(() {
      _isReadingNfc = true;
    });

    _startNfcReading();
  }

  Future<void> _startNfcReading() async {
    try {
      await NfcHelper.readCard(
        context: context,
        onCardRead: (data) {
          Navigator.of(context).pop(); // Close reading dialog
          _showCardInfoDialog(data);
        },
        onError: (error) {
          Navigator.of(context).pop(); // Close reading dialog
          _showErrorDialog("Lỗi đọc NFC", error);
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close reading dialog
      _showErrorDialog("Lỗi đọc NFC", e.toString());
    }
  }

  void _showCardInfoDialog(DriverCardData cardData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.credit_card, color: ColorCustom.blue, size: 28),
                    SizedBox(width: 12),
                    Text(
                      "Thông tin thẻ NFC",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tên tài xế:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardData.driverName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Số GPLX:",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cardData.licenseNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // const SizedBox(height: 16),
                      // Text(
                      //   "userId:",
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.grey.shade600,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   cardData.userId,
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.black87,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCustom.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Đóng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: Colors.green.shade700)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text("OK", style: TextStyle(color: ColorCustom.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: Colors.red.shade700)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text("OK", style: TextStyle(color: ColorCustom.blue)),
            ),
          ],
        );
      },
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
        flexibleSpace: !_isSearching
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Thêm màn thêm tài xế nếu cần
                        },
                        icon: const Icon(Icons.person_add,
                            size: 18, color: Colors.white),
                        label: const Text(
                          "Thêm tài xế",
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorCustom.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isNfcAvailable && !_isReadingNfc
                            ? _readNfcCard
                            : null,
                        icon: _isReadingNfc
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.nfc,
                                size: 18, color: Colors.white),
                        label: Text(
                          _isReadingNfc ? "Đang đọc..." : "Đọc thẻ",
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReadingNfc
                              ? Colors.grey.shade400
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        isLeading: false,
        widgetTitle: !_isSearching
            ? const SizedBox()
            // Text(lang.unit_driver,
            //         style: const TextStyle(
            //             color: Colors.black, fontWeight: FontWeight.w600))
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
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
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
              const SizedBox(width: 16),
              Text('${lang.total}: ${_filtered.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _drivers.isEmpty
                ? _buildShimmerList()
                : _filtered.isEmpty
                    ? Center(
                        child: Text(lang.please_try_again,
                            style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight,
                            left: 16,
                            right: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final d = _filtered[index];
                          String driverId = d.personalId ?? d.firstname ?? "";
                          bool isWritingNfc =
                              _writingNfcDrivers.contains(driverId);

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
                                                color: Colors.black87)),
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
                                                    color: Colors.black54)),
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if ((d.vehicleName?.isNotEmpty ??
                                                false))
                                              Text(d.vehicleName!,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87)),
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
                                  Column(
                                    children: [
                                      // ElevatedButton(
                                      //   onPressed: () => _openDetail(d),
                                      //   style: ElevatedButton.styleFrom(
                                      //     backgroundColor: ColorCustom.blue,
                                      //     foregroundColor: Colors.white,
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 10, vertical: 8),
                                      //     shape: RoundedRectangleBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(20)),
                                      //   ),
                                      //   child: const Text("Xem",
                                      //       style: TextStyle(
                                      //           fontSize: 12,
                                      //           fontWeight: FontWeight.w600)),
                                      // ),
                                      // const SizedBox(height: 6),
                                      ElevatedButton.icon(
                                        onPressed:
                                            _isNfcAvailable && !isWritingNfc
                                                ? () => _writeNfcCard(d)
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isWritingNfc
                                              ? Colors.grey.shade400
                                              : ColorCustom.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ),
                                        icon: isWritingNfc
                                            ? const SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white)))
                                            : const Icon(Icons.nfc, size: 14),
                                        label: Text(
                                            isWritingNfc
                                                ? "Đang ghi..."
                                                : "Ghi thẻ",
                                            style: const TextStyle(
                                                fontSize: 11,
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

  bool isAscii(String str) => str.codeUnits.every((c) => c <= 127);

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
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
                        borderRadius: BorderRadius.circular(40))),
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
                        borderRadius: BorderRadius.circular(20))),
              ],
            ),
          ),
        );
      },
    );
  }
}

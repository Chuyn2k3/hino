import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hino/api/api.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/driver.dart';
import 'package:hino/model/driver_detail.dart';
import 'package:hino/model/driver_info_create_model.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/snack_bar.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/custom_date_picker.dart';
import 'package:hino/widget/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:radar_chart/radar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/driver_info_model.dart';
import '../../model/driver_user_model.dart';
import '../../model/vehicle.dart';

class DriverManagementPage extends StatefulWidget {
  final Driver driver;

  const DriverManagementPage({Key? key, required this.driver})
      : super(key: key);

  @override
  State<DriverManagementPage> createState() => _DriverManagementPageState();
}

class _DriverManagementPageState extends State<DriverManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DriverDetail? driverDetail;
  bool _isLoading = false;
  bool _showVehicleTab = false;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _fetchDriverDetail();
  }

  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString("profile");

      if (profileString == null) {
        throw Exception("Không tìm thấy profile");
      }

      final profileJson = json.decode(profileString);
      _profile = Profile.fromJson(profileJson);
      setState(() {
        _showVehicleTab = (_profile?.userLevelId ?? 0) <= 41;
        _tabController = TabController(
          length: _showVehicleTab ? 4 : 3,
          vsync: this,
        );
      });
    } catch (e) {
      context.showSnackBarFail(
          text: "Lỗi khi lấy thông tin profile: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDriverDetail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await Api.get(
        context,
        "${Api.driver_detail}${widget.driver.driver_id!}",
      );
      if (res != null) {
        setState(() {
          driverDetail = DriverDetail.fromJson(res["result"]);
        });
      }
    } catch (e) {
      context.showSnackBarFail(text: "Lỗi khi lấy thông tin: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppbar.basic(
        title: 'Quản Lý Tài Xế',
        onTap: () => Navigator.pop(context),
      ),
      body: (_isLoading || driverDetail == null || _profile == null)
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  dividerColor: Colors.transparent,
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    const Tab(text: 'Lái xe'),
                    const Tab(text: 'Thông tin'),
                    const Tab(text: 'Tài khoản'),
                    if (_showVehicleTab) const Tab(text: 'Danh sách xe'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      DriverDetailTab(
                          driver: widget.driver, driverDetail: driverDetail!),
                      DriverInfoTab(
                          driver: widget.driver,
                          driverInfo: driverDetail!.driverInfo),
                      AccountTab(
                          driver: widget.driver,
                          driverUser: driverDetail!.driverUser,
                          driverInfo: driverDetail!.driverInfo,
                          driverName: driverDetail!.driverName),
                      if (_showVehicleTab)
                        VehicleListTab(
                            driverId: widget.driver.driver_id!,
                            vehicleIds:
                                (driverDetail!.driverUser?.vehicleIds ?? [])
                                    .whereType<int>()
                                    .toList()),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class DriverDetailTab extends StatefulWidget {
  final Driver driver;
  final DriverDetail driverDetail;

  const DriverDetailTab(
      {Key? key, required this.driver, required this.driverDetail})
      : super(key: key);

  @override
  State<DriverDetailTab> createState() => _DriverDetailTabState();
}

class _DriverDetailTabState extends State<DriverDetailTab> {
  double sumPoint = 0, sumPoint2 = 0;
  List<String> features = [], features2 = [];
  List<double> avg = [], point = [], avg2 = [], point2 = [];

  @override
  void initState() {
    super.initState();
    _initChart();
  }

  void _initChart() {
    sumPoint = 0;
    sumPoint2 = 0;
    features = widget.driverDetail.eco.map((e) => e.arg!).toList();
    avg =
        widget.driverDetail.eco.map((e) => e.avg! / 5).toList().cast<double>();
    point = widget.driverDetail.eco
        .map((e) => e.point! / 5)
        .toList()
        .cast<double>();
    sumPoint = widget.driverDetail.eco.fold(0, (sum, e) => sum + e.avg!);

    features2 = widget.driverDetail.safety.map((e) => e.arg!).toList();
    avg2 = widget.driverDetail.safety
        .map((e) => e.avg! / 5)
        .toList()
        .cast<double>();
    point2 = widget.driverDetail.safety
        .map((e) => e.point! / 5)
        .toList()
        .cast<double>();
    sumPoint2 = widget.driverDetail.safety.fold(0, (sum, e) => sum + e.avg!);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
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
    );
  }

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
                    value: widget.driverDetail != null
                        ? "${Utils.numberFormat(widget.driverDetail!.distance!)} ${Languages.of(context)!.km}"
                        : "",
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    title: Languages.of(context)!.driver_duration,
                    value: widget.driverDetail != null
                        ? "${widget.driverDetail!.totalTime!} ${Languages.of(context)!.h}"
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

class DriverInfoTab extends StatefulWidget {
  final Driver driver;
  final DriverInfoModel? driverInfo;

  const DriverInfoTab(
      {Key? key, required this.driverInfo, required this.driver})
      : super(key: key);

  @override
  State<DriverInfoTab> createState() => _DriverInfoTabState();
}

class _DriverInfoTabState extends State<DriverInfoTab> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cccdController = TextEditingController();
  final _gplxController = TextEditingController();

  String? _selectedPrefix;
  DateTime? _birthDate;
  DateTime? _startDate;
  DateTime? _cardExpiredDate;
  bool _isLoading = false;
  bool _isEditing = false;
  DriverInfoCreateModel? _originalDriverInfo;

  @override
  void initState() {
    super.initState();
    if (widget.driverInfo != null) {
      _originalDriverInfo =
          DriverInfoCreateModel.fromDriverInfoModel(widget.driverInfo!);
    }
    // danh sách hợp lệ
    final validPrefixes = ["Anh", "Chị", "Ông", "Bà", ""];

    // nếu prefix từ API không có trong list thì set về ""
    final prefixFromApi = widget.driverInfo?.prefix;
    _selectedPrefix =
        validPrefixes.contains(prefixFromApi) ? prefixFromApi : "";
    // _selectedPrefix = widget.driverInfo?.prefix ?? "Ông";
    _firstnameController.text = widget.driverInfo?.firstname ?? '';
    _lastnameController.text = widget.driverInfo?.lastname ?? '';
    _phoneController.text = widget.driverInfo?.phone ?? '';
    _addressController.text = widget.driverInfo?.fullAddress ?? '';
    _cccdController.text = widget.driverInfo?.personalId ?? '';
    _gplxController.text = widget.driverInfo?.cardId ?? '';
    _birthDate = widget.driverInfo?.birthDate;
    _startDate = widget.driverInfo?.startDate;
    _cardExpiredDate = widget.driverInfo?.cardExpiredDate;
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cccdController.dispose();
    _gplxController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, String field) async {
    final DateTime initialDate = field == 'birth'
        ? DateTime.now().subtract(const Duration(days: 365 * 20))
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: field == 'birth' ? DateTime(1950) : DateTime.now(),
      lastDate: field == 'expire' ? DateTime(2100) : DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (field == 'birth') {
          _birthDate = picked;
        } else if (field == 'start') {
          _startDate = picked;
        } else {
          _cardExpiredDate = picked;
        }
      });
    }
  }

  Future<bool> _showConfirmationDialog(String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Xác nhận $action tài xế'),
              content: Text(
                action == 'Xóa'
                    ? 'Bạn có chắc muốn xóa tài xế này? Hành động này không thể hoàn tác.'
                    : 'Bạn có chắc muốn lưu các thay đổi?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _updateDriver() async {
    if (!_formKey.currentState!.validate() ||
        _birthDate == null ||
        _selectedPrefix == null ||
        _startDate == null) {
      context.showSnackBarFail(text: 'Vui lòng điền đầy đủ thông tin bắt buộc');
      return;
    }

    final confirmed = await _showConfirmationDialog('Cập nhật');
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      final profileString = prefs.getString("profile");

      if (token == null || profileString == null) {
        throw Exception("Không tìm thấy token hoặc profile");
      }

      final profileJson = json.decode(profileString);
      final profile = Profile.fromJson(profileJson);
      final userId = profile.userId ?? 0;

      final url =
          "${Api.BaseUrlBuilding}${Api.updateDriver}/${widget.driver.driver_id}";
      final body = DriverInfoCreateModel(
        prefix: _selectedPrefix,
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        personalId: _cccdController.text.trim(),
        cardId: _gplxController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _birthDate!,
        startDate: _startDate!,
        fullAddress: _addressController.text.trim(),
        userId: userId,
        cardExpiredDate: _cardExpiredDate,
      );

      print("==== UPDATE DRIVER ====");
      print("Token: $token");
      print("Body: ${body.toString()}");
      print("Url: $url");
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body.toJson()),
      );

      print("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson["code"] == 200) {
          context.showSnackBarSuccess(
            text: "Cập nhật tài xế thành công!",
          );
          setState(() {
            _isEditing = false;
            _originalDriverInfo = body;
          });
        } else {
          throw Exception(responseJson["result"] ?? "Có lỗi xảy ra");
        }
      } else {
        throw Exception("Lỗi HTTP: ${response.body}");
      }
    } catch (e) {
      context.showSnackBarFail(
        text: e.toString(),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDriver() async {
    final confirmed = await _showConfirmationDialog('Xóa');
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString("accessToken");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      final profileString = prefs.getString("profile");

      if (token == null || profileString == null) {
        throw Exception("Không tìm thấy token hoặc profile");
      }

      final profileJson = json.decode(profileString);
      final profile = Profile.fromJson(profileJson);
      final userId = profile.userId ?? 0;
      if (token == null) {
        throw Exception("Không tìm thấy token");
      }

      final url =
          "${Api.BaseUrlBuilding}${Api.deleteDriver}/${widget.driver.driver_id}";

      print("==== DELETE DRIVER ====");
      print("Token: $token");
      print("Url: $url");
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({"user_id": userId}),
      );

      print("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson["code"] == 200) {
          context.showSnackBarSuccess(
            text: "Xóa tài xế thành công!",
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) Navigator.pop(context);
          });
        } else {
          throw Exception(responseJson["result"] ?? "Có lỗi xảy ra");
        }
      } else {
        throw Exception("Lỗi HTTP: ${response.body}");
      }
    } catch (e) {
      context.showSnackBarFail(
        text: e.toString(),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _isEditing = !_isEditing;
                              if (!_isEditing && _originalDriverInfo != null) {
                                _selectedPrefix = _originalDriverInfo!.prefix;
                                _firstnameController.text =
                                    _originalDriverInfo!.firstname ?? '';
                                _lastnameController.text =
                                    _originalDriverInfo!.lastname ?? '';
                                _phoneController.text =
                                    _originalDriverInfo!.phone ?? '';
                                _addressController.text =
                                    _originalDriverInfo!.fullAddress ?? '';
                                _cccdController.text =
                                    _originalDriverInfo!.personalId ?? '';
                                _gplxController.text =
                                    _originalDriverInfo!.cardId ?? '';
                                _birthDate = _originalDriverInfo!.birthDate;
                                _startDate = _originalDriverInfo!.startDate;
                                _cardExpiredDate =
                                    _originalDriverInfo!.cardExpiredDate;
                              }
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditing ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isEditing ? 'Hủy' : 'Chỉ xem'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Chức danh",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPrefix,
              hint: const Text(
                "Chức danh",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              dropdownColor: Colors.white,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              items: ["Anh", "Chị", "Ông", "Bà", ""]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _isEditing
                  ? (val) => setState(() => _selectedPrefix = val)
                  : null,
              validator: (val) =>
                  _isEditing && val == null ? "Vui lòng chọn chức danh" : null,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _firstnameController,
              label: "Họ",
              icon: Icons.person_outline,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _lastnameController,
              label: "Tên",
              icon: Icons.person_outline,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: "Số điện thoại",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              label: "Địa chỉ",
              icon: Icons.home,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _cccdController,
              label: "CCCD",
              icon: Icons.credit_card,
              enabled: false,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _gplxController,
              label: "GPLX",
              icon: Icons.drive_eta,
              enabled: false,
            ),
            const SizedBox(height: 16),
            CustomDatePickerField(
              label: "Ngày sinh",
              date: _birthDate,
              onTap: _isEditing ? () => _pickDate(context, 'birth') : () {},
            ),
            const SizedBox(height: 16),
            CustomDatePickerField(
              label: "Ngày bắt đầu làm việc",
              date: _startDate,
              onTap: _isEditing ? () => _pickDate(context, 'start') : () {},
            ),
            const SizedBox(height: 16),
            CustomDatePickerField(
              label: "Ngày hết hạn GPLX",
              date: _cardExpiredDate,
              onTap: _isEditing ? () => _pickDate(context, 'expire') : () {},
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        //()
                        //{},
                        _isLoading || !_isEditing ? null : _updateDriver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cập nhật thông tin'),
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        //() {},
                        _isLoading ? null : _deleteDriver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Xóa tài xế'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AccountTab extends StatefulWidget {
  final Driver driver;
  final DriverUserModel? driverUser;
  final DriverInfoModel? driverInfo;
  final String? driverName;

  const AccountTab(
      {Key? key,
      this.driverUser,
      this.driverName,
      this.driverInfo,
      required this.driver})
      : super(key: key);

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  bool _isCreatingAccount = false;
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: "123456"); // default

  //DateTime? _expiredDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isCreatingAccount = widget.driverUser == null;
    });

    print(widget.driverInfo?.toJson());
    _displayNameController.text = widget.driverName ?? '';
    _usernameController.text = 'hd${widget.driverInfo?.phone ?? ''}';
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    // final DateTime? picked = await showDatePicker(
    //   context: context,
    //   initialDate: DateTime.now(),
    //   firstDate: DateTime.now(),
    //   lastDate: DateTime(2100),
    // );

    // if (picked != null) {
    //   setState(() {
    //     _expiredDate = picked;
    //   });
    // }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      context.showSnackBarFail(text: 'Vui lòng điền đầy đủ thông tin bắt buộc');
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Xác nhận tạo tài khoản'),
              content:
                  const Text('Bạn có chắc muốn tạo tài khoản cho tài xế này?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      final profileString = prefs.getString("profile");

      if (token == null || profileString == null) {
        throw Exception("Không tìm thấy token hoặc profile");
      }

      final profileJson = json.decode(profileString);
      final profile = Profile.fromJson(profileJson);

      final url = "${Api.BaseUrlBuilding}${Api.createDriverUser}";
      final body = {
        "driver_id": widget.driver.driver_id,
        "display_name": _displayNameController.text.trim(),
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "mobile": widget.driverInfo?.phone ?? "", // mặc định phone của tài xế
        "owner_partner_id": profile.userId,
        "user_id": profile.userId,
      };

      print("==== CREATE DRIVER ACCOUNT ====");
      print("Token: $token");
      print("Body: ${json.encode(body)}");
      print("Url: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      );

      print("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        if (responseJson["code"] == 200) {
          context.showSnackBarSuccess(text: "Tạo tài khoản thành công!");
          setState(() {
            _isCreatingAccount = false;
          });
          if (context.mounted) {
            final parentState =
                context.findAncestorStateOfType<_DriverManagementPageState>();
            parentState?._fetchDriverDetail();
          }
        } else {
          throw Exception(responseJson["result"] ?? "Có lỗi xảy ra");
        }
      } else {
        throw Exception("Lỗi HTTP: ${response.body}");
      }
    } catch (e) {
      context.showSnackBarFail(text: "Lỗi: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _callHotline() async {
    final Uri url = Uri(scheme: 'tel', path: '19009082');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      context.showSnackBarFail(text: "Không thể thực hiện cuộc gọi");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.driverUser == null && !_isCreatingAccount) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tài xế chưa có tài khoản',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isCreatingAccount = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tạo tài khoản'),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _callHotline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.call),
                label: const Text("Liên hệ tổng đài 19009082"),
              ),
            ),
          ],
        ),
      );
    }

    if (_isCreatingAccount) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _displayNameController,
                label: "Tên hiển thị *",
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                label: "Tên tài khoản *",
                icon: Icons.account_circle,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: "Mật khẩu",
                icon: Icons.lock,
              ),
              const SizedBox(height: 8),
              const Text(
                "Mật khẩu mặc định: 123456",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              // const SizedBox(height: 16),
              // CustomDatePickerField(
              //   label: "Ngày hết hạn",
              //   date: _expiredDate,
              //   onTap: () => _pickDate(context),
              // ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isCreatingAccount = false;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          //() {},
                          _isLoading ? null : _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Tạo tài khoản'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _callHotline,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text("Liên hệ tổng đài 19009082"),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final user = widget.driverUser;
    if (user != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Tên hiển thị", user.displayName),
            _buildInfoRow("Tên tài khoản", user.username),
            _buildInfoRow("Số điện thoại", user.mobile),
            _buildInfoRow("E-mail", user.email),
            _buildInfoRow(
              "Ngày hết hạn",
              user.expiredDate != null
                  ? DateFormat("dd/MM/yyyy").format(user.expiredDate!)
                  : "Chưa có",
            ),
            _buildInfoRow("Ngôn ngữ mặc định", "Vietnam"),
            const SizedBox(height: 16),
            _buildAvatar(user.avatarAttachId),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _callHotline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.call),
                label: const Text("Liên hệ tổng đài 19009082"),
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: Column(
        children: [
          const Text(
            'Thông tin tài khoản (Chưa triển khai đầy đủ)',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _callHotline,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.call),
              label: const Text("Liên hệ tổng đài 19009082"),
            ),
          ),
        ],
      ),
    );
  }

  /// hiển thị một dòng thông tin
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                value ?? "-",
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// hiển thị avatar với fallback
  Widget _buildAvatar(String? avatarId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ảnh hồ sơ",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: avatarId != null
                ? Image.network(
                    "${Api.BaseUrlBuilding}/file/$avatarId",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.account_circle,
                          size: 60, color: Colors.grey);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : const Icon(Icons.account_circle,
                    size: 60, color: Colors.grey),
          ),
        ),
      ],
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

class VehicleListTab extends StatefulWidget {
  final int driverId;
  final List<int> vehicleIds;

  const VehicleListTab({
    Key? key,
    required this.driverId,
    required this.vehicleIds,
  }) : super(key: key);

  @override
  State<VehicleListTab> createState() => _VehicleListTabState();
}

class _VehicleListTabState extends State<VehicleListTab>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _assignedVehicles = [];
  Set<int> _selectedVehicles = {};
  bool _isAllVehiclesLoaded = false;
  bool _selectAll = false;
  bool _indeterminate = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo animation controller và fade animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Đảm bảo animation bắt đầu từ đầu
    _animationController.value = 0.0;
    _loadAllVehicles();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Cập nhật select all logic với vid
  void _updateSelectAllState() {
    final validAssignedVehicles = _assignedVehicles
        .where((vehicle) => vehicle.info?.vid != null)
        .toList();

    if (validAssignedVehicles.isEmpty) {
      _selectAll = false;
      _indeterminate = false;
    } else {
      final validSelectedCount = _selectedVehicles
          .where((id) => validAssignedVehicles.any((v) => v.info?.vid == id))
          .length;

      if (validSelectedCount == validAssignedVehicles.length) {
        _selectAll = true;
        _indeterminate = false;
      } else if (validSelectedCount > 0) {
        _selectAll = false;
        _indeterminate = true;
      } else {
        _selectAll = false;
        _indeterminate = false;
      }
    }
  }

  Future<void> _loadAllVehicles() async {
    setState(() {
      _isLoading = true;
      _isAllVehiclesLoaded = false;
    });

    try {
      final value = await Api.get(context, Api.realtime);
      if (value != null && mounted) {
        final listVehicle = List.from(value['vehicles'])
            .map((a) => Vehicle.fromJson(a))
            .toList();

        setState(() {
          _allVehicles = listVehicle;
          _assignedVehicles = listVehicle
              .where((vehicle) =>
                  vehicle.info?.vid != null &&
                  widget.vehicleIds.contains(vehicle.info!.vid!))
              .toList();
          _isAllVehiclesLoaded = true;
          _updateSelectAllState();
        });

        // Trigger animation sau khi data được load
        if (mounted) {
          _animationController.forward();
        }
      }
    } catch (e) {
      context.showSnackBarFail(
          text: "Lỗi khi tải danh sách xe: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAddVehicleDialog() async {
    if (!_isAllVehiclesLoaded) {
      context.showSnackBarInfo(text: 'Đang tải danh sách xe...');
      return;
    }

    final availableVehicles = _allVehicles
        .where((vehicle) =>
            vehicle.info?.vid != null &&
            !widget.vehicleIds.contains(vehicle.info!.vid!))
        .toList();

    if (availableVehicles.isEmpty) {
      context.showSnackBarFail(text: 'Không có xe nào để thêm');
      return;
    }

    final selectedVehicleIds = <int>{};

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _VehicleSelectionDialog(
          title: 'Thêm xe',
          vehicles: availableVehicles,
          selectedVehicleIds: selectedVehicleIds,
          onConfirm: (selectedIds) {
            Navigator.pop(context);
            _addSelectedVehicles(selectedIds);
          },
        );
      },
    );
  }

  Future<void> _addSelectedVehicles(List<int> vehicleIds) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _updateVehicleAssignment(vehicleIds, 'INSERT');

      if (response != null && response["code"] == 200) {
        context.showSnackBarSuccess(
            text: "Đã thêm ${vehicleIds.length} xe thành công!");
        await _loadAllVehicles();
        _refreshParent();
      }
    } catch (e) {
      context.showSnackBarFail(
        text: "Lỗi: ${e.toString()}",
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSelectedVehicles() async {
    if (_selectedVehicles.isEmpty) {
      context.showSnackBarFail(
        text: 'Vui lòng chọn xe để xóa',
      );
      return;
    }

    final confirmed = await _showConfirmationDialog(
      'Xác nhận xóa xe',
      'Bạn có chắc muốn xóa ${_selectedVehicles.length} xe khỏi danh sách?',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicleIds = _selectedVehicles.toList();
      final response = await _updateVehicleAssignment(vehicleIds, 'DELETE');

      if (response != null && response["code"] == 200) {
        context.showSnackBarSuccess(
            text: "Đã xóa ${_selectedVehicles.length} xe thành công!");
        setState(() {
          _selectedVehicles.clear();
        });
        await _loadAllVehicles();
        _refreshParent();
      }
    } catch (e) {
      context.showSnackBarFail(
        text: "Lỗi: ${e.toString()}",
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _updateVehicleAssignment(
    List<int> vehicleIds,
    String action,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("accessToken");
      final profileString = prefs.getString("profile");

      if (token == null || profileString == null) {
        throw Exception("Không tìm thấy token hoặc profile");
      }

      final profileJson = json.decode(profileString);
      final profile = Profile.fromJson(profileJson);
      final userId = profile.userId ?? 0;

      final url = "${Api.BaseUrlBuilding}${Api.updateVehicleAssignment}";
      final List<Map<String, dynamic>> vehicleManager = [];

      for (int vehicleId in vehicleIds) {
        vehicleManager.add({
          "vehicle_id": vehicleId,
          "action": action,
        });
      }

      final payload = {
        "vehicle_manager": vehicleManager,
        "user_id": userId,
        "driver_id": widget.driverId,
      };

      print("==== ${action.toUpperCase()} VEHICLES ====");
      print("Token: $token");
      print("Body: ${json.encode(payload)}");
      print("Url: $url");

      final response = await Api.post(
        context,
        url,
        json.encode(payload),
        accessToken: "Bearer $token",
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  void _onVehicleSelected(bool? selected, int? vehicleId) {
    if (vehicleId == null) return;

    setState(() {
      if (selected == true) {
        _selectedVehicles.add(vehicleId);
      } else {
        _selectedVehicles.remove(vehicleId);
      }
      _updateSelectAllState();
    });
  }

  void _onSelectAllChanged(bool? value) {
    setState(() {
      if (value == true) {
        _selectedVehicles = _assignedVehicles
            .where((v) => v.info?.vid != null)
            .map((v) => v.info!.vid!)
            .toSet();
      } else {
        _selectedVehicles.clear();
      }
      _updateSelectAllState();
    });
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    if (!mounted) return false;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                content,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Xóa',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _refreshParent() {
    if (context.mounted) {
      final parentState =
          context.findAncestorStateOfType<_DriverManagementPageState>();
      parentState?._fetchDriverDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Action buttons
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_circle_outline,
                    label: 'Thêm xe mới',
                    color: Colors.blue,
                    onPressed: _isLoading ? null : _showAddVehicleDialog,
                    iconColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_outline,
                    label: 'Xóa xe (${_selectedVehicles.length})',
                    color: Colors.red,
                    onPressed: _isLoading || _selectedVehicles.isEmpty
                        ? null
                        : _deleteSelectedVehicles,
                    iconColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Loading indicator for empty state
          if (_isLoading && _assignedVehicles.isEmpty)
            _buildShimmerTable()
          // Empty state
          else if (!_isLoading && _assignedVehicles.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[100]!,
                            Colors.grey[200]!,
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Chưa có xe nào được gán',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nhấn "Thêm xe mới" để bắt đầu quản lý phương tiện cho tài xế',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Thêm xe ngay',
                      color: Colors.blue,
                      onPressed: _showAddVehicleDialog,
                      iconColor: Colors.white,
                      size: 'large',
                    ),
                  ],
                ),
              ),
            )
          // Table section
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Table header - CHỈ HIỆN KHI KHÔNG LOADING
                if (!_isLoading)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue[50]!,
                          Colors.blue[100]!.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // Main Select All Checkbox
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: _selectAll,
                            tristate: _indeterminate,
                            onChanged: _assignedVehicles.isEmpty
                                ? null
                                : _onSelectAllChanged,
                            activeColor: Colors.blue[600],
                            checkColor: Colors.white,
                            side: MaterialStateBorderSide.resolveWith(
                              (states) => BorderSide(
                                width: 2,
                                color: Colors.blue[300]!,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chọn tất cả',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_selectedVehicles.length}/${_assignedVehicles.where((v) => v.info?.vid != null).length} xe được chọn',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Table container với CIRCULAR LOADING
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? _buildShimmerTable() // Circular loading table
                      : _isAllVehiclesLoaded
                          ? FadeTransition(
                              opacity: _fadeAnimation,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _buildDataTable(),
                              ),
                            )
                          : _buildShimmerTable(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Header shimmer
          Container(
            height: 40,
            color: Colors.blue[50],
            child: Row(
              children: [
                _buildShimmerCell(
                    width: 20, height: 20, margin: 12), // checkbox col
                _buildShimmerCell(
                    width: 100, height: 16, margin: 12), // biển số
                _buildShimmerCell(width: 140, height: 16, margin: 12), // VIN
              ],
            ),
          ),
          const Divider(height: 1),
          // Rows shimmer
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey[200]),
            itemBuilder: (context, index) {
              return Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _buildShimmerCell(
                        width: 20, height: 20, radius: 4), // checkbox
                    const SizedBox(width: 12),
                    _buildShimmerCell(width: 80, height: 14), // biển số
                    const SizedBox(width: 32),
                    _buildShimmerCell(width: 120, height: 14), // VIN
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 👉 shimmer cell riêng lẻ
  Widget _buildShimmerCell({
    double width = 60,
    double height = 16,
    double radius = 6,
    double margin = 0,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.all(margin),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  // DataTable widget - CHỈ CÓ 1 CHECKBOX TRONG MỖI ROW
  Widget _buildDataTable() {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Colors.blue[50]),
      headingRowHeight: 32,
      dataRowHeight: 48,
      border: TableBorder.all(
        color: Colors.grey[200]!,
        width: 1,
      ),
      columnSpacing: 16,
      columns: const [
        // Checkbox column - KHÔNG CÓ LABEL
        DataColumn(
          label: Text(''),
        ),
        DataColumn(
          label: Text(
            'Biển số xe',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            'Số VIN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
      rows: _assignedVehicles.asMap().entries.map((entry) {
        final index = entry.key;
        final vehicle = entry.value;
        final vehicleId = vehicle.info?.vid;
        final isSelected =
            vehicleId != null && _selectedVehicles.contains(vehicleId);
        final isEvenRow = index % 2 == 0;

        return DataRow(
          // LOẠI BỎ selected để tránh double checkbox effect
          // LOẠI BỎ onSelectChanged của DataRow
          color: MaterialStateProperty.all(
            isEvenRow ? Colors.grey[50] : Colors.white,
          ),
          cells: [
            // Checkbox cell - CHỈ CÓ 1 CHECKBOX VỚI INKWELL
            DataCell(
              InkWell(
                onTap: vehicleId != null
                    ? () => _onVehicleSelected(!isSelected, vehicleId)
                    : null,
                // borderRadius: BorderRadius.circular(4),
                child: Center(
                  child: Transform.scale(
                    scale: 1.1,
                    child: Align(
                      alignment:
                          Alignment.centerLeft, // 👈 đảm bảo nằm giữa cell
                      child: Checkbox(
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // 👈 bỏ padding mặc định
                        visualDensity: VisualDensity.compact,
                        value: isSelected,
                        onChanged: vehicleId != null
                            ? (bool? value) {
                                _onVehicleSelected(value, vehicleId);
                              }
                            : null,
                        activeColor: Colors.blue[600],
                        checkColor: Colors.white,
                        side: MaterialStateBorderSide.resolveWith(
                          (states) => BorderSide(
                            width: 2,
                            color:
                                isSelected ? Colors.blue[300]! : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // License plate cell
            DataCell(
              InkWell(
                onTap: vehicleId != null
                    ? () => _onVehicleSelected(!isSelected, vehicleId)
                    : null,
                child: Text(
                  vehicle.info?.licenseplate ?? 'N/A',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                    color: isSelected ? Colors.blue[700] : Colors.black87,
                  ),
                ),
              ),
            ),
            // VIN cell
            DataCell(
              InkWell(
                onTap: vehicleId != null
                    ? () => _onVehicleSelected(!isSelected, vehicleId)
                    : null,
                child: Text(
                  vehicle.info?.vin_no ?? 'N/A',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                    color: isSelected ? Colors.blue[700] : Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required Color iconColor,
    String size = 'normal',
  }) {
    final isDisabled = onPressed == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: size == 'large' ? 24 : 20,
          color: isDisabled ? Colors.white54 : iconColor,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: size == 'large' ? 16 : 14,
            color: isDisabled ? Colors.white54 : Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? color.withOpacity(0.6) : color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: size == 'large' ? 16 : 14,
            horizontal: size == 'large' ? 28 : 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDisabled ? 0 : 4,
          shadowColor: isDisabled ? null : color.withOpacity(0.3),
        ),
      ),
    );
  }
}

// Enhanced Vehicle Selection Dialog
class _VehicleSelectionDialog extends StatefulWidget {
  final String title;
  final List<Vehicle> vehicles;
  final Set<int> selectedVehicleIds;
  final Function(List<int>) onConfirm;

  const _VehicleSelectionDialog({
    required this.title,
    required this.vehicles,
    required this.selectedVehicleIds,
    required this.onConfirm,
  });

  @override
  State<_VehicleSelectionDialog> createState() =>
      _VehicleSelectionDialogState();
}

class _VehicleSelectionDialogState extends State<_VehicleSelectionDialog>
    with TickerProviderStateMixin {
  late Set<int> _selectedIds;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedVehicleIds.toSet();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Hàm tìm kiếm theo biển số hoặc mã VIN
  List<Vehicle> _searchVehicles(String query) {
    if (query.isEmpty) return widget.vehicles;
    return widget.vehicles.where((v) {
      final license = (v.info?.licenseplate ?? "").toLowerCase();
      final vin = (v.info?.vin_no ?? "").toLowerCase();
      return license.contains(query.toLowerCase()) ||
          vin.contains(query.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVehicles = _searchVehicles(_searchQuery);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.blue],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "${_selectedIds.length} xe",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm theo biển số hoặc VIN...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.trim());
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Danh sách xe
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 500,
                    minHeight: 300,
                  ),
                  child: filteredVehicles.isEmpty
                      ? const Center(
                          child: Text(
                            "Không tìm thấy xe",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredVehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = filteredVehicles[index];
                            final id = vehicle.info?.vid;
                            if (id == null) return const SizedBox.shrink();

                            final isSelected = _selectedIds.contains(id);

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: isSelected ? 6 : 2,
                              shadowColor: isSelected
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.05),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedIds.remove(id);
                                    } else {
                                      _selectedIds.add(id);
                                    }
                                  });
                                },
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? Colors.blue[600]
                                      : Colors.grey[200],
                                  child: Icon(
                                    Icons.directions_car,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                                title: Text(
                                  vehicle.info?.licenseplate ?? "N/A",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                subtitle: Text(
                                  "VIN: ${vehicle.info?.vin_no ?? "N/A"}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green, size: 28)
                                    : const Icon(Icons.circle_outlined,
                                        color: Colors.grey, size: 26),
                              ),
                            );
                          },
                        ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.blue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Hủy",
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : () => widget.onConfirm(_selectedIds.toList()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          "Thêm ${_selectedIds.length} xe",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
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

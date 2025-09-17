import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hino/api/api.dart';
import 'package:hino/feature/home_driver/vehicle_list_tab.dart';
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
import 'package:url_launcher/url_launcher.dart';

import '../../model/driver_info_model.dart';
import '../../model/driver_user_model.dart';

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
        _showVehicleTab = (_profile?.userLevelId ?? 0) > 41;
        _tabController = TabController(
          length: _showVehicleTab ? 4 : 3,
          vsync: this,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi lấy thông tin profile: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi khi lấy thông tin: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
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
  final DriverUserModel? driverUser;
  final DriverInfoModel? driverInfo;
  final String? driverName;

  const AccountTab(
      {Key? key, this.driverUser, this.driverName, this.driverInfo})
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

  DateTime? _expiredDate;
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _expiredDate = picked;
      });
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
          backgroundColor: Colors.red,
        ),
      );
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

      if (token == null) {
        throw Exception("Không tìm thấy token");
      }

      final url = "${Api.BaseUrlBuilding}${Api.createDriverUser}";
      final body = {
        "display_name": _displayNameController.text.trim(),
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "expired_date": _expiredDate != null
            ? DateFormat("yyyy-MM-dd").format(_expiredDate!)
            : null,
        "password": _passwordController.text.trim(),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tạo tài khoản thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isCreatingAccount = false;
          });
          // Refresh driver detail
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không thể thực hiện cuộc gọi")),
      );
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
              const SizedBox(height: 16),
              CustomDatePickerField(
                label: "Ngày hết hạn",
                date: _expiredDate,
                onTap: () => _pickDate(context),
              ),
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

class _VehicleListTabState extends State<VehicleListTab> {
  bool _isLoading = false;
  Map<int, bool> _vehicleSelection = {};
  final TextEditingController _newVehicleIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vehicleSelection = {for (var id in widget.vehicleIds) id: true};
  }

  @override
  void dispose() {
    _newVehicleIdController.dispose();
    super.dispose();
  }

  void _addVehicleId() {
    final input = _newVehicleIdController.text.trim();
    if (input.isNotEmpty && int.tryParse(input) != null) {
      final vehicleId = int.parse(input);
      setState(() {
        if (!_vehicleSelection.containsKey(vehicleId)) {
          _vehicleSelection[vehicleId] = true;
          _newVehicleIdController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID xe đã tồn tại trong danh sách'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ID xe hợp lệ'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateVehicleAssignments() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Xác nhận thay đổi'),
              content: const Text('Bạn có chắc muốn lưu các thay đổi này?'),
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
      final userId = profile.userId ?? 0;

      final url = "${Api.BaseUrlBuilding}${Api.updateVehicleAssignment}";
      final List<Map<String, dynamic>> vehicleManager = [];

      _vehicleSelection.forEach((vehicleId, isSelected) {
        final wasAssigned = widget.vehicleIds.contains(vehicleId);
        if (isSelected != wasAssigned) {
          vehicleManager.add({
            "vehicle_id": vehicleId,
            "action": isSelected ? "INSERT" : "DELETE",
          });
        }
      });

      if (vehicleManager.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không có thay đổi để cập nhật'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final payload = {
        "vehicle_manager": vehicleManager,
        "user_id": userId,
        "driver_id": widget.driverId,
      };

      print("==== UPDATE VEHICLE ASSIGNMENTS ====");
      print("Token: $token");
      print("Body: ${json.encode(payload)}");
      print("Url: $url");

      final response = await Api.post(
        context,
        url,
        json.encode(payload),
        accessToken: "Bearer $token",
      );

      if (response == null) {
        throw Exception("Không nhận được phản hồi từ server");
      }

      if (response["code"] != 200) {
        throw Exception(response["result"] ?? "Có lỗi xảy ra");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật danh sách xe thành công!"),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh driver detail to update vehicleIds
      if (context.mounted) {
        final parentState =
            context.findAncestorStateOfType<_DriverManagementPageState>();
        await parentState?._fetchDriverDetail();
        if (context.mounted) {
          setState(() {
            _vehicleSelection = {for (var id in widget.vehicleIds) id: true};
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách xe',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newVehicleIdController,
                  decoration: InputDecoration(
                    labelText: 'Nhập ID xe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.5),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _addVehicleId,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thêm'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_vehicleSelection.isEmpty)
            const Text(
              'Không có xe nào',
              style: TextStyle(color: Colors.grey),
            )
          else
            ..._vehicleSelection.entries.map((entry) {
              final vehicleId = entry.key;
              final isChecked = entry.value;
              return CheckboxListTile(
                title: Text('Xe $vehicleId'),
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    _vehicleSelection[vehicleId] = value ?? false;
                  });
                },
              );
            }).toList(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading || _vehicleSelection.isEmpty
                  ? null
                  : _updateVehicleAssignments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xác nhận'),
            ),
          ),
        ],
      ),
    );
  }
}

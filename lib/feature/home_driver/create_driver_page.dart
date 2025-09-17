import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hino/api/api.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/snack_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/driver_info_create_model.dart';
import '../../model/driver_info_model.dart';
import '../../widget/custom_date_picker.dart';
import '../../widget/custom_text_field.dart';

class CreateDriverPage extends StatefulWidget {
  const CreateDriverPage({Key? key}) : super(key: key);

  @override
  State<CreateDriverPage> createState() => _CreateDriverPageState();
}

class _CreateDriverPageState extends State<CreateDriverPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cccdController = TextEditingController();
  final _gplxController = TextEditingController();

  String? _selectedPrefix = "Ông"; // Default to "Ông"
  DateTime? _birthDate;
  DateTime _startDate = DateTime.now(); // Default to current date
  DateTime? _cardExpiredDate;

  bool _isLoading = false;

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

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Xác nhận thêm mới tài xế'),
              content: const Text(
                'Vui lòng kiểm tra lại nội dung, các thông tin CCCD và GPLX sẽ không thể thay đổi sau khi tạo.',
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

  Future<void> _createDriver() async {
    if (!_formKey.currentState!.validate() ||
        _birthDate == null ||
        _selectedPrefix == null) {
      context.showSnackBarFail(
        text: 'Vui lòng điền đầy đủ thông tin bắt buộc',
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog();
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

      final url = Api.BaseUrlBuilding + Api.createDriver;
      final body = DriverInfoCreateModel(
        prefix: _selectedPrefix,
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        personalId: _cccdController.text.trim(),
        cardId: _gplxController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _birthDate!,
        startDate: _startDate,
        fullAddress: _addressController.text.trim(),
        userId: userId,
        cardExpiredDate: _cardExpiredDate,
      );

      print("==== CREATE DRIVER ====");
      print("Token: $token");
      print("Body: ${body.toString()}");
      print("Url: $url");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body.toJson()),
      );

      print("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = json.decode(response.body);

        if (responseJson["code"] == 200) {
          if (mounted) {
            context.showSnackBarSuccess(
              text: responseJson["result"] ?? "Thêm tài xế thành công",
            );
          }

          _firstnameController.clear();
          _lastnameController.clear();
          _phoneController.clear();
          _addressController.clear();
          _cccdController.clear();
          _gplxController.clear();
          _birthDate = null;
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pop(context);Navigator.pop(context);
          }
        } else {
          if (mounted) {
            context.showSnackBarFail(
              text: responseJson["result"] ?? "Thêm tài xế thất bại",
            );
          }

          //throw Exception(responseJson["result"] ?? "Có lỗi xảy ra");
        }
      } else {
        throw Exception("Lỗi: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBarFail(text: e.toString());
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppbar.basic(
        title: 'Tạo Tài Xế Mới',
        onTap: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.5),
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
                items: ["Anh", "Chị", "Ông", "Bà"]
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
                onChanged: (val) => setState(() => _selectedPrefix = val),
                validator: (val) =>
                    val == null ? "Vui lòng chọn chức danh" : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _firstnameController,
                label: "Họ",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _lastnameController,
                label: "Tên",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: "Số điện thoại",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: "Địa chỉ",
                icon: Icons.home,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cccdController,
                label: "CCCD",
                icon: Icons.credit_card,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _gplxController,
                label: "GPLX",
                icon: Icons.drive_eta,
              ),
              const SizedBox(height: 16),
              CustomDatePickerField(
                label: "Ngày sinh",
                date: _birthDate,
                onTap: () => _pickDate(context, 'birth'),
              ),
              const SizedBox(height: 16),
              CustomDatePickerField(
                label: "Ngày bắt đầu làm việc",
                date: _startDate,
                onTap: () => _pickDate(context, 'start'),
              ),
              const SizedBox(height: 16),
              CustomDatePickerField(
                label: "Ngày hết hạn GPLX",
                date: _cardExpiredDate,
                onTap: () => _pickDate(context, 'expire'),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createDriver,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Tạo Tài Xế"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

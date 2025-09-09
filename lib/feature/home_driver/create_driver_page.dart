import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hino/api/api.dart';
import 'package:hino/model/profile.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? _selectedPrefix;
  DateTime? _birthDate;
  DateTime? _startDate;

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

  Future<void> _pickDate(BuildContext context, bool isBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirth) {
          _birthDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _createDriver() async {
    if (!_formKey.currentState!.validate() ||
        _birthDate == null ||
        _startDate == null ||
        _selectedPrefix == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

      final body = {
        "prefix": _selectedPrefix,
        "firstname": _firstnameController.text.trim(),
        "lastname": _lastnameController.text.trim(),
        "personal_id": _cccdController.text.trim(),
        "card_id": _gplxController.text.trim(),
        "phone": _phoneController.text.trim(),
        "birth_date": DateFormat("yyyy-MM-dd").format(_birthDate!),
        "start_date": DateFormat("yyyy-MM-dd").format(_startDate!),
        "full_address": _addressController.text.trim(),
        "user_id": userId,
      };

      print("==== CREATE DRIVER ====");
      print("Token: $token");
      print("Body: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode(body),
      );

      print("Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tạo tài xế thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Lỗi: ${response.body}");
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
              // Prefix dropdown
              const Text("Chức danh",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPrefix,
                decoration: InputDecoration(
                  labelText: "Chức danh",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: ["Anh", "Chị", "Ông", "Bà"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPrefix = val),
                validator: (val) =>
                    val == null ? "Vui lòng chọn chức danh" : null,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _firstnameController,
                label: "Họ",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _lastnameController,
                label: "Tên",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              _datePickerField(
                label: "Ngày sinh",
                date: _birthDate,
                onTap: () => _pickDate(context, true),
              ),
              const SizedBox(height: 20),

              _datePickerField(
                label: "Ngày bắt đầu làm việc",
                date: _startDate,
                onTap: () => _pickDate(context, false),
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _phoneController,
                label: "Số điện thoại",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _addressController,
                label: "Địa chỉ",
                icon: Icons.home,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _cccdController,
                label: "CCCD",
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 20),

              _buildInputField(
                controller: _gplxController,
                label: "GPLX",
                icon: Icons.drive_eta,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) =>
          value == null || value.isEmpty ? "Vui lòng nhập $label" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFf0f9ff),
      ),
    );
  }

  Widget _datePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFf0f9ff),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFd1d5db)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              date != null
                  ? DateFormat("dd/MM/yyyy").format(date)
                  : "Chọn $label",
              style: TextStyle(
                  color: date != null ? Colors.black : Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

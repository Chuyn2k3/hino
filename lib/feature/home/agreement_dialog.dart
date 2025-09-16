import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hino/api/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AgreementDialog extends StatefulWidget {
  const AgreementDialog({super.key});

  @override
  State<AgreementDialog> createState() => _AgreementDialogState();
}

class _AgreementDialogState extends State<AgreementDialog> {
  bool isChecked = false;
  String htmlData = "";

  @override
  void initState() {
    super.initState();
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final data = await rootBundle.loadString("assets/test.html");
    setState(() {
      htmlData = data;
    });
  }

  Future<void> _submitAgreement() async {
    try {
      final res = await http.post(
        Uri.parse(
            "https://apidotnet-v2.hino-connect.vn/users/agreement?AgreementTypeId=1&IsAgreement=true"),
        headers: {
          "x-api-key": Api.profile?.redisKey ?? "",
          "Content-Type": "application/json"
        },
      );
      if (res.statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xác nhận thất bại")),
        );
      }
    } catch (e) {
      debugPrint("Error submit agreement: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // chặn nút Back
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: htmlData.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: HtmlWidget(htmlData),
                      ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (v) => setState(() => isChecked = v ?? false),
                  ),
                  const Expanded(
                    child: Text("Tôi đồng ý với các Điều khoản và Điều kiện"),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: isChecked ? _submitAgreement : null,
                  child: const Text("Xác nhận"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

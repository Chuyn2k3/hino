import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hino/api/api.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:http/http.dart' as http;

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool isChecked = false;
  String htmlData = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    // load file HTML từ assets
    final data = await rootBundle.loadString("assets/test.html");
    setState(() {
      htmlData = data;
    });
  }

  Future<void> _submitAgreement() async {
    setState(() => isLoading = true);
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
        if (mounted) {
          Navigator.of(context).pushReplacementNamed("/home"); // hoặc pop về Home
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Xác nhận thất bại")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error submit agreement: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // chặn nút Back
      child: BaseScaffold(
        appBar: CustomAppbar.basic(
          title: "Điều khoản sử dụng",
          onTap:()=>Navigator.pop(context)
        ),
        body: Column(
          children: [
            Expanded(
              child: htmlData.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: HtmlWidget(htmlData),
                    ),
            ),
            // Row(
            //   children: [
            //     Checkbox(
            //       value: isChecked,
            //       onChanged: (v) => setState(() => isChecked = v ?? false),
            //     ),
            //     const Expanded(
            //       child: Text("Tôi đồng ý với các Điều khoản và Điều kiện"),
            //     ),
            //   ],
            // ),
            // SafeArea(
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: SizedBox(
            //       width: double.infinity,
            //       height: 48,
            //       child: ElevatedButton(
            //         onPressed: isChecked && !isLoading ? _submitAgreement : null,
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.blue,
            //           foregroundColor: Colors.white,
            //         ),
            //         child: isLoading
            //             ? const CircularProgressIndicator(color: Colors.white)
            //             : const Text("Xác nhận"),
            //       ),
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

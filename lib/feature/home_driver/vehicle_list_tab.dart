// import 'package:flutter/material.dart';
// import 'package:hino/api/api.dart';
// import 'package:hino/utils/snack_bar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:hino/api/api.dart';
// import 'package:hino/utils/snack_bar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
//
// import '../../model/profile.dart';
//
// class VehicleListTab extends StatefulWidget {
//   final int driverId;
//   final List<int> vehicleIds;
//
//   const VehicleListTab({
//     Key? key,
//     required this.driverId,
//     required this.vehicleIds,
//   }) : super(key: key);
//
//   @override
//   State<VehicleListTab> createState() => _VehicleListTabState();
// }
//
// class _VehicleListTabState extends State<VehicleListTab> {
//   bool _isLoading = false;
//   Map<int, bool> _vehicleSelection = {};
//   final TextEditingController _newVehicleIdController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _vehicleSelection = {for (var id in widget.vehicleIds) id: true};
//   }
//
//   @override
//   void dispose() {
//     _newVehicleIdController.dispose();
//     super.dispose();
//   }
//
//   void _addVehicleId() {
//     final input = _newVehicleIdController.text.trim();
//     if (input.isNotEmpty && int.tryParse(input) != null) {
//       final vehicleId = int.parse(input);
//       setState(() {
//         if (!_vehicleSelection.containsKey(vehicleId)) {
//           _vehicleSelection[vehicleId] = true;
//           _newVehicleIdController.clear();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('ID xe đã tồn tại trong danh sách'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vui lòng nhập ID xe hợp lệ'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   Future<void> _updateVehicleAssignments() async {
//     final confirmed = await showDialog<bool>(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               backgroundColor: Colors.white,
//               title: const Text('Xác nhận thay đổi'),
//               content: const Text('Bạn có chắc muốn lưu các thay đổi này?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: const Text('Hủy', style: TextStyle(color: Colors.red)),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('Xác nhận'),
//                 ),
//               ],
//             );
//           },
//         ) ??
//         false;
//
//     if (!confirmed) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("accessToken");
//       final profileString = prefs.getString("profile");
//
//       if (token == null || profileString == null) {
//         throw Exception("Không tìm thấy token hoặc profile");
//       }
//
//       final profileJson = json.decode(profileString);
//       final profile = Profile.fromJson(profileJson);
//       final userId = profile.userId ?? 0;
//
//       final url = "${Api.BaseUrlBuilding}${Api.updateVehicleAssignment}";
//       final List<Map<String, dynamic>> vehicleManager = [];
//
//       _vehicleSelection.forEach((vehicleId, isSelected) {
//         final wasAssigned = widget.vehicleIds.contains(vehicleId);
//         if (isSelected != wasAssigned) {
//           vehicleManager.add({
//             "vehicle_id": vehicleId,
//             "action": isSelected ? "INSERT" : "DELETE",
//           });
//         }
//       });
//
//       if (vehicleManager.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Không có thay đổi để cập nhật'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }
//
//       final payload = {
//         "vehicle_manager": vehicleManager,
//         "user_id": userId,
//         "driver_id": widget.driverId,
//       };
//
//       print("==== UPDATE VEHICLE ASSIGNMENTS ====");
//       print("Token: $token");
//       print("Body: ${json.encode(payload)}");
//       print("Url: $url");
//
//       final response = await Api.post(
//         context,
//         url,
//         json.encode(payload),
//         accessToken: "Bearer $token",
//       );
//
//       if (response == null) {
//         throw Exception("Không nhận được phản hồi từ server");
//       }
//
//       if (response["code"] != 200) {
//         throw Exception(response["result"] ?? "Có lỗi xảy ra");
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Cập nhật danh sách xe thành công!"),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       // Refresh driver detail to update vehicleIds
//       if (context.mounted) {
//         final parentState =
//             context.findAncestorStateOfType<_DriverManagementPageState>();
//         await parentState?._fetchDriverDetail();
//         if (context.mounted) {
//           setState(() {
//             _vehicleSelection = {for (var id in widget.vehicleIds) id: true};
//           });
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Lỗi: ${e.toString()}"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Danh sách xe',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _newVehicleIdController,
//                   decoration: InputDecoration(
//                     labelText: 'Nhập ID xe',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.grey, width: 1),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide:
//                           const BorderSide(color: Colors.blue, width: 1.5),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _addVehicleId,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Thêm'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (_vehicleSelection.isEmpty)
//             const Text(
//               'Không có xe nào',
//               style: TextStyle(color: Colors.grey),
//             )
//           else
//             ..._vehicleSelection.entries.map((entry) {
//               final vehicleId = entry.key;
//               final isChecked = entry.value;
//               return CheckboxListTile(
//                 title: Text('Xe $vehicleId'),
//                 value: isChecked,
//                 onChanged: (bool? value) {
//                   setState(() {
//                     _vehicleSelection[vehicleId] = value ?? false;
//                   });
//                 },
//               );
//             }).toList(),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               onPressed: _isLoading || _vehicleSelection.isEmpty
//                   ? null
//                   : _updateVehicleAssignments,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Xác nhận'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

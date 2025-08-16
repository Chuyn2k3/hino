import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Uint8List

class VehicleMarkerWidget extends StatelessWidget {
  final Uint8List iconBytes; // Byte của icon xe (phải trong suốt)
  final String licensePlate;

  const VehicleMarkerWidget({
    Key? key,
    required this.iconBytes,
    required this.licensePlate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Giúp Column chỉ chiếm không gian cần thiết
      children: [
        // Icon xe
        Image.memory(
          iconBytes,
          width: 100, // Kích thước icon xe
          height: 100, // Kích thước icon xe
          //fit: BoxFit.contain,
          // Quan trọng: Đảm bảo ảnh gốc (iconBytes) đã trong suốt
        ),
        // if (licensePlate.isNotEmpty) ...[
        const SizedBox(height: 2), // Khoảng cách giữa icon và biển số
        // Nền biển số xe
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(
                255, 0, 51, 153), // Nền xanh đậm cho biển số
            border: Border.all(color: Colors.white, width: 1), // Viền trắng
            borderRadius: BorderRadius.circular(4), // Bo góc nhẹ
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            licensePlate,
            style: const TextStyle(
              color: Colors.white, // Chữ trắng cho biển số
              fontSize: 20, // Kích thước chữ dễ đọc
              fontWeight: FontWeight.bold,
              //height: 1.2, // Điều chỉnh chiều cao dòng nếu cần
            ),
            textAlign: TextAlign.center,
          ),
        ),
        //],
      ],
    );
  }
}

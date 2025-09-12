class Driver {
  final String? id;
  final String name;
  final DateTime dateOfBirth;
  final String phone;
  final String address;
  final String cccd;
  final String gplx;
  final DateTime? createdAt;

  Driver({
    this.id,
    required this.name,
    required this.dateOfBirth,
    required this.phone,
    required this.address,
    required this.cccd,
    required this.gplx,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phone': phone,
      'address': address,
      'cccd': cccd,
      'gplx': gplx,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      phone: json['phone'],
      address: json['address'],
      cccd: json['cccd'],
      gplx: json['gplx'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

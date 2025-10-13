// file: meters_to_km_extension.dart

extension MetersFormatting on num {
  /// Chuyển số nguyên/float (giả sử là mét) sang chuỗi kilometers.
  ///
  /// - this: giá trị tính bằng mét (m)
  /// - decimals: số chữ số thập phân hiển thị (mặc định 2)
  /// - thousandSeparator: ký tự để chèn làm phân cách hàng nghìn của phần nguyên (mặc định '.')
  /// - decimalSeparator: ký tự phân cách phần thập phân (mặc định ',')
  /// - showUnit: nếu true sẽ thêm " km" vào cuối chuỗi (mặc định true)
  ///
  /// Ví dụ:
  ///   1500.toKmString(decimals:1) -> "1,5 km"
  ///   1234567.toKmString(decimals:2) -> "1.234,57 km"
  String toKmString({
    int decimals = 2,
    String thousandSeparator = '.',
    String decimalSeparator = ',',
    bool showUnit = true,
  }) {
    if (decimals < 0) decimals = 0;

    double km = this / 1000.0;
    String fixed = km.toStringAsFixed(decimals); // ví dụ "1234.56"

    // Luôn tách theo dấu '.' vì toStringAsFixed sử dụng '.'
    List<String> parts = fixed.split('.');
    String intPart = parts[0];
    String fracPart = parts.length > 1 ? parts[1] : '';

    bool negative = intPart.startsWith('-');
    String absInt = negative ? intPart.substring(1) : intPart;

    // Chèn dấu phân cách hàng nghìn (từ phải qua trái)
    StringBuffer sb = StringBuffer();
    int len = absInt.length;
    for (int i = 0; i < len; i++) {
      int posFromRight = len - i;
      sb.write(absInt[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) {
        sb.write(thousandSeparator);
      }
    }

    String formattedInt = sb.toString();
    if (negative) formattedInt = '-$formattedInt';

    // Ghép phần thập phân
    String result;
    if (decimals > 0) {
      result = '$formattedInt$decimalSeparator$fracPart';
    } else {
      result = formattedInt;
    }

    if (showUnit) result = '$result km';
    return result;
  }
}

extension StringMetersFormatting on String {
  /// Chuyển chuỗi biểu diễn mét sang chuỗi km đã định dạng.
  ///
  /// Nếu không parse được -> trả về "0 km" hoặc chuỗi fallback tuỳ chỉnh.
  String toKmString({
    int decimals = 2,
    String thousandSeparator = '.',
    String decimalSeparator = ',',
    bool showUnit = true,
    String fallback = '0 km',
  }) {
    final cleaned = trim().replaceAll(RegExp(r'[^0-9\-,\.]'), '');
    final value = num.tryParse(cleaned);
    if (value == null) return fallback;

    return value.toKmString(
      decimals: decimals,
      thousandSeparator: thousandSeparator,
      decimalSeparator: decimalSeparator,
      showUnit: showUnit,
    );
  }
}


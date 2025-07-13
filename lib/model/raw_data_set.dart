import 'dart:ffi';
import 'dart:ui';

import 'package:hino/model/vehicle.dart';
import 'package:hino/utils/utils.dart';

class RawDataSet {
  final String title;
  final Color color;
  final List<double> values;

  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });
}


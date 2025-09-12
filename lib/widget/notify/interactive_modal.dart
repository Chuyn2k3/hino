import 'package:flutter/material.dart';

abstract class InteractiveModal {
  String? title;
  String? message;

  Future<dynamic> showFailure(BuildContext context);
  Future<dynamic> showInfo(BuildContext context);
  Future<dynamic> showSuccess(BuildContext context);
}

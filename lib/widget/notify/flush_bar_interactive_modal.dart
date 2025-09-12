import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'interactive_modal.dart';

class FlushBarInteractiveModal implements InteractiveModal {
  @override
  String? message;

  @override
  String? title;

  FlushbarPosition? flushBarPosition;
  Function(Flushbar flushbar)? onTap;

  static Duration displayDuration = const Duration(seconds: 2);

  FlushBarInteractiveModal({
    this.message,
    this.title,
    this.flushBarPosition,
    this.onTap,
  });

  @override
  Future<dynamic> showFailure(BuildContext context) {
    final flushBarWidget = Flushbar(
      icon: const Icon(
        Icons.error,
        size: 32,
        color: Colors.white,
      ),
      shouldIconPulse: false,
      message: message,
      messageText: Center(
        child: Text(
          message ?? "",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
      backgroundColor: Colors.red.shade300,
      borderRadius: BorderRadius.circular(16),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      flushbarPosition: flushBarPosition ?? FlushbarPosition.TOP,
    );
    return flushBarWidget.show(context);
  }

  @override
  Future showInfo(BuildContext context) {
    // TODO: implement showInfo
    throw UnimplementedError();
  }

  @override
  Future showSuccess(BuildContext context) {
    final flushBar = Flushbar(
      icon: const Icon(
        Icons.check_circle,
        color: Colors.white,
      ),
      shouldIconPulse: false,
      message: message,
      onTap: onTap,
      messageText: Center(
        child: Text(
          message ?? "",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
      backgroundColor: Colors.green,
      borderRadius: BorderRadius.circular(16),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(8),
      flushbarPosition: flushBarPosition ?? FlushbarPosition.TOP,
    );
    return flushBar.show(context);
  }
}

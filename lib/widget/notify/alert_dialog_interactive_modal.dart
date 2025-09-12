import 'package:flutter/material.dart';
import '../button/primary_button.dart';
import 'interactive_modal.dart';

class AlertDialogInteractiveModal implements InteractiveModal {
  @override
  String? message;

  @override
  String? title;

  AlertDialogInteractiveModal({
    this.message,
    this.title,
  });

  factory AlertDialogInteractiveModal.build({
    String? message,
    String? title,
  }) {
    return AlertDialogInteractiveModal(
      title: title,
      message: message,
    );
  }

  @override
  Future<dynamic> showFailure(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialogContent(
          context,
          title: title,
          content: message,
        );
      },
    );
    return result;
  }

  @override
  Future<dynamic> showInfo(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialogContent(
          context,
          title: title,
          content: message,
        );
      },
    );
    return result;
  }

  @override
  Future<dynamic> showSuccess(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAlertDialogContent(
          context,
          title: title,
          content: message,
        );
      },
    );
    return result;
  }

  Widget _buildAlertDialogContent(
    BuildContext context, {
    required String? title,
    required String? content,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Text(
                  title,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            Text(
              content ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: "Tiếp tục",
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

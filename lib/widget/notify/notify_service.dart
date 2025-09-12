import 'package:flutter/material.dart';

import 'interactive_modal.dart';

class NotifyService {
  InteractiveModal notify;

  NotifyService(this.notify);

  Future<dynamic> showFailure(BuildContext context) {
    return notify.showFailure(context);
  }

  Future<dynamic> showInfo(BuildContext context) {
    return notify.showInfo(context);
  }

  Future<dynamic> showSuccess(BuildContext context) {
    return notify.showSuccess(context);
  }
}

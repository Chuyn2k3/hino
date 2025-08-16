import 'package:hino/model/noti.dart';
import 'package:hino/model/vehicle.dart';

class NotiGroup {
  String? name;
  List<Noti> notifications;
  List<Vehicle> vehicle;

  NotiGroup({
    this.name,
    List<Noti>? notifications,
    List<Vehicle>? vehicle,
  })  : notifications = notifications ?? [],
        vehicle = vehicle ?? [];
}

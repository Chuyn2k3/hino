import 'dart:ffi';

import 'package:hino/model/history.dart';
import 'package:hino/model/location.dart';
import 'package:hino/model/member.dart';
import 'package:hino/model/noti.dart';
import 'package:hino/model/vehicle.dart';

class MemberGroup {
  String? name;
  List<Member> members = [];
  List<Vehicle> vehicle = [];
  bool isExpand = false;
  bool isSelect = true;

  MemberGroup({String? name}) {
    this.name = name;
    this.members = [];
    this.vehicle = [];
  }
}

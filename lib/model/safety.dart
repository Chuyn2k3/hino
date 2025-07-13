import 'dart:ffi';

import 'package:hino/api/api.dart';

class Safety {


  String? arg ;
  var avg ;
  var point ;


  Safety.fromJson(Map<String, dynamic> json) {
    arg = mapName(json['arg']);
    avg = json['avg'];
    point = json['point'];

  }

  mapName(String name){
    if(Api.language=="en"){
      if(name=="harsh_start"){
        return "Harsh Start";
      }else if(name=="harsh_acceleration"){
        return "Harsh Acceleration";
      }else if(name=="harsh_brake"){
        return "Harsh Brake";
      }else if(name=="sharp_turn"){
        return "Sharp Turn";
      }else if(name=="exceeding_speed"){
        return "Exceeding Speed";
      }else if(name=="exceeding_rpm"){
        return "Exceeding RPM";
      }else{
        return name;
      }
    }else{
      if(name=="harsh_start"){
        return "Bắt đầu đột ngột";
      }else if(name=="harsh_acceleration"){
        return "Tăng tốc đột ngột";
      }else if(name=="harsh_brake"){
        return "Phanh đột ngột";
      }else if(name=="sharp_turn"){
        return "Rẽ đột ngột";
      }else if(name=="exceeding_speed"){
        return "Quá tốc độ";
      }else if(name=="exceeding_rpm"){
        return "Quá RPM";
      }else{
        return name;
      }
    }

  }
}


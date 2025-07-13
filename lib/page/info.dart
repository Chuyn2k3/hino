import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';

class InfoPage extends StatefulWidget {
   InfoPage({Key? key, required this.count}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final int count;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<InfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 40),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info,
                    size: 30,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.info_map,
                      style: TextStyle(
                          color: ColorCustom.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                      widget.count!=0?Languages.of(context)!.total_vehicle+" " + widget.count.toString() + " "+Languages.of(context)!.unit:"",
                    style: TextStyle(
                        color: ColorCustom.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                color: Colors.grey,
                height: 1,
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: ColorCustom.run,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.driving,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: ColorCustom.parking,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.ignOff,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: ColorCustom.idle,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.idle,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: ColorCustom.offline,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.offline,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: ColorCustom.over_speed,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.overspeed_info,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: ColorCustom.blue,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.vehicle_group,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    color: Colors.green,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.swipe_card,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Icon(
                    Icons.credit_card,
                    color: Colors.red,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.wrong_license,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    color: Colors.grey,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.no_swipe_card,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: Colors.lightGreen,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.rpm_green,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 15,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(Languages.of(context)!.rpm_red,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            color: Colors.red,
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            shape: CircleBorder(),
            padding: EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }
}

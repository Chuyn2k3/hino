import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/member_group.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/utils/color_custom.dart';
import 'dart:ui' as ui;


List<MemberGroup> listNameGroup = [];
bool isAll = true;

class DashboardFilter extends StatefulWidget {
  const DashboardFilter({Key? key, required this.data}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final ValueChanged<List<Vehicle>> data;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<DashboardFilter> {
  @override
  void initState() {
    // listSearchVehicle.addAll(listVehicle);
    // getDataCarList(context);
    if (listNameGroup.isEmpty) {
      groupNameTest();
    }

    super.initState();
  }

  // List<Member> listMember = [];
  // List<Vehicle> listSearchVehicle = [];
  //
  // getDataCarList(BuildContext context) {
  //   Api.get(context, Api.listmember).then((value) => {
  //         if (value != null)
  //           {
  //             listMember = List.from(value['result'])
  //                 .map((a) => Member.fromJson(a))
  //                 .toList(),
  //             groupName(),
  //             refresh()
  //           }
  //         else
  //           {}
  //       });
  // }

  // List<MemberGroup> listSearchGroup = [];

  // groupName() {
  //   var groupByDate = groupBy(listMember, (Member obj) => obj.fleet_name);
  //   groupByDate.forEach((date, list) {
  //     // Header
  //     print('${date}:');
  //     var group = new MemberGroup();
  //     group.name = date;
  //
  //     // Group
  //     list.forEach((listItem) {
  //       // List item
  //       group.members.add(listItem);
  //       // print('${listItem.gpsdate}, ${listItem.location!.admin_level3_name}');
  //     });
  //     listNameGroup.add(group);
  //     // day section divider
  //     // print('\n');
  //   });
  //
  //   for (MemberGroup m in listNameGroup) {
  //     for (Vehicle v in listVehicle) {
  //       if (m.name == v.fleet!.fleet_name) {
  //         m.vehicle.add(v);
  //       }
  //     }
  //   }
  //   listSearchGroup.addAll(listNameGroup);
  // }

  groupNameTest() async {
    var groupByDate =
        groupBy(listVehicle, (Vehicle obj) => obj.fleet!.fleet_name);
    groupByDate.forEach((date, list) {
      // Header
      // print('${date}:');
      var group = new MemberGroup();
      group.name = date;

      // Group
      list.forEach((listItem) {
        // List item
        group.vehicle.add(listItem);
        // print('${listItem.gpsdate}, ${listItem.location!.admin_level3_name}');
      });
      listNameGroup.add(group);
      // day section divider
      // print('\n');
    });

    refresh();
    // for (MemberGroup m in listNameGroup) {
    //   for (Vehicle v in listVehicle) {
    //     if (m.name == v.fleet!.fleet_name) {
    //       m.vehicle.add(v);
    //     }
    //   }
    // }
    // listSearchGroup.addAll(listNameGroup);
  }

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToMe,
      //   label: Text('My location'),
      //   icon: Icon(Icons.near_me),
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                    value: isAll,
                    onChanged: (value) {
                      isAll = value!;
                      for (MemberGroup m in listNameGroup) {
                        m.isSelect = isAll;
                        for (Vehicle v in m.vehicle) {
                          v.isSelect = isAll;
                        }
                      }
                      refresh();
                    }),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      isAll = !isAll;
                      for (MemberGroup m in listNameGroup) {
                        m.isSelect = isAll;
                        for (Vehicle v in m.vehicle) {
                          v.isSelect = isAll;
                        }
                      }
                      refresh();
                    },
                    child: Text(Languages.of(context)!.select_all,
                      style: TextStyle(
                        color: ColorCustom.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                shrinkWrap: true,
                itemCount: listNameGroup.length,
                itemBuilder: (BuildContext context, int index) {
                  MemberGroup group = listNameGroup[index];

                  return Column(
                    children: [
                      InkWell(
                        child:  Container(
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: ColorCustom.blue),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                  value: group.isSelect,
                                  onChanged: (value) {
                                    group.isSelect = value!;
                                    for (Vehicle v in group.vehicle) {
                                      v.isSelect = value;
                                    }
                                    refresh();
                                  }),
                              Expanded(
                                child: Text(group.name!,
                                  style: TextStyle(
                                    color: ColorCustom.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(group.isExpand?Icons.keyboard_arrow_up:Icons.keyboard_arrow_down,color: ColorCustom.blue,),
                              SizedBox(width: 10,),
                            ],
                          ),
                        ),
                        onTap: (){
                          group.isExpand = !group.isExpand;
                          refresh();
                        },
                      ),

                      group.isExpand
                          ? Column(
                              children: [
                                for (Vehicle v in group.vehicle)
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10,left: 20),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: ColorCustom.greyBG2),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value: v.isSelect,
                                            onChanged: (value) {
                                              v.isSelect = value!;
                                              refresh();
                                            }),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              v.isSelect = !v.isSelect;
                                              refresh();
                                            },
                                            child:  Text(
                                              v.info!.licenseplate!,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  )
                              ],
                            )
                          : Container(),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorCustom.blue,
                padding: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5), // <-- Radius
                ),
              ),
              onPressed: () {
                List<Vehicle> list = [];
                for (MemberGroup m in listNameGroup) {
                  for (Vehicle v in m.vehicle) {
                    if (v.isSelect) {
                      // print(v.info!.licenseplate!);
                      list.add(v);
                    }
                  }
                }

                widget.data.call(list);
                Navigator.pop(context);
              },
              child: Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

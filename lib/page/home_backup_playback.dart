import 'package:flutter/material.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_vi.dart';
import 'package:hino/model/dropdown.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_backup_playback_search.dart';
import 'package:hino/page/home_realtime.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/utils.dart';
import 'package:hino/widget/dropbox_general_search.dart';
import 'package:hino/widget/dropbox_general_search_trip.dart';

import '../api/api.dart';
import '../localization/language/languages.dart';
import '../widget/back_ios.dart';

class HomeBackupPlaybackPage extends StatefulWidget {
  const HomeBackupPlaybackPage({Key? key}) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeBackupPlaybackPage> {
  List<Dropdown> listDropdown = [];

  @override
  void initState() {
    if (Api.language == "en") {
      listDropdown.add(Dropdown("1", LanguageEn().plate_no));
      listDropdown.add(Dropdown("2", LanguageEn().vehicle_name));
      listDropdown.add(Dropdown("3", LanguageEn().vin_no));
    } else {
      listDropdown.add(Dropdown("1", LanguageVi().plate_no));
      listDropdown.add(Dropdown("2", LanguageVi().vehicle_name));
      listDropdown.add(Dropdown("3", LanguageVi().vin_no));
    }

    super.initState();
  }

  refresh() {
    setState(() {});
  }

  Vehicle? selectVehicle;

  submit() {
    if (selectVehicle == null) {
      if (dropdown != null) {
        Utils.showAlertDialog(
            context, Languages.of(context)!.please_select + dropdown!.name);
      } else {
        Utils.showAlertDialog(
            context,
            Languages.of(context)!.please_select +
                Languages.of(context)!.plate_no);
      }

      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            HomePlaybackEventSearchPage(imei: selectVehicle!.gps!.imei!)));
  }

  // String imei = "";
  Dropdown? dropdown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              BackIOS(),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restore,
                            size: 30,
                            color: Colors.grey,
                          ),
                          Text(
                            Languages.of(context)!.camera_playback,
                            style: TextStyle(
                              color: ColorCustom.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Languages.of(context)!.search_by,
                            style: TextStyle(
                              color: ColorCustom.black,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorCustom.greyBG2),
                              color: ColorCustom.greyBG2,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            child: DropboxGeneralSearchViewTrip(
                              name: "",
                              onChanged: (value) {
                                dropdown = value;
                                refresh();
                              },
                              listData: listDropdown,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dropdown != null
                                ? dropdown!.name
                                : Languages.of(context)!.plate_no,
                            style: TextStyle(
                              color: ColorCustom.black,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorCustom.greyBG2),
                              color: ColorCustom.greyBG2,
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            child: DropboxGeneralSearchView(
                              name: dropdown != null
                                  ? Languages.of(context)!.please_select +
                                      dropdown!.name
                                  : Languages.of(context)!.please_select +
                                      Languages.of(context)!.plate_no,
                              onChanged: (value) {
                                // imei = value.gps!.imei!;
                                // license = value.info!.licenseplate!;
                                selectVehicle = value;
                              },
                              listData: listVehicle,
                              dropdownID: dropdown?.id,
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: Container()),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorCustom.blue,
                            padding: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // <-- Radius
                            ),
                          ),
                          onPressed: () {
                            submit();
                          },
                          child: Text(
                            Languages.of(context)!.search,
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hino/feature/home_realtime/home_realtime_page.dart';
import 'package:hino/localization/language/language_en.dart';
import 'package:hino/localization/language/language_vi.dart';
import 'package:hino/model/dropdown.dart';
import 'package:hino/model/vehicle.dart';
import 'package:hino/page/home_backup_playback_search.dart';
import 'package:hino/page/home_realtime.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/custom_app_bar.dart';
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
    dropdown = listDropdown.first;
    if (listVehicle.isNotEmpty) {
      selectVehicle = listVehicle.first;
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
    return BaseScaffold(
      appBar: CustomAppbar.basic(
        title: Languages.of(context)!.camera_playback,
        onTap: () => Navigator.pop(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Languages.of(context)!.search_by,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(
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
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dropdown != null
                        ? dropdown!.name
                        : Languages.of(context)!.plate_no,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(
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
                        setState(() {});
                      },
                      listData: listVehicle,
                      dropdownID: dropdown?.id,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              //Expanded(child: Container()),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCustom.blue,
                    padding: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // <-- Radius
                    ),
                  ),
                  onPressed: () {
                    submit();
                  },
                  child: Text(
                    Languages.of(context)!.search,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

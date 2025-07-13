import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:hino/model/vehicle.dart';

class DropboxGeneralSearchView extends StatefulWidget {
  const DropboxGeneralSearchView({
    Key? key,
    required this.name,
    required this.listData,
    this.dropdownID,
    required this.onChanged,
    this.selectedItem,
  }) : super(key: key);

  final String name;
  final List<Vehicle> listData;
  final ValueChanged<Vehicle> onChanged;
  final String? dropdownID;
  final Vehicle? selectedItem;

  @override
  State<DropboxGeneralSearchView> createState() =>
      _DropboxGeneralSearchViewState();
}

class _DropboxGeneralSearchViewState extends State<DropboxGeneralSearchView> {
  final TextEditingController textEditingController = TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Vehicle>(
      selectedItem: widget.selectedItem ??
          (widget.listData.isNotEmpty ? widget.listData[0] : null),
      asyncItems: (String filter) async {
        search = filter;
        return widget.listData.where((item) {
          final lp = item.info?.licenseplate ?? '';
          final name = item.info?.vehicle_name ?? '';
          final vin = item.info?.vin_no ?? '';

          if (lp.contains(filter)) {
            item.searchType = 0;
            return true;
          } else if (name.contains(filter)) {
            item.searchType = 1;
            return true;
          } else if (vin.contains(filter)) {
            item.searchType = 2;
            return true;
          }
          return false;
        }).toList();
      },
      onChanged: (value) {
        if (value != null) {
          widget.onChanged(value);
        }
      },
      validator: (value) => value == null ? "required field" : null,
      itemAsString: (item) {
        if (search.isNotEmpty) {
          switch (item?.searchType) {
            case 0:
              return item?.info?.licenseplate ?? '';
            case 1:
              return item?.info?.vehicle_name ?? '';
            case 2:
              return item?.info?.vin_no ?? '';
            default:
              return item?.info?.licenseplate ?? '';
          }
        } else {
          if (widget.dropdownID != null && widget.dropdownID!.isNotEmpty) {
            switch (widget.dropdownID) {
              case "1":
                return item?.info?.licenseplate ?? '';
              case "2":
                return item?.info?.vehicle_name ?? '';
              default:
                return item?.info?.vin_no ?? '';
            }
          }
          return item?.info?.licenseplate ?? '';
        }
      },
      compareFn: (a, b) {
        if (a == null || b == null) return false;
        return a.info?.licenseplate == b.info?.licenseplate ||
            a.info?.vehicle_name == b.info?.vehicle_name ||
            a.info?.vin_no == b.info?.vin_no;
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          controller: textEditingController,
          decoration: const InputDecoration(hintText: "Tìm kiếm..."),
        ),
        showSelectedItems: true,
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: widget.name,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

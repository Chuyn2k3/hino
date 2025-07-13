import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hino/model/cctv_date_date.dart';
import 'package:intl/intl.dart';

class DropboxGeneralSearchDateView extends StatefulWidget {
  DropboxGeneralSearchDateView({
    Key? key,
    required this.name,
    required this.listData,
    this.dropdownID,
    required this.onChanged,
    this.selectItem,
  }) : super(key: key);

  final String name;
  final List<CctvDateDate> listData;
  final ValueChanged<CctvDateDate> onChanged;
  final String? dropdownID;
  final CctvDateDate? selectItem;

  @override
  _DropboxGeneralSearchDateViewState createState() =>
      _DropboxGeneralSearchDateViewState();
}

class _DropboxGeneralSearchDateViewState
    extends State<DropboxGeneralSearchDateView> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<CctvDateDate>(
      selectedItem: widget.selectItem,
      asyncItems: (String filter) async {
        return widget.listData;
      },
      onChanged: (value) {
        if (value != null) {
          widget.onChanged(value);
        }
      },
      validator: (value) {
        return value == null ? "required field" : null;
      },
      itemAsString: (item) => item.date ?? '',
      compareFn: (item, selectedItem) => item.date == selectedItem.date,
      popupProps: PopupProps.menu(
        showSearchBox: false,
        showSelectedItems: true,
        searchFieldProps: TextFieldProps(
          controller: textEditingController,
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: widget.name,
          border: const OutlineInputBorder(
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

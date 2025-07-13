import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:hino/model/dropdown.dart';

class DropboxGeneralSearchViewTrip extends StatefulWidget {
  const DropboxGeneralSearchViewTrip({
    Key? key,
    required this.name,
    required this.listData,
    required this.onChanged,
    this.selectedItem,
  }) : super(key: key);

  final String name;
  final List<Dropdown> listData;
  final ValueChanged<Dropdown> onChanged;
  final Dropdown? selectedItem;

  @override
  State<DropboxGeneralSearchViewTrip> createState() =>
      _DropboxGeneralSearchViewTripState();
}

class _DropboxGeneralSearchViewTripState
    extends State<DropboxGeneralSearchViewTrip> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Dropdown>(
      selectedItem: widget.selectedItem ??
          (widget.listData.isNotEmpty ? widget.listData[0] : null),
      asyncItems: (String filter) async {
        return widget.listData
            .where((item) =>
                item.name?.toLowerCase().contains(filter.toLowerCase()) ??
                false)
            .toList();
      },
      onChanged: (value) {
        if (value != null) {
          widget.onChanged(value);
        }
      },
      validator: (value) => value == null ? "required field" : null,
      itemAsString: (item) => item?.name ?? '',
      compareFn: (item, selectedItem) => item?.name == selectedItem?.name,
      popupProps: PopupProps.menu(
        showSearchBox: false,
        showSelectedItems: true,
        searchFieldProps: TextFieldProps(
          controller: textEditingController,
        ),
        itemBuilder: (context, item, isSelected) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.name ?? '',
              style: const TextStyle(fontSize: 13),
            ),
          );
        },
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

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DropboxGeneralSearchViewString extends StatefulWidget {
  const DropboxGeneralSearchViewString({
    Key? key,
    required this.name,
    required this.listData,
    this.dropdownID,
    required this.onChanged,
    this.selectedItem,
  }) : super(key: key);

  final String name;
  final List<String> listData;
  final ValueChanged<String> onChanged;
  final String? dropdownID;
  final String? selectedItem;

  @override
  State<DropboxGeneralSearchViewString> createState() =>
      _DropboxGeneralSearchViewStringState();
}

class _DropboxGeneralSearchViewStringState
    extends State<DropboxGeneralSearchViewString> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      selectedItem: widget.selectedItem,
      asyncItems: (String filter) async {
        // Nếu muốn lọc kết quả theo filter nhập vào
        return widget.listData
            .where((item) => item.toLowerCase().contains(filter.toLowerCase()))
            .toList();
      },
      onChanged: (value) {
        if (value != null) {
          widget.onChanged(value);
        }
      },
      validator: (value) => value == null ? "required field" : null,
      itemAsString: (item) => item,
      compareFn: (item, selectedItem) => item == selectedItem,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          controller: textEditingController,
          decoration: const InputDecoration(
            hintText: "Tìm kiếm...",
          ),
        ),
        showSelectedItems: true,
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          hintText: widget.name,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(4),
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

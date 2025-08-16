import 'package:flutter/material.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/utils/color_custom.dart';

/// Dựa trên code gốc của bạn, nhưng đã tối ưu và sửa lỗi `select`.
class HomeCarSortPage extends StatefulWidget {
  final ValueChanged<int> select;
  final String? title;
  final int initialSelect;

  const HomeCarSortPage({
    Key? key,
    required this.select,
    this.title,
    this.initialSelect = 2,
  }) : super(key: key);

  @override
  State<HomeCarSortPage> createState() => _HomeCarSortPageState();
}

class _HomeCarSortPageState extends State<HomeCarSortPage> {
  late int selectIndex;

  @override
  void initState() {
    super.initState();
    selectIndex = widget.initialSelect;
  }

  void _onChanged(int index) {
    setState(() {
      selectIndex = index;
    });
    widget.select(index);
  }

  Widget _buildOption(int value, String text) {
    return InkWell(
      onTap: () => _onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 14, color: ColorCustom.black)),
            ),
            Radio<int>(
              value: value,
              groupValue: selectIndex,
              onChanged: (_) => _onChanged(value),
              activeColor: ColorCustom.blue,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.title ?? lang.sort_by,
                style: const TextStyle(fontSize: 20, color: ColorCustom.black),
              ),
            ),
            const SizedBox(height: 10),
            _buildOption(0, lang.unit_ascending),
            _buildOption(1, lang.unit_descending),
            _buildOption(2, lang.alphabet_a_z),
            _buildOption(3, lang.alphabet_z_a),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

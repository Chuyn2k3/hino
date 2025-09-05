import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:hino/localization/language/languages.dart';
import 'package:hino/model/car_filter.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/widget/back_ios.dart';

class HomeCarFilterPage extends StatefulWidget {
  const HomeCarFilterPage({Key? key, required this.filter}) : super(key: key);
  final ValueChanged<CarFilter> filter;

  @override
  State<HomeCarFilterPage> createState() => _HomeCarFilterPageState();
}

class _HomeCarFilterPageState extends State<HomeCarFilterPage> {
  bool isSpeed = true, isFuel = true, isStatus = true;
  double minSpeed = 50, maxSpeed = 120, fuelPerc = 25;
  late List<String> statusOptions;
  final List<bool> statusSelect = [true, true, true, true];
  final GroupButtonController gbController = GroupButtonController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo sau khi context sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = Languages.of(context)!;
      statusOptions = [
        lang.driving,
        lang.idle,
        lang.ignOff,
        lang.offline,
      ];
      gbController.selectIndexes(List.generate(statusOptions.length, (i) => i));
      setState(() {});
    });
  }

  void _resetAll() {
    setState(() {
      isSpeed = isFuel = isStatus = true;
      minSpeed = 50;
      maxSpeed = 120;
      fuelPerc = 25;
      for (var i = 0; i < statusSelect.length; i++) {
        statusSelect[i] = true;
      }
      gbController.selectIndexes([0, 1, 2, 3]);
    });
  }

  void _applyFilter() {
    final filter = CarFilter()
      ..isSpeed = isSpeed
      ..minSpeed = minSpeed.toInt()
      ..maxSpeed = maxSpeed.toInt()
      ..isFuel = isFuel
      ..fuel = fuelPerc.toInt()
      ..isStatus = isStatus
      ..status = List.from(statusSelect);

    widget.filter(filter);
    Navigator.of(context).pop();
  }

  Widget _buildSection({required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final lang = Languages.of(context)!;

    return Scaffold(
      backgroundColor: ColorCustom.greyBG2,
      appBar: AppBar(
        leading: BackIOS(),
        title: Text(lang.filter),
        actions: [
          TextButton(
            onPressed: _resetAll,
            child: Text(lang.reset_filter,
                style: const TextStyle(color: Colors.grey)),
          )
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              title: lang.speed,
              subtitle:
                  '${minSpeed.toInt()} - ${maxSpeed.toInt()} ${lang.km_h}',
              value: isSpeed,
              onChanged: (v) => setState(() => isSpeed = v),
              child: RangeSlider(
                min: 40,
                max: 160,
                divisions: 24,
                values: RangeValues(minSpeed, maxSpeed),
                labels: RangeLabels(
                  minSpeed.toInt().toString(),
                  maxSpeed.toInt().toString(),
                ),
                onChanged: isSpeed
                    ? (values) => setState(() {
                          minSpeed = values.start;
                          maxSpeed = values.end;
                        })
                    : null,
                activeColor: ColorCustom.blue,
              ),
            ),
            _buildCard(
              title: '${lang.fuel} (%)',
              subtitle: '${fuelPerc.toInt()} %',
              value: isFuel,
              onChanged: (v) => setState(() => isFuel = v),
              child: Slider(
                min: 0,
                max: 100,
                divisions: 20,
                value: fuelPerc,
                label: '${fuelPerc.toInt()}%',
                onChanged:
                    isFuel ? (val) => setState(() => fuelPerc = val) : null,
                activeColor: ColorCustom.blue,
              ),
            ),
            _buildCard(
              title: lang.status,
              value: isStatus,
              onChanged: (v) {
                setState(() {
                  isStatus = v;
                  if (!v) {
                    for (int i = 0; i < statusSelect.length; i++) {
                      statusSelect[i] = false;
                    }
                    gbController.unselectAll();
                  } else {
                    gbController.selectIndexes([0, 1, 2, 3]);
                  }
                });
              },
              child: isStatus && statusOptions.isNotEmpty
                  ? GroupButton(
                      controller: gbController,
                      isRadio: false,
                      buttons: statusOptions,
                      onSelected: (val, index, selected) =>
                          statusSelect[index] = selected,
                      options: GroupButtonOptions(
                        selectedColor: ColorCustom.blue,
                        unselectedColor: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        spacing: 8,
                        runSpacing: 8,
                        selectedTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                        unselectedTextStyle: const TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w500),
                        unselectedBorderColor: Colors.grey.shade300,
                        // borderWidth: 1,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _applyFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorCustom.blue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              lang.confirm,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: subtitle != null ? Text(subtitle) : null,
              value: value,
              onChanged: onChanged,
            ),
            if (value) child,
          ],
        ),
      ),
    );
  }
}

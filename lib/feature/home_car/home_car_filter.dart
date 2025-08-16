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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                 BackIOS(),
                const Spacer(),
                TextButton(
                  onPressed: _resetAll,
                  child: Text(
                    lang.reset_filter,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSection(
                      child: SwitchListTile(
                        title: Text(lang.speed),
                        subtitle: Text(
                            '${minSpeed.toInt()} - ${maxSpeed.toInt()} ${lang.km_h}'),
                        value: isSpeed,
                        onChanged: (val) => setState(() => isSpeed = val),
                      ),
                    ),
                    _buildSection(
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
                      ),
                    ),
                    _buildSection(
                      child: SwitchListTile(
                        title: Text('${lang.fuel} (%)'),
                        subtitle: Text('${fuelPerc.toInt()} %'),
                        value: isFuel,
                        onChanged: (val) => setState(() => isFuel = val),
                      ),
                    ),
                    _buildSection(
                      child: Slider(
                        min: 0,
                        max: 100,
                        divisions: 20,
                        value: fuelPerc,
                        label: '${fuelPerc.toInt()}%',
                        onChanged: isFuel
                            ? (val) => setState(() => fuelPerc = val)
                            : null,
                      ),
                    ),
                    _buildSection(
                      child: SwitchListTile(
                        title: Text(lang.status),
                        value: isStatus,
                        onChanged: (val) {
                          setState(() {
                            isStatus = val;
                            if (!val) {
                              for (int i = 0; i < statusSelect.length; i++) {
                                statusSelect[i] = false;
                              }
                              gbController.unselectAll();
                            } else {
                              gbController.selectIndexes([0, 1, 2, 3]);
                            }
                          });
                        },
                      ),
                    ),
                    if (isStatus && statusOptions.isNotEmpty)
                      _buildSection(
                        child: GroupButton(
                          controller: gbController,
                          isRadio: false,
                          buttons: statusOptions,
                          onSelected: (val, index, selected) =>
                              statusSelect[index] = selected,
                          options: GroupButtonOptions(
                            selectedColor: ColorCustom.blue,
                            unselectedColor: ColorCustom.greyBG2,
                            borderRadius: BorderRadius.circular(20),
                            spacing: 8,
                            runSpacing: 8,
                            selectedTextStyle: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorCustom.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    lang.confirm,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

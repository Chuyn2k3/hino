import 'package:flutter/material.dart';

class TimelineWidget extends StatelessWidget {
  final Color startColor;
  final Color dotColor;
  final Color endColor;

  const TimelineWidget({
    Key? key,
    this.startColor = Colors.green,
    this.dotColor = Colors.grey,
    this.endColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Start circle
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: startColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        // Middle dots
        for (int i = 0; i < 4; i++) ...[
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
        ],
        // End location icon
        Icon(
          Icons.location_on,
          size: 20,
          color: endColor,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ContentButton extends StatelessWidget {
  final bool isHasIcon;
  final Widget iconWidget;
  final Color textColor;
  final bool isLoading;
  final bool showTitle;
  final String label;

  const ContentButton({
    super.key,
    required this.isHasIcon,
    required this.iconWidget,
    required this.textColor,
    required this.isLoading,
    required this.label,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return _buildFullContent(context, isHasIcon, iconWidget, textColor);
  }

  Widget _buildFullContent(
    BuildContext context,
    bool isHasIcon,
    Widget iconWidget,
    Color textColor,
  ) {
    const double paddingHorizontal = 20;
    String? textLabel = label;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            _loadingWidget(),
            const SizedBox(
              width: 5,
            ),
          ],
          iconWidget,
          if ((textLabel).isNotEmpty) ...[
            const SizedBox(
              width: 5,
            ),
            Flexible(
              child: _buildLabelBtn(context, textColor, isHasIcon),
            ),
          ]
        ],
      ),
    );
  }

  Widget _loadingWidget() {
    return Container(
      height: 22,
      width: 22,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        backgroundColor: Colors.grey,
        color: Colors.white,
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildLabelBtn(
    BuildContext context,
    Color textColor,
    bool isHasIcon,
  ) {
    return Text(
      label,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        overflow: TextOverflow.visible,
      ),
      maxLines: 1,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.center,
    );
  }
}

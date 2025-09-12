
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'content_button.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final Widget? customLeadingIcon;
  final IconData? iconData;
  final String? iconAsset;
  final String? iconSvgAsset;
  final VoidCallback? onPressed;
  final double? minHeight;
  final bool isLoading;
  final bool showTitle;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? child;

  const PrimaryButton({
    super.key,
    this.label = "",
    this.customLeadingIcon,
    this.iconData,
    this.iconAsset,
    this.iconSvgAsset,
    this.minHeight,
    required this.onPressed,
    this.isLoading = false,
    this.showTitle = false,
    this.backgroundColor,
    this.textColor,
    this.child,
  });

  factory PrimaryButton.icon({
    required String label,
    IconData? iconData,
    VoidCallback? onPressed,
    double? minHeight,
    bool isLoading = false,
    bool showTitle = false,
  }) {
    return PrimaryButton(
      label: label,
      iconData: iconData,
      onPressed: onPressed,
      minHeight: minHeight,
      isLoading: isLoading,
      showTitle: showTitle,
    );
  }

  factory PrimaryButton.svg({
    required String label,
    String? svgIcon,
    VoidCallback? onPressed,
    double? minHeight,
    bool isLoading = false,
    bool showTitle = false,
    Color? backgroundColor,
  }) {
    return PrimaryButton(
      label: label,
      iconSvgAsset: svgIcon,
      onPressed: onPressed,
      minHeight: minHeight,
      isLoading: isLoading,
      showTitle: showTitle,
      backgroundColor: backgroundColor,
    );
  }

  factory PrimaryButton.asset({
    required String label,
    String? assetIcon,
    VoidCallback? onPressed,
    double? minHeight,
    bool isLoading = false,
    bool showTitle = false,
  }) {
    return PrimaryButton(
      label: label,
      iconAsset: assetIcon,
      onPressed: onPressed,
      minHeight: minHeight,
      isLoading: isLoading,
      showTitle: showTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnable = onPressed != null;
    final disableBackgroundColor = const Color(0xFF747480).withOpacity(0.08);
    // const disableBorderColor = Color(0xFFD8DDE4);
    final disableTextColor = const Color(0xFF3C3C43).withOpacity(0.18);

    Color tmpBackgroundColor = isEnable
        ? (backgroundColor ?? const Color(0xFF007AFF))
        : disableBackgroundColor;
    Color borderColor = Colors.transparent;
    Color tmpTextColor =
        isEnable ? (textColor ?? Colors.white) : disableTextColor;

    Widget iconWidget = customLeadingIcon ?? const SizedBox();
    final isHasIcon =
        iconSvgAsset != null || iconAsset != null || iconData != null;

    if (customLeadingIcon == null) {
      if (iconSvgAsset != null) {
        iconWidget = SvgPicture.asset(
          iconSvgAsset!,
          width: 16,
          height: 16,
          // colorFilter: ColorFilter.mode(
          //   tmpTextColor,
          //   BlendMode.srcIn,
          // ),
        );
      } else {
        if (iconAsset != null) {
          iconWidget = Image.asset(
            iconAsset!,
            color: tmpTextColor,
            width: 16,
            height: 16,
          );
        } else if (iconData != null) {
          iconWidget = Icon(
            iconData,
            color: tmpTextColor,
            size: 20,
          );
        }
      }
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? 48),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: tmpBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          elevation: 0,
          side: BorderSide(
            width: 1,
            color: borderColor,
          ),
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 24),
        ),
        onPressed: onPressed,
        child: child ??
            ContentButton(
              isHasIcon: isHasIcon,
              iconWidget: iconWidget,
              textColor: tmpTextColor,
              isLoading: isLoading,
              label: label,
              showTitle: showTitle,
            ),
      ),
    );
  }
}

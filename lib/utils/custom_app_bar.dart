import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar(
      {super.key,
      this.title,
      this.actions,
      this.flexibleSpace,
      this.automaticallyImplyLeading,
      this.widgetTitle,
      this.leading,
      this.leadingWidth,
      this.styleTitle,
      this.bottom});
  final String? title;
  final List<Widget>? actions;
  final Widget? flexibleSpace;
  final bool? automaticallyImplyLeading;
  final Widget? widgetTitle;
  final Widget? leading;
  final double? leadingWidth;
  final TextStyle? styleTitle;
  final TabBar? bottom;
  CustomAppbar.basic({
    super.key,
    this.title,
    this.actions,
    this.flexibleSpace,
    this.automaticallyImplyLeading,
    this.widgetTitle,
    this.leadingWidth,
    this.styleTitle,
    VoidCallback? onTap,
    bool isLeading = true,
    this.bottom,
  }) : leading = isLeading ? _previousButton(onTap) : const SizedBox();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widgetTitle ??
          Text(title ?? "",
              style: styleTitle ??
                  TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      actions: actions,
      flexibleSpace: flexibleSpace,
      iconTheme: IconThemeData(color: Colors.black),
      leading: leading,
      leadingWidth: leadingWidth,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent),
      automaticallyImplyLeading: automaticallyImplyLeading ?? true,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => AppBar().preferredSize;
}

Widget _previousButton(VoidCallback? onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Icon(
        Icons.arrow_back_ios_new,
        color: Colors.black,
        size: 16,
      ),
    ),
  );
}

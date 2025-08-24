import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  const BaseScaffold({
    super.key,
    this.body,
    this.appBar,
    this.background,
    this.resizeToAvoidBottomInset,
    this.bottom,
    this.drawer,
  });
  final Widget? body;
  final Widget? bottom;
  final Widget? background;
  final PreferredSizeWidget? appBar;
  final bool? resizeToAvoidBottomInset;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottom,
      body: background ?? _defaultBackgroundV2(context),
      drawer: drawer,
    );
  }

  // Widget _defaultBackground(BuildContext context) {
  //   return Container(
  //     width: double.maxFinite,
  //     height: double.maxFinite,
  //     decoration: BoxDecoration(
  //       image: DecorationImage(
  //         image: AssetImage(Assets.newAssets.images.backGround.path),
  //         fit: BoxFit.fill,
  //       ),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.only(
  //           top: (appBar?.preferredSize.height ?? 0) +
  //               MediaQuery.of(context).padding.top),
  //       child: body,
  //     ),
  //   );
  // }

  Widget _defaultBackgroundV2(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF03F0FF).withOpacity(0.03),
              const Color(0xFF007AFF).withOpacity(0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: appBar != null
                ? (appBar!.preferredSize.height +
                    MediaQuery.of(context).padding.top)
                : 0,
          ),
          child: body,
        ),
      ),
    );
  }
}

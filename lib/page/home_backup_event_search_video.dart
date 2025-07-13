import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:group_button/group_button.dart';
import 'package:hino/model/dropdown.dart';
import 'package:hino/model/truck.dart';
import 'package:hino/page/home_car_filter.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/widget/dropbox_general_search.dart';
import 'package:hino/widget/fancy_fab.dart';

import 'dart:ui' as ui;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'home_car_sort.dart';

class HomeBackupEventSearchVideoPage extends StatefulWidget {
  const HomeBackupEventSearchVideoPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeBackupEventSearchVideoPage> {
  @override
  void initState() {
    // videoPlayerController.initialize();
    // chewieController = ChewieController(
    //   aspectRatio: videoPlayerController.value.aspectRatio,
    //   videoPlayerController: videoPlayerController,
    //   autoPlay: true,
    //   looping: false,
    // );
    // playerWidget = Chewie(
    //   controller: chewieController!,
    // );
    super.initState();
  }

  // final videoPlayerController = VideoPlayerController.network(
  //     'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');
  //
  // ChewieController? chewieController;
  //
  // Chewie? playerWidget;

  // @override
  // void dispose() {
  //   videoPlayerController.dispose();
  //   chewieController!.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToMe,
      //   label: Text('My location'),
      //   icon: Icon(Icons.near_me),
      // ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text("Video"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          // child: playerWidget,
        ),
      ),
    );
  }
}

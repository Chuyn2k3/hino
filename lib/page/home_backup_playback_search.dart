import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hino/api/api.dart';
import 'package:hino/model/history.dart';
import 'package:hino/utils/base_scaffold.dart';
import 'package:hino/utils/custom_app_bar.dart';
import 'package:hino/utils/utils.dart';

import 'dart:ui' as ui;

class HomePlaybackEventSearchPage extends StatefulWidget {
  const HomePlaybackEventSearchPage({Key? key, required this.imei})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String imei;

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomePlaybackEventSearchPage> {
  @override
  void initState() {
    getData(context);
    super.initState();
  }

  List<PlaybackHistory> listHistory = [];

  getData(BuildContext context) {
    String monthyear = DateTime.now().month < 10
        ? "0${DateTime.now().month}${DateTime.now().year}"
        : DateTime.now().month.toString() + DateTime.now().year.toString();
    Api.get(context,
            "${Api.cctv_vehicle}imei=${widget.imei}&limit=10&page=1&monthyear=$monthyear")
        .then((value) => {
              if (value != null)
                {
                  if (value.containsKey("result"))
                    {
                      listHistory = List.from(value['result']['snapshot'])
                          .map((a) => PlaybackHistory.fromJson(a))
                          .toList(),
                      isLoad = false,
                      refresh()
                    }
                  else
                    {
                      isLoad = false,
                      refresh(),
                      Utils.showAlertDialog(
                          context, "Không tìm thấy thông tin"),
                    }
                }
              else
                {}
            });
  }

  bool isLoad = true;

  refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BaseScaffold(
      appBar: CustomAppbar.basic(
        onTap: () => Navigator.pop(context),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: listHistory.isEmpty && !isLoad
                      ? Center(
                          child: Text(
                            "Không tìm thấy dữ liệu",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: listHistory.length,
                          itemBuilder: (context, index) {
                            var e = listHistory[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2, // Softer shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias, // Prevent overflow
                              child: InkWell(
                                splashColor: Colors.blueAccent.withOpacity(0.1),
                                onTap: () {
                                  // TODO: Add action for card tap (e.g., full-screen image view)
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Thumbnail with overlay
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(16)),
                                          child: Image.network(
                                            "${Api.BaseUrlBuilding}fleet${e.url}",
                                            width: double.infinity,
                                            height: screenWidth > 600
                                                ? 240
                                                : 180, // Responsive height
                                            fit: BoxFit.cover,
                                            loadingBuilder:
                                                (context, child, progress) {
                                              if (progress == null)
                                                return child;
                                              return Container(
                                                height: screenWidth > 600
                                                    ? 240
                                                    : 180,
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: progress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? progress
                                                                .cumulativeBytesLoaded /
                                                            progress
                                                                .expectedTotalBytes!
                                                        : null,
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: screenWidth > 600
                                                    ? 240
                                                    : 180,
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                    size: 40,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Channel badge overlay
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent
                                                  .withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "Kênh ${e.channel_no}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Info row
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.take_photo_time,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "Kênh ${e.channel_no}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          OutlinedButton.icon(
                                            icon: const Icon(
                                              Icons.download,
                                              color: Colors.blueAccent,
                                              size: 20,
                                            ),
                                            label: const Text(
                                              "Tải",
                                              style: TextStyle(
                                                color: Colors.blueAccent,
                                                fontSize: 14,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                  color: Colors.blueAccent
                                                      .withOpacity(0.5)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                            ),
                                            onPressed: () {
                                              // TODO: Implement download functionality
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          if (isLoad)
            Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hino/model/news.dart';
import 'package:hino/model/truck.dart';
import 'package:hino/page/home_car_filter.dart';
import 'package:hino/page/home_detail.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/utils/responsive.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:hino/widget/fancy_fab.dart';

import 'dart:ui' as ui;

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'home_car_sort.dart';
import 'home_noti_event.dart';

const homeNewsDetailPageDataList1 = [
  "https://hino.vn/w/wp-content/uploads/2024/10/preorder-900x600-1.jpg",
"KHUYẾN MẠI ĐẶT TRƯỚC XE HINO FG/FL/FM EURO5",
"Những chiếc xe Hino Series 500 từ lâu đã được biết đến với tiêu chí Chất lượng – Bền bỉ – Tin cậy, và sắp tới, chúng sẽ còn thân thiện với môi trường hơn nữa. Hino Motors Việt Nam xin trân trọng giới thiệu chương trình khuyến mại đặc biệt dành cho khách hàng đặt trước các dòng xe FG, FL và FM Euro5.\n\nNội dung khuyến mại:\n\nTặng ngay 10 triệu đồng cho mỗi xe.\nTặng thêm 50% phí bảo hiểm Hino (vật chất xe) trong 1 năm, tương đương:\n12.000.000 VND cho xe FG\n14.000.000 VND cho xe FL, FM\n(Áp dụng cho xe có ứng dụng thùng nằm trong danh mục cung cấp dịch vụ bảo hiểm Hino)\n\nThời gian áp dụng:\n\nChương trình áp dụng cho khách hàng ký hợp đồng và đặt cọc mua xe từ 01/10/2024 đến 31/12/2024.\n\nĐể biết thêm thông tin chi tiết và điều kiện áp dụng, quý khách vui lòng liên hệ với đại lý chính hãng gần nhất. Danh sách đại lý có thể tham khảo tại HINO MOTORS VIETNAM | Xe tải Hino, 300 Series, 500 Series, 700 Series, Hino Việt Nam\n\nChúng tôi rất mong muốn được đồng hành cùng quý khách hàng trong hành trình sở hữu những chiếc xe Hino chất lượng cao và thân thiện với môi trường."
];

const homeNewsDetailPageDataList2 = [
  "https://hino.vn/w/wp-content/uploads/2024/10/SS2P-900x600-2.jpg",
  "KHUYẾN MẠI DÀNH CHO KHÁCH HÀNG MUA XE ĐẦU KÉO SS2P EURO5",
  "Nhằm hỗ trợ khách hàng trong việc lựa chọn chiếc xe phù hợp, Hino Motors Việt Nam xin giới thiệu chương trình khuyến mại mới dành cho khách hàng mua xe đầu kéo SS2P Euro5.\nThời gian áp dụng:\n\nTừ 01/10/2024 đến 31/12/2024.\n\nNội Dung Khuyến Mại:\n\nHỗ trợ 2% lãi suất vay năm đầu khi khách hàng vay qua HFS.\nTặng 50% phí bảo hiểm vật chất xe Hino năm đầu (tương đương 16.500.000 VNĐ).\n(Áp dụng cho xe có ứng dụng thùng nằm trong danh mục cung cấp dịch vụ bảo hiểm Hino)\n\nQuý khách hàng vui lòng liên hệ với đại lý chính hãng gần nhất để biết thêm thông tin chi tiết và điều kiện áp dụng. Danh sách đại lý quý khách có thể tham khảo tại  HINO MOTORS VIETNAM | Xe tải Hino, 300 Series, 500 Series, 700 Series, Hino Việt Nam"
];

const homeNewsDetailPageDataList3 = [
  "https://hino.vn/w/wp-content/uploads/2024/10/sale-XZU-900x600-1.jpg",
  "KHUYẾN MẠI DÀNH CHO KHÁCH HÀNG MUA XE XZU EURO5",
  "Là một trong những nhà sản xuất xe tải hàng đầu tại Việt Nam, Hino Motors Việt Nam luôn nỗ lực cải tiến không ngừng để đáp ứng nhu cầu của khách hàng. Chúng tôi cũng đặc biệt quan tâm trong việc mang đến những sản phẩm thân thiện với môi trường, các mẫu xe Euro5 ra đời thể hiện cam kết này.\n\nNhằm hỗ trợ khách hàng trong việc lựa chọn chiếc xe phù hợp, Hino Motors Việt Nam xin giới thiệu chương trình khuyến mại dành cho khách hàng mua xe XZU Euro5.\n\nThời gian áp dụng:\n\nTừ 01/10/2024 đến 31/12/2024.\n\nNội dung khuyến mại:\n\nHỗ trợ 2% lãi suất vay năm đầu khi khách hàng vay qua HFS.\nTặng 50% phí bảo hiểm vật chất xe Hino năm đầu (tương đương 6.000.000 VNĐ).\n(Áp dụng cho xe có ứng dụng thùng nằm trong danh mục cung cấp dịch vụ bảo hiểm Hino)\n\nQuý khách hàng vui lòng liên hệ với đại lý chính hãng gần nhất để biết thêm thông tin chi tiết và điều kiện áp dụng. Danh sách đại lý quý khách có thể tham khảo tại  HINO MOTORS VIETNAM | Xe tải Hino, 300 Series, 500 Series, 700 Series, Hino Việt Nam"
];

const homeNewsDetailPageDataList4 = [
  "https://hino.vn/w/wp-content/uploads/2024/10/Feature.png",
  "GÓI BẢO DƯỠNG ƯU ĐÃI DÀNH CHO KHÁCH HÀNG LỚN (FCP)",
  "Với mục tiêu hỗ trợ tổng thể và toàn diện cho khách hàng sử dụng xe Hino, đặc biệt với những khách hàng ở hữu số lượng lớn xe tải Hino, Hino Motors Việt Nam đã và đang liên tục triển khai những chương trình hỗ trợ khách hàng lớn với mong muốn được đồng hành cũng những khách hàng đã tin tưởng và lựa chọn Hino.\n\nTrong đó, Hino xin trân trọng giới thiệu đến quý khách hàng Gói Bảo Dưỡng FCP, gói bảo dưỡng ưu đãi dành riêng cho khách hàng lớn.\n\nChi tiết thông tin Gói Bảo Dưỡng FCP như sau:\n\nĐối tượng áp dụng:\nĐối tượng khách hàng:\n\n– Áp dụng cho các khách hàng sở hữu từ 20 xe Hino trở lên hoặc khách hàng sở hữu từ 50 xe tải (bao gồm Hino và các hãng khác) trở lên.\n\n– Áp dụng cho khách hàng mang xe đến trạm dịch vụ hoặc sử dụng dịch vụ sửa chữa, xe lưu động của Đại lý chính hãng Hino.\n\nĐối tượng xe:\n\n– Xe thuộc đối tượng chương trình Bảo Dưỡng Tối Ưu – HMP và đã áp dụng hết chương trình\n\n– Series 500: Có số km lớn hơn 340,000\n\n– Series 300: Có số km lớn hơn 260,000\n\n– Xe thuộc đối tượng chương trình Bảo Dưỡng Miễn Phí – FMP và đã sử dụng hết chương trình\n\nThời hạn áp dụng: từ tháng 4/2024 đến hết tháng 3/2025\nNội dung Gói Bảo Dưỡng Ưu Đãi Dành Cho Khách Hàng Lớn – FCP:\n– Giảm giá 20% chi phí phụ tùng và nhân công\n\n– Mỗi model gồm 2 gói:\n\nFCP tiêu chuẩn\nFCP rút gọn\n– Mỗi gói gồm 3 cấp bảo dưỡng 40,000km; 60,000km; 80,000km hoặc km tương đương.\nGhi chú: • Hạng mục cần thiết           ○ Hạng mục tùy chọn\n\nThời hạn sử dụng: 12 tháng (Khách hàng cần hoàn thành 3 cấp bảo dưỡng trong 12 tháng, quá thời hạn trên sẽ không được hỗ trợ giảm giá theo Gói FCP)\n\n\nLưu ý:\n\nĐể tham gia chương trình, khách hàng phải ký Biên bản xác nhận sử dụng Gói FCP\nKhách hàng không phải trả tiền trước khi sử dụng gói mà trả tiền tại mỗi lần sử dụng gói\nĐể biết thêm thông tin liên quan đến chương trình và điều kiện áp dụng, vui lòng liên hệ Đại lý Hino chính hãng gần nhất."
];

class HomeNewsDetailPage1 extends StatefulWidget {
  const HomeNewsDetailPage1({Key? key}) : super(key: key);

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

class _PageState extends State<HomeNewsDetailPage1> {
  @override
  void initState() {
    super.initState();
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackIOS(),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.network(homeNewsDetailPageDataList1[0], fit: BoxFit.fitWidth),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      homeNewsDetailPageDataList1[1],
                      style: TextStyle(
                        color: ColorCustom.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ColorCustom.black,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.thumb_up_off_alt,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Like',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.share,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Share',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  homeNewsDetailPageDataList1[2],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: Image.asset(
                        "assets/images/hino_icon.png",
                        width: 40,
                        height: 40,
                      ),
                      padding: EdgeInsets.all(5),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hino Motors Vietnam',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '10 post · Updated last week',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeNewsDetailPage2 extends StatefulWidget {
  const HomeNewsDetailPage2({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _PageState2 createState() => _PageState2();
}

class _PageState2 extends State<HomeNewsDetailPage2> {
  @override
  void initState() {
    super.initState();
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackIOS(),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.network(homeNewsDetailPageDataList2[0], fit: BoxFit.fitWidth),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      homeNewsDetailPageDataList2[1],
                      style: TextStyle(
                        color: ColorCustom.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ColorCustom.black,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.thumb_up_off_alt,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Like',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.share,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Share',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  homeNewsDetailPageDataList2[2],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: Image.asset(
                        "assets/images/hino_icon.png",
                        width: 40,
                        height: 40,
                      ),
                      padding: EdgeInsets.all(5),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hino Motors Vietnam',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '10 post · Updated last week',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeNewsDetailPage3 extends StatefulWidget {
  const HomeNewsDetailPage3({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _PageState3 createState() => _PageState3();
}

class _PageState3 extends State<HomeNewsDetailPage3> {
  @override
  void initState() {
    super.initState();
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackIOS(),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.network(homeNewsDetailPageDataList3[0], fit: BoxFit.fitWidth),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      homeNewsDetailPageDataList3[1],
                      style: TextStyle(
                        color: ColorCustom.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ColorCustom.black,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.thumb_up_off_alt,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Like',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.share,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Share',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  homeNewsDetailPageDataList3[2],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: Image.asset(
                        "assets/images/hino_icon.png",
                        width: 40,
                        height: 40,
                      ),
                      padding: EdgeInsets.all(5),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hino Motors Vietnam',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '10 post · Updated last week',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeNewsDetailPage4 extends StatefulWidget {
  const HomeNewsDetailPage4({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _PageState4 createState() => _PageState4();
}

class _PageState4 extends State<HomeNewsDetailPage4> {
  @override
  void initState() {
    super.initState();
  }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              BackIOS(),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.network(homeNewsDetailPageDataList4[0], fit: BoxFit.fitWidth),
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      homeNewsDetailPageDataList4[1],
                      style: TextStyle(
                        color: ColorCustom.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ColorCustom.black,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.thumb_up_off_alt,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Like',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: ColorCustom.greyBG,
                      ),
                      child: InkWell(
                        onTap: () {
                          // showFilter();
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.share,
                              size: 20,
                              color: ColorCustom.blue,
                            ),
                            Text(
                              'Share',
                              style: TextStyle(
                                color: ColorCustom.blue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  homeNewsDetailPageDataList4[2],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: Image.asset(
                        "assets/images/hino_icon.png",
                        width: 40,
                        height: 40,
                      ),
                      padding: EdgeInsets.all(5),
                    ),
                    SizedBox(width: 10,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hino Motors Vietnam',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '10 post · Updated last week',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
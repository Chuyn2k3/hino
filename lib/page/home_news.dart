import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hino/model/news.dart';
import 'package:hino/page/home_news_detail.dart';
import 'package:hino/utils/color_custom.dart';
import 'package:hino/widget/back_ios.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../api/api.dart';

class HomeNewsPage extends StatefulWidget {
  const HomeNewsPage({Key? key}) : super(key: key);

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<HomeNewsPage> {
  List<News> listNews = [];
  int selectedFilterIndex = 0;

  // Modern color palette
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color accentOrange = Color(0xFFEA580C);
  static const Color backgroundGrey = Color(0xFFF8FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    getNews(context);
  }

  getNews(BuildContext context) {
    Api.get(context, Api.news).then((value) {
      if (value != null) {
        listNews = List.from(value['result']['news_management'])
            .map((a) => News.fromJson(a))
            .toList();
        setState(() {});
      }
    });
  }

  showDetail1() {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const HomeNewsDetailPage1(),
    );
  }

  showDetail2() {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const HomeNewsDetailPage2(),
    );
  }

  showDetail3() {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const HomeNewsDetailPage3(),
    );
  }

  showDetail4() {
    showBarModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const HomeNewsDetailPage4(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, primaryBlueLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
          // const Spacer(),
              Text(
                "Thông báo",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Cập nhật tin tức và khuyến mãi mới nhất",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabSection(BuildContext context) {
    return DefaultTabController(

      length: 2,
      child: Column(
        children: [
          // Enhanced TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: backgroundGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TabBar(indicatorColor: Colors.transparent,
              tabs: const [
                Tab(text: "Tin tức"),
                Tab(text: "Khuyến mãi"),
              ],
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryBlue, primaryBlueLight],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: textGrey,
              labelStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              children: [
                _buildNewsGrid(context),
                _buildPromotionGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsGrid(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
            children: [
              _newsCard(homeNewsDetailPageDataList1, showDetail1, true),
              _newsCard(homeNewsDetailPageDataList2, showDetail2, false),
              _newsCard(homeNewsDetailPageDataList3, showDetail3, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionGrid(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
            children: [
              _newsCard(homeNewsDetailPageDataList4, showDetail4, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _newsCard(List<String> data, Function() onTap, bool isFeatured) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Hero(
                      tag: data[0],
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: Image.network(
                          data[0],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (isFeatured)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            accentOrange,
                            accentOrange.withOpacity(0.8)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'HOT',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Enhanced content section
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data[1],
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      data[2],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textGrey,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _tabSection(context)),
          ],
        ),
      ),
    );
  }
}

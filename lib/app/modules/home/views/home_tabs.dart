import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/demo_details/views/demo_details_view.dart';
import 'package:ibo_clone/app/modules/home/controllers/home_tab_controller.dart';
import 'package:ibo_clone/app/modules/home/views/live_page.dart';
import 'package:ibo_clone/app/modules/home/views/movies_page.dart';
import 'package:ibo_clone/app/modules/home/views/series_page.dart';
import 'package:sizer/sizer.dart';

import '../../../const/appColors.dart';

class HomeTabs extends StatefulWidget {
  final int initialTabIndex;
  const HomeTabs({super.key, required this.initialTabIndex});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  final HomeTabController controller = Get.put(HomeTabController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure initial tab is set safely after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.changeTabByIndex(widget.initialTabIndex);
    });
    _searchController.addListener(() {
      setState(() {}); // rebuilds _buildContent with updated query
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimColor,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(),
          Divider(color: Colors.grey, thickness: 2),
          // Single Obx for efficiency
          Expanded(
            child: Obx(() {
              final selected = controller.selectedTab.value;
              return _buildContent(selected);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 11.h, left: 1.w, right: 1.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabItem("home", onTap: () {
                if (controller.selectedTab.value != "home") {
                  controller.changeTab("home");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeView()),
                  );
                }
              }),
              _buildTabItem("live", onTap: () {
                controller.changeTab("live");
                _searchController.clear();
              }),
              _buildTabItem("movies", onTap: () {
                controller.changeTab("movies");
                _searchController.clear();
              }),
              _buildTabItem("series", onTap: () {
                controller.changeTab("series");
                _searchController.clear();
              }),
              _buildSearchBar(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Image.asset(
            'assets/images/bglog.png',
            width: 40.sp,
            height: 30.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String key, {required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w, right: 1.w),
      child: GestureDetector(
        onTap: onTap,
        child: Obx(() {
          final isSelected = controller.selectedTab.value == key;
          return Text(
            key.tr, // show translated label
            style: TextStyle(
              color: isSelected ? Colors.yellow : Colors.white,
              fontSize: isSelected ? 16.5.sp : 16.sp,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 8.h,
      width: 66.sp,
      margin: EdgeInsets.only(left: 20),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(35.0.sp),
        border: Border.all(color: kSecColor, width: 4.sp),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                hintStyle: TextStyle(color: Colors.white, fontSize: 16.sp),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String selected) {
    final query = _searchController.text.toLowerCase();

    switch (selected) {
      case "live":
        return LivePage(searchQuery: query);
      case "movies":
        return MoviesPage(searchQuery: query);
      case "series":
        return SeriesPage(searchQuery: query);
      default:
        return Container(); // fallback
    }
  }

}

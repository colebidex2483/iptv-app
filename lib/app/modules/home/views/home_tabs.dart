import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/demo_details/views/demo_details_view.dart';
import 'package:ibo_clone/app/modules/home/controllers/home_tab_controller.dart';
import 'package:ibo_clone/app/modules/home/views/live_page.dart';
import 'package:ibo_clone/app/modules/home/views/movies_page.dart';
import 'package:ibo_clone/app/modules/home/views/series_page.dart';
import 'package:sizer/sizer.dart';

import '../../../const/appColors.dart';

class HomeTabs extends StatelessWidget {
  final HomeTabController controller = Get.put(HomeTabController());
  final TextEditingController _searchController = TextEditingController();
  final int initialTabIndex;

  HomeTabs({super.key, required this.initialTabIndex}) {
    controller.changeTabByIndex(initialTabIndex);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimColor,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 11.h, left: 1.w, right: 1.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTabItem(context, 'Home', () {
                      if (controller.selectedTab.value != 'Home') {
                        controller.changeTab('Home');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeView()));
                      }
                    }),
                    _buildTabItem(context, 'Live', () {
                      controller.changeTab('Live');
                    }),
                    _buildTabItem(context, 'Movies', () {
                      controller.changeTab('Movies');
                    }),
                    _buildTabItem(context, 'Series', () {
                      controller.changeTab('Series');
                    }),
                    Container(
                      height: 8.h,
                      width: 66.sp,
                      margin: EdgeInsets.only(left: 20),
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(35.0.sp),
                          border: Border.all(
                            color: kSecColor,
                            width: 4.sp,
                          )),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 16.sp),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Image.asset('assets/images/bglog.png',
                    width: 40.sp, height: 30.sp),
              ),
            ],
          ),
          Divider(
            color: Colors.grey,
            thickness: 2,
          ),
          // Main content
          Expanded(
            child: Obx(() {
              return _buildContent();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: 1.w, right: 1.w),
        child: Row(
          children: [
            Obx(() {
              return Text(
                label,
                style: TextStyle(
                  color: controller.selectedTab.value == label
                      ? Colors.yellow
                      : Colors.white,
                  fontSize:
                      controller.selectedTab.value == label ? 16.5.sp : 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (controller.selectedTab.value) {
      case 'Live':
        return LivePage();
      case 'Movies':
        return MoviesPage();
      case 'Series':
        return SeriesPage();
      default:
        return Container(); // Empty container for 'Home' tab
    }
  }
}

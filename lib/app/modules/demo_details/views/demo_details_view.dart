import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/change_playlist/views/change_playlist.dart';
import 'package:ibo_clone/app/modules/home/views/home_tabs.dart';
import 'package:ibo_clone/app/modules/settings/views/settings_view.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../const/appColors.dart';
import '../controllers/demo_details_controller.dart';

class HomeView extends GetView<DemoDetailsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kBtnColor, kPrimColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 1.h),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    'Current playlist expires: unlimited',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: .5.h),
              Image.asset(
                'assets/images/bglog.png',
                height: 20.h,
                width: 20.h,
              ),
              // Button grid
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeTabs(initialTabIndex: 0),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        padding: EdgeInsets.all(20.sp),
                        decoration: BoxDecoration(
                          color: kSecColor,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.live_tv_rounded,
                                color: Colors.white, size: 35.sp),
                            SizedBox(height: 1.h),
                            MyText(
                              text: 'Live',
                              color: Colors.white,
                              size: 18.sp,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCustomContainer(
                              icon: Icons.movie,
                              label: 'Movies',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeTabs(initialTabIndex: 1),
                                  ),
                                );
                              },
                              color: Colors.red,
                              context: context,
                            ),
                            SizedBox(width: 2.w),
                            _buildCustomContainer(
                              icon: Icons.video_library,
                              label: 'Series',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeTabs(initialTabIndex: 2),
                                  ),
                                );
                              },
                              color: Colors.deepPurple,
                              context: context,
                            ),
                          ],
                        ),
                        SizedBox(
                            height: 2.h), // Add some space between the rows
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildCustomContainer(
                              icon: Icons.account_circle,
                              label: 'Account',
                              onPressed: () {},
                              color: Colors.blue,
                              context: context,
                            ),
                            SizedBox(width: 2.w),
                            _buildCustomContainer(
                              icon: Icons.playlist_add,
                              label: 'Change Playlist',
                              onPressed: () {
                                Get.to(() => ChangePlaylist());
                              },
                              color: Colors.green,
                              context: context,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildText(Icons.settings, 'Settings', () {
                          Get.to(() => SettingsView());
                        }),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.11,
                        ),
                        _buildText(Icons.refresh, 'Reload', () {}),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.11,
                        ),
                        _buildText(Icons.exit_to_app, 'Exit', () {
                          _showExitDialog(context);
                        }),
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

  Widget _buildCustomContainer({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.16,
        height: MediaQuery.of(context).size.height * 0.215,
        decoration: BoxDecoration(
          color: kSecColor,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(height: 1.h),
            MyText(
              text: label,
              color: Colors.white,
              size: 15.sp,
              weight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22.sp),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          backgroundColor: kPrimColor,
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.3, // Adjust width as needed
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: kPrimColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // Add your exit logic here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
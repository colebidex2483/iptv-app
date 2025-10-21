import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/change_playlist/views/change_playlist.dart';
import 'package:ibo_clone/app/modules/home/views/home_tabs.dart';
import 'package:ibo_clone/app/modules/settings/views/settings_view.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';
import '../../../const/appColors.dart';
import '../controllers/demo_details_controller.dart';
import 'package:ibo_clone/app/modules/on_boarding/controllers/onboarding_controller.dart';
import 'package:intl/intl.dart';
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
                    "current_playlist".trParams({"name": "Trial"}),
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
                            builder: (context) => HomeTabs(initialTabIndex: 1),
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
                              text: "live".tr,
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
                              label: "movies".tr,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeTabs(initialTabIndex: 2),
                                  ),
                                );
                              },
                              color: Colors.red,
                              context: context,
                            ),
                            SizedBox(width: 2.w),
                            _buildCustomContainer(
                              icon: Icons.video_library,
                              label: 'series'.tr,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeTabs(initialTabIndex: 3),
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
                              label: 'account'.tr,
                              onPressed: () {
                                _showAccountInfoDialog(context);
                              },
                              color: Colors.blue,
                              context: context,
                            ),
                            SizedBox(width: 2.w),
                            _buildCustomContainer(
                              icon: Icons.playlist_add,
                              label: 'change_playlist'.tr,
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
                        _buildText(Icons.settings, 'settings'.tr, () {
                          Get.to(() => SettingsView());
                        }),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.11,
                        ),
                        _buildText(Icons.refresh, 'reload'.tr, () {
                          // controller.fetchDeviceInfo(); // replace with your actual reload logic
                          Get.snackbar("reload".tr, "reload_message".tr,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white);
                        }),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.11,
                        ),
                        _buildText(Icons.exit_to_app, 'exit'.tr, () {
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
                  'exit_confirm'.tr,
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
                        'cancel'.tr,
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
                        SystemNavigator.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      child: Text(
                        'yes'.tr,
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

void _showAccountInfoDialog(BuildContext context) {
  final onboardingController = Get.find<OnboardingController>();
  final deviceId = onboardingController.deviceId.value;
  final deviceKey = onboardingController.deviceKey.value;
  final expiryDate = onboardingController.trialStartDate.value
      .add(const Duration(days: OnboardingController.trialDurationDays));
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.deepPurple.shade900, // or your light blue if desired
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "account_info".tr,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              _buildInfoRow("mac_id".tr, deviceId),
              SizedBox(height: 1.h),
              _buildInfoRow("device_key".tr, deviceKey),
              _buildInfoRow("expiry_date".tr, onboardingController.isActivated.value
                  ? "activated_forever".tr
                  : DateFormat("yyyy-MM-dd").format(expiryDate)), // update if dynamic
              SizedBox(height: 2.h),
              Text(
                "visit_website".tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildInfoRow(String title, String value) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(color: Colors.white70, fontSize: 13.sp),
      ),
      SizedBox(height: 0.5.h),
      Text(
        value,
        style: TextStyle(color: Colors.white, fontSize: 15.sp),
      ),
    ],
  );
}

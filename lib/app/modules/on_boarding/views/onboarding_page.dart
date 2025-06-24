// modules/on_boarding/view/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:ibo_clone/app/widgets/common_image_view_widget.dart';
import 'package:ibo_clone/app/widgets/my_button_widget.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:ibo_clone/app/modules/demo_details/views/demo_details_view.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../const/appColors.dart';
import '../../../const/spaces.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          final isTrialActive = controller.isTrialActive.value;
          final daysLeft = controller.daysLeft.value;
          final deviceId = controller.deviceId.value;
          final deviceKey = controller.deviceKey.value;

          return Stack(
            children: [
              // Background image
              Positioned.fill(
                child: CommonImageView(
                  imagePath: 'assets/images/log.jpg',
                  fit: BoxFit.cover,
                ),
              ),

              // Black mask with opacity
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                ),
              ),

              // Main content
              Positioned.fill(
                child: Row(
                  children: [
                    // Left side: Centered text and buttons
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isTrialActive) ...[
                              MyText(
                                textAlign: TextAlign.center,
                                text: daysLeft > 0
                                    ? "You have $daysLeft days of free trial remaining"
                                    : "This is your last day of free trial",
                                color: Colors.white,
                                size: 18.sp,
                                weight: FontWeight.w500,
                              ),
                              Spaces.y2,
                              MyText(
                                text: 'To add/manage the playlists, use following\n values on website:',
                                color: Colors.white,
                                size: 18.sp,
                                weight: FontWeight.w500,
                                textAlign: TextAlign.center,

                              ),
                              Spaces.y2,
                              MyText(
                                text: 'https://livecostplayer.com',
                                color: Colors.yellow,
                                size: 18.sp,
                                weight: FontWeight.w500,
                              ),
                            ] else ...[
                              MyText(
                                text: 'Your trial has expired',
                                color: Colors.white,
                                weight: FontWeight.w600,
                                size: 20.sp,
                              ),
                              Spaces.y3,
                              MyText(
                                textAlign: TextAlign.center,
                                text: "To continue the app, please pay €7.99 via website.",
                                color: Colors.white,
                                size: 18.sp,
                                weight: FontWeight.w500,
                              ),
                              Spaces.y2,
                              MyText(
                                text: 'https://livecostplayer.com',
                                color: Colors.yellow,
                                size: 18.sp,
                                weight: FontWeight.w500,
                              ),
                            ],
                            Spaces.y2,
                            MyText(
                              text: 'Device ID',
                              color: Colors.white,
                              size: 18.sp,
                              weight: FontWeight.w500,
                            ),
                            Spaces.y1,
                            MyText(
                              text: deviceId,
                              color: Colors.yellow,
                              size: 17.sp,
                              weight: FontWeight.w500,
                            ),
                            Spaces.y2,
                            MyText(
                              text: 'Activation Key',
                              color: Colors.white,
                              size: 18.sp,
                              weight: FontWeight.w500,
                            ),
                            Spaces.y1,
                            MyText(
                              text: deviceKey,
                              color: Colors.yellow,
                              size: 17.sp,
                              weight: FontWeight.w500,
                            ),
                            if (isTrialActive) ...[
                              Spaces.y2,
                              MyText(
                                text: 'Trial started on: ${DateFormat('yyyy-MM-dd').format(controller.trialStartDate.value)}',
                                color: Colors.white70,
                                size: 14.sp,
                              ),
                            ],
                            Spaces.y10,
                            // Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isTrialActive) ...[
                                  MyButton(
                                    backgroundColor: kPrimColor,
                                    width: 18.w,
                                    height: 8.h,
                                    buttonText: 'RELOAD',
                                    textSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    onTap: () {
                                      controller.checkTrialStatus();
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  MyButton(
                                    backgroundColor: kPrimColor,
                                    width: 18.w,
                                    height: 8.h,
                                    buttonText: 'CONTINUE',
                                    textSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    onTap: () {
                                      Get.to(() => HomeView());
                                    },
                                  ),
                                ] else ...[
                                  MyButton(
                                    backgroundColor: kPrimColor,
                                    width: 18.w,
                                    height: 8.h,
                                    buttonText: 'OPEN WEBSITE',
                                    textSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    onTap: () {
                                      controller.launchPaymentWebsite();
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  MyButton(
                                    backgroundColor: kPrimColor,
                                    width: 18.w,
                                    height: 8.h,
                                    buttonText: 'EXIT',
                                    textSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    onTap: () {
                                      SystemNavigator.pop(); // Close the app
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right side: Column with two images and text
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CommonImageView(
                              imagePath: 'assets/images/log.jpg',
                              width: 30.sp,
                              height: 30.sp,
                            ),
                            const SizedBox(height: 25),
                            CommonImageView(
                              imagePath: 'assets/images/log.jpg',
                              width: 55.sp,
                              height: 55.sp,
                            ),
                            const SizedBox(height: 10),
                            MyText(
                              text: 'Scan QR to add playlist',
                              textAlign: TextAlign.center,
                              weight: FontWeight.w500,
                              color: Colors.yellow,
                              size: 16.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
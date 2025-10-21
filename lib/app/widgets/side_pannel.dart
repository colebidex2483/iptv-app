import 'package:flutter/material.dart';
import 'package:ibo_clone/app/widgets/my_button_widget.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import '../const/spaces.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/on_boarding/controllers/onboarding_controller.dart';

class SidePannel extends StatelessWidget {
  const SidePannel({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingController = Get.find<OnboardingController>();
    final deviceId = onboardingController.deviceId.value;
    final deviceKey = onboardingController.deviceKey.value;

    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(left: 8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyButton(
              width: 20.w,
              height: 8.h,
              onTap: () {
                onboardingController.launchPaymentWebsite();
              },
              backgroundColor: kPrimColor,
              buttonText: "open_website".tr,
              textColor: Colors.white,
              textSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            Spaces.y3,
            MyText(
              text: "mac_free_trial".tr,
              color: Colors.white,
              size: 16.sp,
              weight: FontWeight.w500,
            ),
            SizedBox(height: 8),
            MyText(
              text: "free_trial_message".tr,
              color: Colors.white,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
            Spaces.y2,
            MyText(
              text: "https://livecostplayer.com/",
              color: kOrangeColor,
              size: 16.sp,
              weight: FontWeight.w600,
            ),
            Spaces.y2,
            MyText(
              text: "mac_address".tr,
              color: Colors.white,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
            MyText(
              text: deviceId,
              color: kOrangeColor,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
            Spaces.y2,
            MyText(
              text: "device_key".tr,
              color: Colors.white,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
            MyText(
              text: deviceKey,
              color: kOrangeColor,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}

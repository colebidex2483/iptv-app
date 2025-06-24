import 'package:flutter/material.dart';
import 'package:ibo_clone/app/widgets/my_button_widget.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import '../const/spaces.dart';

class SidePannel extends StatelessWidget {
  const SidePannel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35, // Adjust width as needed
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(left: 8), // Spacing from other elements
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyButton(
              width: 20.w,
              height: 8.h,
              onTap: () {}, // Open website action
              backgroundColor: kPrimColor,
              buttonText: "Open Website",
              textColor: Colors.white,
              textSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            Spaces.y3,
            MyText(
              text: "Your MAC is Free Trial",
              color: Colors.white,
              size: 16.sp,
              weight: FontWeight.w500,
            ),
            SizedBox(height: 8),
            MyText(
              text:
                  "The application can be used free of charge for first 15 days.",
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
              text: "Mac Address",
              color: Colors.white,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
            MyText(
              text: "11:f4:ef:08:6f:ba",
              color: kOrangeColor,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
            Spaces.y2,
            MyText(
              text: "Device key",
              color: Colors.white,
              size: 16.sp,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
            MyText(
              text: "1234",
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

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../const/appColors.dart';
import '../const/spaces.dart';
import 'my_button_widget.dart';
import 'my_text_field_widget.dart';
import 'my_text_widget.dart';

class ParentalControl extends StatelessWidget {
  const ParentalControl({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: kPrimColor,
        surfaceTintColor: Colors.white,
        title: MyText(
          text: 'Parental Control',
          color: Colors.white,
          textAlign: TextAlign.center,
          weight: FontWeight.w600,
          size: 18.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextField(
              hint: 'Password',
              isObSecure: true,
            ),
            Spaces.y1,
            MyTextField(
              hint: 'New Password',
              isObSecure: true,
            ),
            Spaces.y1,
            MyTextField(
              hint: 'Confirm Password',
              isObSecure: true,
            ),
          ],
        ),
        actions: [
          BorderButton(
            width: 10 * 2.w,
            borderColor: kSecColor,
            textColor: Colors.white,
            buttonText: 'Cancel',
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: 2,
            // shapeBorder: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(2),
            // ),
          ),
          MyButton(
            backgroundColor: kSecColor,
            width: 10 * 2.w,
            onTap: () {},
            buttonText: 'Ok',
            borderRadius: 2,

          ),
        ],
      ),
    );
  }
}
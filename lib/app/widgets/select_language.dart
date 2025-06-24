import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:sizer/sizer.dart';

import '../const/spaces.dart';
import 'my_button_widget.dart';
import 'my_text_widget.dart';

class SelectLanguage extends StatelessWidget {
  const SelectLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: kPrimColor,
        surfaceTintColor: Colors.white,
        title: MyText(
          text: 'Select Language',
          color: kwhite,
          textAlign: TextAlign.center,
          weight: FontWeight.w600,
          size: 18.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        content: SizedBox(
          width: 100.w,
          child: ListView(
            children: [
              ListTile(
                  title: MyText(
                text: 'English',
                color: kwhite,
                size: 16,
                weight: FontWeight.w600,
              )),
              ListTile(
                  title: MyText(
                text: 'Spanish',
                color: kwhite,
                weight: FontWeight.w600,
              )),
              ListTile(
                  title: MyText(
                text: 'French',
                color: kwhite,
                weight: FontWeight.w600,
              )),
              ListTile(
                  title: MyText(
                text: 'German',
                color: kwhite,
                weight: FontWeight.w600,
              )),
              ListTile(
                  title: MyText(
                text: 'Chinese',
                color: kwhite,
                weight: FontWeight.w600,
              )),
            ],
          ),
        ),
        actions: [
          BorderButton(
              borderColor: kSecColor,
              textColor: kwhite,
              width: 100,
              onTap: () => Navigator.pop(context),
              buttonText: 'Cancel',
            borderRadius: 2,
          ),
          Spaces.y2,
          MyButton(
              backgroundColor: kSecColor,
              width: 100,
              onTap: () => Navigator.pop(context),
              buttonText: 'Ok',
            borderRadius: 2,

          )
        ]);
  }
}

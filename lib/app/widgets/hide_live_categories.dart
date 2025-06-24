import 'package:flutter/material.dart';
import 'package:ibo_clone/app/widgets/my_button_widget.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import 'my_text_widget.dart';

class HideLiveCategories extends StatelessWidget {
  const HideLiveCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kPrimColor,
      surfaceTintColor: Colors.white,
      title: MyText(
        text: 'Hide Live Categories',
        color: Colors.white,
        textAlign: TextAlign.center,
        weight: FontWeight.w600,
        size: 18.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: MyText(text: 'Demo ibo', color: Colors.white),
              value: false,
              onChanged: (value) {},
            ),
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
        MyButton(
          backgroundColor: kSecColor,
          width: 100,
          onTap: () => Navigator.pop(context),
          buttonText: 'Select All',
          borderRadius: 2,
        ),
        MyButton(
          backgroundColor: kSecColor,
          width: 100,
          onTap: () => Navigator.pop(context),
          buttonText: 'Ok',
          borderRadius: 2,
        )
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import '../const/spaces.dart';
import 'my_button_widget.dart';
import 'my_text_widget.dart';

class LiveChannelSort extends StatelessWidget {
  const LiveChannelSort({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kPrimColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      title: MyText(
        text: 'Live Channel Sort',
        color: Colors.white,
        textAlign: TextAlign.center,
        weight: FontWeight.w600,
        size: 18.sp,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: MyText(
                text: 'Default',
                color: Colors.white,
              ),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: MyText(
                text: 'Order by A-Z',
                color: Colors.white,
              ),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: MyText(
                text: 'Order by Z-A',
                color: Colors.white,
              ),
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
        Spaces.y2,
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

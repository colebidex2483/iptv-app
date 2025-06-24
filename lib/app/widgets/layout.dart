import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibo_clone/app/const/appColors.dart';

import '../const/spaces.dart';
import 'my_button_widget.dart';
import 'my_text_widget.dart';

class Selectlayout extends StatelessWidget {
  Selectlayout({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kPrimColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      title: MyText(
        text: 'Select Layout',
        color: Colors.white,
        textAlign: TextAlign.center,
        weight: FontWeight.w500,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: MyText(text: 'List View', color: kwhite),
              leading: Radio(
                  value: 'list', groupValue: 'layout', onChanged: (value) {}),
            ),
            ListTile(
              title: MyText(text: 'Grid View', color: kwhite),
              leading: Radio(
                  value: 'grid', groupValue: 'layout', onChanged: (value) {}),
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
            buttonText: 'OK',
          borderRadius: 2,

        )
      ],
    );
  }
}

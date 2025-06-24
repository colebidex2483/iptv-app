import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import 'my_button_widget.dart';
import 'my_text_field_widget.dart';
import 'my_text_widget.dart';


class AddPlaylistDialog extends StatelessWidget {
  const AddPlaylistDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: kPrimColor,
        surfaceTintColor: Colors.white,
        title: MyText(
          text: 'Add Playlist',
          color: Colors.white,
          textAlign: TextAlign.center,
          weight: FontWeight.w600,
          size: 18.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        content: SingleChildScrollView(
          // Wrap the content with SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                hint: 'Playlist Name',
              ),
              SizedBox(height: 2.h),
              MyTextField(
                hint: 'https://play.google.com',
              ),
            ],
          ),
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
          ),
          MyButton(
            backgroundColor: kSecColor,
            width: 10 * 2.w,
            onTap: () {
              // Add playlist logic here
            },
            buttonText: 'Add Playlist',
          ),
        ],
      ),
    );
  }
}

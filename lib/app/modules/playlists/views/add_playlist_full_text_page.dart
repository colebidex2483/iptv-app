import 'package:flutter/material.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';

class AddPlayListFullTextPage extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const AddPlayListFullTextPage({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    final tempController = TextEditingController(text: controller.text);

    return Scaffold(
      backgroundColor: kPrimColor,
      body: Padding(
        padding: EdgeInsets.only(top: 8.h, left: 2.w, right: 2.w),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: tempController,
                autofocus: true,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, tempController.text);
              },
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                  ),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  backgroundColor: kSecColor),
              child: MyText(
                text: 'Done',
                size: 16.sp,
                weight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:sizer/sizer.dart';

class CustomTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  CustomTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(top: 3.h, left: 2.w, right: 2.w),
        child: Text(
          title,
          style: TextStyle(
              color: isSelected ? kSecColor : Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: isSelected ? 16.5.sp : 16.sp),
        ),
      ),
    );
  }
}

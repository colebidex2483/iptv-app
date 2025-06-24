import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RowWidget extends StatelessWidget {
  const RowWidget({
    required this.text1,
    required this.text2,
    required this.isSelected,
    super.key,
  });
  final String text1, text2;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text1,
            style: TextStyle(
              fontSize: 16.sp,
              color: isSelected ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            text2,
            style: TextStyle(
              fontSize: 16.sp,
              color: isSelected ? Colors.yellow : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

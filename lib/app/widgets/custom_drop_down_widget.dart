import 'package:flutter/material.dart';

import '../const/appColors.dart';
import 'my_text_widget.dart';

class CustomDropDown extends StatelessWidget {
  final String hint;
  final List<String> items;
  final String selectedValue;
  final ValueChanged<String> onChanged;
  final String? labelText;
  final Color? bgColor;
  final double? marginBottom;
  final double? width;

  const CustomDropDown({
    Key? key,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.bgColor,
    this.marginBottom = 16.0,
    this.width,
    this.labelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom ?? 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (labelText != null)
            MyText(
              text: labelText!,
              size: 12,
              color: kTertiaryColor,
              paddingBottom: 6,
              weight: FontWeight.w500,
            ),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bgColor ?? kGrey1Color,
            ),
            child: DropdownButton<String>(
              value: selectedValue == hint ? null : selectedValue,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              hint: MyText(
                text: hint,
                size: 14,
                color: kGreyColor,
                weight: FontWeight.w500,
              ),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: MyText(
                    text: item,
                    size: 14,
                    color: kQuaternaryColor,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
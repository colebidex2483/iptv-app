import 'package:flutter/material.dart';

import '../const/appColors.dart';
import '../const/app_fonts.dart';
import 'my_text_widget.dart';

// ignore: must_be_immutable
class MyTextField extends StatelessWidget {
  MyTextField({
    Key? key,
    this.controller,
    this.validator,
    this.hint,
    this.label,
    this.onChanged,
    this.isObSecure = false,
    this.marginBottom = 16.0,
    this.maxLines = 1,
    this.labelSize,
    this.prefix,
    this.suffix,
    this.labelWeight,
    this.isReadOnly,
    this.isWhite = false,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  String? label, hint;
  TextEditingController? controller;
  ValueChanged<String>? onChanged;
  bool? isObSecure, isReadOnly, isWhite;
  double? marginBottom;
  int? maxLines;
  double? labelSize;
  Widget? prefix, suffix;
  FontWeight? labelWeight;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: marginBottom!),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null)
            MyText(
              text: label ?? '',
              size: labelSize ?? 12,
              color: kTertiaryColor,
              paddingBottom: 6,
              weight: labelWeight ?? FontWeight.w500,
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TextFormField(
              onTap: onTap,
              textAlignVertical: prefix != null || suffix != null
                  ? TextAlignVertical.center
                  : null,
              cursorColor: isWhite! ? kPrimaryColor : kTertiaryColor,
              maxLines: maxLines,
              readOnly: readOnly,
              controller: controller,
              validator: validator,
              onChanged: onChanged,
              textInputAction: TextInputAction.next,
              obscureText: isObSecure!,
              obscuringCharacter: '*',
              style: TextStyle(
                fontSize: 14,
                color: isWhite! ? kPrimaryColor : kTertiaryColor,
                fontFamily: AppFonts.boston,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor:
                    isWhite! ? kPrimaryColor.withOpacity(0.2) : kGrey1Color,
                prefixIcon: prefix,
                suffixIcon: suffix,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: maxLines! > 1 ? 15 : 0,
                ),
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.boston,
                  color: isWhite! ? kPrimaryColor : kGreyColor,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isWhite! ? kSecColor : kSecColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isWhite! ? kSecColor : kSecColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isWhite! ? kSecColor : kSecColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                errorBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

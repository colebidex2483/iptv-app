import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/appColors.dart';
import 'my_text_widget.dart';

class MyButton extends StatelessWidget {
  MyButton({
    required this.buttonText,
    required this.onTap,
    this.height = 48.0,
    this.width,
    this.textSize,
    this.fontWeight,
    this.borderRadius = 50.0,
    this.customChild,
    this.backgroundColor,
    this.textColor,
    this.margin,
    this.gradient,
    this.boxShadow,
    this.padding,
    this.shapeBorder,
  });

  final String buttonText;
  final VoidCallback onTap;
  final double? height, width, textSize, borderRadius;
  final FontWeight? fontWeight;
  final Widget? customChild;
  final Color? backgroundColor, textColor;
  final EdgeInsetsGeometry? margin, padding;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final ShapeBorder? shapeBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        color: gradient == null ? backgroundColor ?? Colors.green : null,
        gradient: gradient,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 16,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
          child: customChild ??
              Center(
                child: MyText(
                  text: buttonText,
                  size: textSize ?? 15,
                  weight: fontWeight ?? FontWeight.w400,
                  color: textColor ?? Colors.white,
                ),
              ),
        ),
      ),
    );
  }
}

class BorderButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final Widget? icon; // Fully customizable icon
  final Color borderColor;
  final Color textColor;
  final double height;
  final double width;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final EdgeInsetsGeometry? margin;

  const BorderButton({
    Key? key,
    required this.buttonText,
    required this.onTap,
    this.icon,
    this.borderColor = Colors.teal,
    this.textColor = Colors.teal,
    this.height = 48.0,
    this.width = double.infinity,
    this.borderRadius = 25.0,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
    this.textStyle,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8), // Space between icon and text
                ],
                Text(
                  buttonText,
                  style: textStyle ??
                      TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import '../const/spaces.dart';
import 'my_button_widget.dart';
import 'my_text_widget.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  Locale? _selectedLocale;

  final Map<String, Locale> languages = {
    '🇺🇸 English': const Locale('en', 'US'),
    '🇪🇸 Español': const Locale('es', 'ES'),
    '🇫🇷 Français': const Locale('fr', 'FR'),
    '🇩🇪 Deutsch': const Locale('de', 'DE'),
    // '🇨🇳 中文': const Locale('zh', 'CN'),
  };

  @override
  void initState() {
    super.initState();
    _selectedLocale = Get.locale ?? const Locale('en', 'US');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kPrimColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Center(
        child: MyText(
          text: 'change_language'.tr,
          color: kwhite,
          textAlign: TextAlign.center,
          weight: FontWeight.w600,
          size: 18.sp,
        ),
      ),
      content: SizedBox(
        width: 50.w,
        height: 40.h, // 👈 ensures no RenderFlex overflow
        child: ListView(
          shrinkWrap: true,
          children: languages.entries.map((entry) {
            final isSelected = _selectedLocale == entry.value;
            return RadioListTile<Locale>(
              dense: true,
              activeColor: kSecColor,
              value: entry.value,
              groupValue: _selectedLocale,
              onChanged: (locale) {
                if (locale != null) {
                  setState(() => _selectedLocale = locale);
                  Get.updateLocale(locale);
                }
              },
              title: MyText(
                text: entry.key,
                color: isSelected ? kSecColor : kwhite,
                weight: FontWeight.w600,
                size: 14.sp,
              ),
            );
          }).toList(),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      actions: [
        BorderButton(
          borderColor: kSecColor,
          textColor: kwhite,
          width: 30.w,
          borderRadius: 8,
          onTap: () => Navigator.pop(context),
          buttonText: 'cancel'.tr,
        ),
        Spaces.x2,
        MyButton(
          backgroundColor: kSecColor,
          width: 30.w,
          borderRadius: 8,
          onTap: () => Navigator.pop(context),
          buttonText: 'ok'.tr,
        ),
      ],
    );
  }
}

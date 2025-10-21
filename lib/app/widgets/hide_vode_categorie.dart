import 'package:flutter/material.dart';
import 'package:ibo_clone/app/widgets/my_button_widget.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import '../core/hive_service.dart';
import 'my_text_widget.dart';

class HideVodeCategories extends StatefulWidget {
  final List<String> allCategories;
  final VoidCallback? onSaved;

  const HideVodeCategories({
    super.key,
    required this.allCategories,
    this.onSaved,
  });

  @override
  State<HideVodeCategories> createState() => _HideVodeCategoriesState();
}

class _HideVodeCategoriesState extends State<HideVodeCategories> {
  // keep local copy of hidden categories (strings)
  late List<String> hiddenCategories;

  @override
  void initState() {
    super.initState();
    // load from HiveService (synchronous in your HiveService)
    hiddenCategories = HiveService.getHiddenVodCategories().map((e) => e.toString()).toList();
  }

  void _toggle(String cat, bool selected) {
    setState(() {
      if (selected) {
        if (!hiddenCategories.contains(cat)) hiddenCategories.add(cat);
      } else {
        hiddenCategories.remove(cat);
      }
    });
  }

  void _selectAll() {
    setState(() {
      hiddenCategories = List<String>.from(widget.allCategories);
    });
  }

  void _saveAndClose() {
    HiveService.saveHiddenVodCategories(hiddenCategories);
    if (widget.onSaved != null) widget.onSaved!();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kPrimColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
      title: MyText(
        text: 'Hide VOD Categories',
        color: Colors.white,
        textAlign: TextAlign.center,
        weight: FontWeight.w600,
        size: 18.sp,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.allCategories.map((cat) {
            final isHidden = hiddenCategories.contains(cat);
            return CheckboxListTile(
              title: MyText(text: cat, color: Colors.white),
              value: isHidden,
              onChanged: (val) => _toggle(cat, val ?? false),
              activeColor: kSecColor,
              checkColor: Colors.white,
            );
          }).toList(),
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
        MyButton(
          backgroundColor: kSecColor,
          width: 100,
          onTap: _selectAll,
          buttonText: 'Select All',
          borderRadius: 2,
        ),
        MyButton(
          backgroundColor: kSecColor,
          width: 100,
          onTap: _saveAndClose,
          buttonText: 'Ok',
          borderRadius: 2,
        )
      ],
    );
  }
}

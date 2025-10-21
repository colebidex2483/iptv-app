import 'package:flutter/material.dart';
import 'package:ibo_clone/app/widgets/my_button_widget.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import 'my_text_widget.dart';
import '../core/hive_service.dart';

class HideLiveCategories extends StatefulWidget {
  final List<String> allCategories; // categories passed from LivePage
  final VoidCallback onSaved; // callback to refresh LivePage after saving

  const HideLiveCategories({
    super.key,
    required this.allCategories,
    required this.onSaved,
  });

  @override
  State<HideLiveCategories> createState() => _HideLiveCategoriesState();
}

class _HideLiveCategoriesState extends State<HideLiveCategories> {
  late List<String> hiddenCats;

  @override
  void initState() {
    super.initState();
    hiddenCats = List<String>.from(HiveService.getHiddenLiveCategories());
  }

  void _toggleCategory(String cat, bool? value) {
    setState(() {
      if (value == true) {
        hiddenCats.add(cat);
      } else {
        hiddenCats.remove(cat);
      }
    });
  }

  void _selectAll() {
    setState(() {
      hiddenCats = List<String>.from(widget.allCategories);
    });
  }

  void _clearAll() {
    setState(() {
      hiddenCats.clear();
    });
  }

  void _saveAndClose() {
    HiveService.saveHiddenLiveCategories(hiddenCats);
    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kPrimColor,
      surfaceTintColor: Colors.white,
      title: MyText(
        text: 'Hide Live Categories',
        color: Colors.white,
        textAlign: TextAlign.center,
        weight: FontWeight.w600,
        size: 18.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      content: SizedBox(
        width: 100.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.allCategories.map((cat) {
              return CheckboxListTile(
                value: hiddenCats.contains(cat),
                onChanged: (v) => _toggleCategory(cat, v),
                activeColor: kSecColor,
                title: MyText(text: cat, color: Colors.white),
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        BorderButton(
          borderColor: kSecColor,
          textColor: kwhite,
          width: 90,
          onTap: () => Navigator.pop(context),
          buttonText: 'Cancel',
          borderRadius: 4,
        ),
        BorderButton(
          borderColor: kSecColor,
          textColor: kwhite,
          width: 100,
          onTap: _clearAll,
          buttonText: 'Clear All',
          borderRadius: 4,
        ),
        MyButton(
          backgroundColor: kSecColor,
          width: 100,
          onTap: _selectAll,
          buttonText: 'Select All',
          borderRadius: 4,
        ),
        MyButton(
          backgroundColor: kSecColor,
          width: 100,
          onTap: _saveAndClose,
          buttonText: 'Ok',
          borderRadius: 4,
        ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../const/spaces.dart';
import 'my_text_widget.dart';

class PlaylistsWidget extends StatelessWidget {
  final String dynamicName;
  final String link;
  final void Function()? onLinkTap;

  const PlaylistsWidget({
    Key? key,
    required this.dynamicName,
    required this.link,
    this.onLinkTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText(
            color: Colors.white,
            text: dynamicName,
            textAlign: TextAlign.center,
          ),
          Spaces.y2,
          GestureDetector(
            onTap: onLinkTap,
            child: MyText(
              color: Colors.white,
              text: link,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
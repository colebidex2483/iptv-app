import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:sizer/sizer.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimColor,
      body: Padding(
        padding: EdgeInsets.only(top: 11.h, left: 2.w),
        child: Row(
          children: [
            InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: ()
              {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Container(
              height: 8.h,
              width: 80.sp,
              margin: EdgeInsets.only(left: 20),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(35.0.sp),
                  border: Border.all(
                    color: kSecColor,
                    width: 4.sp,
                  )),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle:
                            TextStyle(color: Colors.white, fontSize: 16.sp),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

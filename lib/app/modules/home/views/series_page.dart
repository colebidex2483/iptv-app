import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/search/view/search_page.dart';
import 'package:ibo_clone/app/widgets/row_widget.dart';
import 'package:sizer/sizer.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  String _selectedOrder = 'Order by Added';
  int _selectedRowIndex = 0;

  final List<String> _orderOptions = [
    'Order by Added',
    'Order by that',
    'Order by another',
  ];

  final List<String> _seriesCategories = [
    'Recently Viewed',
    'All',
    'Favourite',
    'Demo Series',
  ];

  final Map<String, List<String>> _seriesByCategory = {
    'Recently Viewed': ['Series 1', 'Series 2'],
    'All': ['Series 3', 'Series 4', 'Series 5', 'Series 6'],
    'Favourite': ['Series 7', 'Series 8'],
    'Demo Series': ['Series 9'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimColor,
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            margin: EdgeInsets.only(left: 7),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.play_circle_outline_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_sharp,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16.5.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          Get.to(() => SearchPage());
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_sharp,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 16.5.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  for (int i = 0; i < _seriesCategories.length; i++) ...[
                    InkWell(
                      onTap: ()
                      {
                        setState(() {
                          _selectedRowIndex = i;
                        });
                      },
                      child: RowWidget(
                        text1: _seriesCategories[i],
                        text2: _seriesByCategory[_seriesCategories[i]]?.length.toString() ?? '0',
                        isSelected: _selectedRowIndex == i,
                      ),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ],
              ),
            ),
          ),
          // Vertical Divider
          VerticalDivider(
            color: Colors.white,
            width: 10,
            thickness: 1,
          ),
          // Main Area
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedOrder,
                        dropdownColor: kSecColor,
                        icon: Icon(Icons.keyboard_arrow_down_outlined,
                            color: Colors.white),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedOrder = newValue!;
                          });
                        },
                        items: _orderOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      Text(
                        'All(${_seriesByCategory[_seriesCategories[_selectedRowIndex]]?.length ?? 0})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio:
                      0.68, // Adjust this value to increase/decrease the height
                    ),
                    itemCount: _seriesByCategory[_seriesCategories[_selectedRowIndex]]?.length ?? 0,
                    itemBuilder: (context, index) {
                      String series = _seriesByCategory[_seriesCategories[_selectedRowIndex]]![index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 8.0), // Add some space at the top
                            Icon(
                              Icons.perm_media_sharp,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                            Container(
                              height: 7.h,
                              width: double.infinity,
                              color: kSecColor,
                              child: Center(
                                child: Text(
                                  series,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
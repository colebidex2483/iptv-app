import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/playlists/views/add_playlist_full_text_page.dart';
import 'package:ibo_clone/app/widgets/custom_playlist_tab.dart';
import 'package:ibo_clone/app/widgets/my_text_field_widget.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';

class PlaylistTabs extends StatefulWidget {
  const PlaylistTabs({super.key});

  @override
  State<PlaylistTabs> createState() => _PlaylistTabsState();
}

class _PlaylistTabsState extends State<PlaylistTabs>
    with SingleTickerProviderStateMixin {
  final TextEditingController playlistNameOneController =
      TextEditingController();
  final TextEditingController playlistNameTwoController =
      TextEditingController();
  final TextEditingController m3uController = TextEditingController();
  final TextEditingController urlPortController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _navigateAndEdit(
      TextEditingController controller, String hintText) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPlayListFullTextPage(
          controller: controller,
          hintText: hintText,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        controller.text = result;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    playlistNameOneController.dispose();
    m3uController.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimColor,
      body: Column(
        children: [
          SizedBox(height: 8.h),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Center(
                  child: MyText(
                    text: 'Add Playlist',
                    weight: FontWeight.w600,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTab(
                title: 'ADD M3U URL',
                isSelected: _tabController.index == 0,
                onTap: () {
                  setState(() {
                    _tabController.index = 0;
                  });
                },
              ),
              SizedBox(width: 10),
              CustomTab(
                title: 'XTREAM-CODES-API',
                isSelected: _tabController.index == 1,
                onTap: () {
                  setState(() {
                    _tabController.index = 1;
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (_) {},
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Container(
                        height: 55.h,
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 6.h),
                        color: kSecColor,
                        child: Column(
                          children: [
                            // Existing Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_alt_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 2.w),
                                    MyText(
                                      text: 'Mac Address',
                                      size: 17.sp,
                                      color: Colors.white,
                                      weight: FontWeight.w700,
                                    ),
                                  ],
                                ),
                                MyText(
                                  text: '33:cf:9b:67:f3:dd',
                                  size: 17.sp,
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            // Row with TextFormFields
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // First TextFormField with label
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'Playlist Name',
                                        size: 16.sp,
                                        color: Colors.white,
                                        weight: FontWeight.w500,
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      MyTextField(
                                        hint: 'Name',
                                        readOnly: true,
                                        controller: playlistNameOneController,
                                        onTap: () => _navigateAndEdit(
                                            playlistNameOneController,
                                            'Playlist Name'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                // Second TextFormField with label
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'Enter M3U',
                                        size: 16.sp,
                                        color: Colors.white,
                                        weight: FontWeight.w500,
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      MyTextField(
                                        hint: 'http://server_domain:8080',
                                        controller: m3uController,
                                        readOnly: true,
                                        onTap: () => _navigateAndEdit(
                                            m3uController, 'Add M3U '),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Container(
                        height: 60.h, // Adjusted height for additional content
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding:
                            EdgeInsets.only(left: 5.w, right: 5.w, top: 3.h),
                        color: kSecColor,
                        child: Column(
                          children: [
                            // Existing Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_alt_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 2.w),
                                    MyText(
                                      text: 'Mac Address',
                                      size: 17.sp,
                                      color: Colors.white,
                                      weight: FontWeight.w700,
                                    ),
                                  ],
                                ),
                                MyText(
                                  text: '33:cf:9b:67:f3:dd',
                                  size: 17.sp,
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            // Row with TextFormFields
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // First TextFormField with label
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'Playlist Name',
                                        size: 16.sp,
                                        color: Colors.white,
                                        weight: FontWeight.w500,
                                      ),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      MyTextField(
                                        hint: 'Name',
                                        controller: playlistNameTwoController,
                                        readOnly: true,
                                        onTap: () => _navigateAndEdit(
                                            playlistNameTwoController,
                                            'Playlist Name'),
                                      ),
                                      MyText(
                                        text: 'Username',
                                        size: 16.sp,
                                        color: Colors.white,
                                        weight: FontWeight.w500,
                                      ),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      MyTextField(
                                        hint: 'Username',
                                        controller: usernameController,
                                        readOnly: true,
                                        onTap: () => _navigateAndEdit(
                                            usernameController, 'Username'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                // Second TextFormField with label
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'URL + PORT',
                                        size: 16.sp,
                                        color: Colors.white,
                                        weight: FontWeight.w500,
                                      ),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      MyTextField(
                                        hint: 'http://server_domain:8080',
                                        controller: urlPortController,
                                        readOnly: true,
                                        onTap: () => _navigateAndEdit(
                                            urlPortController, 'URL + PORT'),
                                      ),
                                      MyText(
                                        text: 'Password',
                                        size: 16.sp,
                                        color: Colors.white,
                                        weight: FontWeight.w500,
                                      ),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      MyTextField(
                                        hint: 'Password',
                                        controller: passwordController,
                                        readOnly: true,
                                        onTap: () => _navigateAndEdit(
                                            passwordController,
                                            'Enter Password'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Button at the bottom
          Container(
            color: kPrimColor,
            padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 1.h),
            child: ElevatedButton(
              onPressed: () {
                print("Add Playlist Button Pressed");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 8.w),
              ),
              child: Text(
                'Add Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

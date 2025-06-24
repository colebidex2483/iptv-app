import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/playlists/views/playlist_tabs.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';
import '../../../const/appColors.dart';
import '../../../widgets/my_button_widget.dart';
import '../../../widgets/side_pannel.dart';

class ChangePlaylist extends StatelessWidget {
  const ChangePlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kBtnColor, kPrimColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, top: 8.h),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/bglog.png',
                          width: 8.w,
                        ),
                        MyText(
                          text: 'Playlists',
                          color: Colors.white,
                          size: 18.sp,
                          weight: FontWeight.w800,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2.w, top: 2.h, right: 1.w),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        height: 70.h,
                        child: GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 3.h,
                            childAspectRatio: 2.2,
                          ),
                          itemCount: 6, // Number of demo containers
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                //_showPlaylistOptionsDialog(context);
                                Get.to(
                                  PlaylistTabs(),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 2.w,
                                  top: 2.w,
                                ),
                                decoration: BoxDecoration(
                                  color: kSecColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: 'Demo ${index + 1}',
                                      color: Colors.white,
                                      size: 18.sp,
                                      weight: FontWeight.w600,
                                    ),
                                    MyText(
                                      text: 'https://github.com/',
                                      color: Colors.yellow,
                                      size: 16.sp,
                                    ),
                                    SizedBox(
                                      height: 4.h,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: .3.w,
              height: double.infinity,
              color: Colors.white,
            ),
            Expanded(flex: 1, child: SidePannel())
          ],
        ),
      ),
    );
  }

  // Method to show the Playlist Options dialog with Connect, Edit, and Delete buttons
  void _showPlaylistOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          surfaceTintColor: Colors.white,
          title: MyText(
            text: 'Playlist Options',
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  text: 'What would you like to do with this playlist?',
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            BorderButton(
              width: 10 * 2.w,
              borderColor: kOrangeColor,
              textColor: Colors.white,
              buttonText: 'Connect',
              onTap: () {
                // Connect playlist logic
                Navigator.pop(context);
              },
            ),
            BorderButton(
              width: 10 * 2.w,
              borderColor: kOrangeColor,
              textColor: Colors.white,
              buttonText: 'Edit',
              onTap: () {
                // Edit playlist logic
                Navigator.pop(context);
              },
            ),
            BorderButton(
              width: 10 * 2.w,
              borderColor: kOrangeColor,
              textColor: Colors.white,
              buttonText: 'Delete',
              onTap: () {
                // Show confirmation dialog for deletion
                Navigator.pop(context); // Close the options dialog
                _showDeleteConfirmationDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show the Delete Confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          surfaceTintColor: Colors.white,
          title: MyText(
            text: 'Confirm Deletion',
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  text: 'Are you sure you want to delete this playlist?',
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            BorderButton(
              width: 10 * 2.w,
              borderColor: kOrangeColor,
              textColor: Colors.white,
              buttonText: 'Cancel',
              onTap: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
            ),
            MyButton(
              backgroundColor: kOrangeColor,
              width: 10 * 2.w,
              buttonText: 'Delete',
              onTap: () {
                // Delete playlist logic
                Navigator.pop(context); // Close the confirmation dialog
                // Add logic to delete the playlist here
              },
            ),
          ],
        );
      },
    );
  }
}

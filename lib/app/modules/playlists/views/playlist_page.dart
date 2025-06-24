import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/playlists/views/playlist_tabs.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';
import '../../../const/appColors.dart';
import '../../../widgets/my_button_widget.dart';
import '../../../widgets/side_pannel.dart';
import '../controllers/playlists_controller.dart';

class PlaylistsPage extends GetView<PlaylistsController> {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(10.h),
      //   child: Container(
      //     decoration: BoxDecoration(
      //       gradient: LinearGradient(
      //         colors: [kBtnColor, kPrimColor],
      //         begin: Alignment.topLeft,
      //         end: Alignment.bottomRight,
      //       ),
      //     ),
      //     child: AppBar(
      //       backgroundColor: Colors.transparent,
      //         leading: Padding(
      //           padding: const EdgeInsets.only(left: 20.0),
      //           child: CommonImageView(imagePath: 'assets/images/bglog.png'),
      //         ),
      //         title: MyText(
      //           text: 'Playlists',
      //           color: Colors.white,
      //         )),
      //   ),
      // ),
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
                      padding: EdgeInsets.only(left: 5.w),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // navigate
                                Get.toNamed('/demo-details');
                              },
                              child: Container(
                                height: 37.h,
                                width: 27.w,
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
                                      text: 'Demo',
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
                                    // ElevatedButton(
                                    //   onPressed: () {},
                                    //   style: ElevatedButton.styleFrom(
                                    //       backgroundColor: kPrimColor,
                                    //       padding: EdgeInsets.symmetric(
                                    //           horizontal: 3.w, vertical: 0)
                                    //       // shape: RoundedRectangleBorder(
                                    //       //   borderRadius: BorderRadius.circular(10),
                                    //       // ),
                                    //       ),
                                    //   child: MyText(
                                    //     text: 'Connected',
                                    //     color: Colors.white,
                                    //     weight: FontWeight.w600,
                                    //     size: 16.sp,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 3.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                //Get.toNamed('/demo-details');
                                Get.to(()=> PlaylistTabs());
                              },
                              child: Container(
                                height: 37.h,
                                width: 27.w,
                                decoration: BoxDecoration(
                                  color: kSecColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(1.w),
                                      decoration: BoxDecoration(
                                        color: kPrimColor,
                                        borderRadius:
                                            BorderRadius.circular(25.sp),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    MyText(
                                      text: 'Add Playlist',
                                      color: Colors.white,
                                      size: 17.sp,
                                      weight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
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
// Main content area
// Expanded(
//   flex: 2,
//   child: Padding(
//     padding: EdgeInsets.all(2.w),
//     child: Column(
//       children: [
//         // GridView containing playlists and add button
//         Expanded(
//           child: GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2, // Number of items per row
//               crossAxisSpacing: 2.w, // Horizontal spacing
//               mainAxisSpacing: 2.w, // Vertical spacing
//               childAspectRatio:
//               2.5, // Adjust aspect ratio for horizontal layout
//             ),
//             itemCount:
//             4, // 2 playlist items + 1 add button + 1 predefined item
//             itemBuilder: (context, index) {
//               if (index == 0) {
//                 // The first grid item is the predefined container
//                 return GestureDetector(
//                   onTap: () {
//                     // navigate
//                     Get.toNamed('/demo-details');
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     height: double.infinity,
//                     padding: EdgeInsets.all(2.w),
//                     decoration: BoxDecoration(
//                       color: Colors.white12,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.music_note, color: Colors.white),
//                         MyText(
//                           text: 'Demo',
//                           color: Colors.white,
//                         ),
//                         MyText(
//                           text: 'https://github.com/',
//                           color: kOrangeColor,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               } else if (index == 3) {
//                 // The last grid item is the "+" button with text
//                 return GestureDetector(
//                   onTap: () {
//                     showDialog(
//                       context: context,
//                       builder: (BuildContext context) {
//                         return AddPlaylistDialog();
//                       },
//                     );
//                   },
//                   child: Container(
//                     width: double.infinity,
//                     height: double.infinity,
//                     padding: EdgeInsets.all(2.w),
//                     decoration: BoxDecoration(
//                       color: Colors.white12,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add, color: Colors.white),
//                         SizedBox(height: 1.h),
//                         MyText(
//                           text: 'Add Playlist',
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               } else {
//                 // Other playlist grid items
//                 return GestureDetector(
//                   onTap: () {
//                     _showPlaylistOptionsDialog(context);
//                   },
//                   child: PlaylistsWidget(
//                     dynamicName: 'Dynamic Name $index',
//                     link: 'https://www.google.com/$index',
//                     onLinkTap: () {
//                       // Handle the link click
//                     },
//                   ),
//                 );
//               }
//             },
//           ),
//         ),
//         // Bottom text outside of GridView
//         Padding(
//           padding: EdgeInsets.all(2.w),
//           child: MyText(
//             text: 'This is the text at the bottom of the screen',
//             color: Colors.white,
//           ),
//         ),
//       ],
//     ),
//   ),
// ),
//
// // Side panel on the right
// SizedBox(
//   width: 200,
//   child: SidePannel(),
// ),

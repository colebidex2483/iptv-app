import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/playlists/controllers/playlists_controller.dart';
import 'package:ibo_clone/app/modules/playlists/views/playlist_tabs.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';
import '../../../const/appColors.dart';
import '../../../widgets/my_button_widget.dart';
import '../../../widgets/side_pannel.dart';

class ChangePlaylist extends StatelessWidget {
  ChangePlaylist({super.key});

  final PlaylistController playlistController = Get.put(PlaylistController());

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
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                        SizedBox(width: 3.w),
                        Image.asset(
                          'assets/images/bglog.png',
                          width: 8.w,
                        ),
                        MyText(
                          text: 'playlists'.tr,
                          color: Colors.white,
                          size: 18.sp,
                          weight: FontWeight.w800,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 2.w, top: 2.h, right: 1.w),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Obx(() {
                        if (playlistController.isLoading.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return SizedBox(
                          height: 70.h,
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 3.w,
                              mainAxisSpacing: 3.h,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: playlistController.playlists.length + 1,
                            itemBuilder: (context, index) {
                              if (index < playlistController.playlists.length) {
                                final playlist = playlistController.playlists[index];
                                return GestureDetector(
                                  onTap: () => _showPlaylistOptionsDialog(context, playlist),
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: playlist['isConnected'] == true ? Colors.green : kSecColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text: playlist['name'] ?? '',
                                          color: Colors.white,
                                          size: 16.sp,
                                          weight: FontWeight.w600,
                                        ),
                                        MyText(
                                          text: playlist['url'] ?? '',
                                          color: Colors.yellow,
                                          size: 12.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () async {
                                    final result = await Get.to(() => const PlaylistTabs());
                                    if (result == true) {
                                      playlistController.loadPlaylists();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      border: Border.all(color: Colors.white54),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.white, size: 30.sp),
                                        SizedBox(height: 1.h),
                                        MyText(
                                          text: 'add_playlist'.tr,
                                          color: Colors.white,
                                          size: 15.sp,
                                          weight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      }),
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
            Expanded(flex: 1, child: SidePannel()),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> playlist) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSecColor,
        title: MyText(
          text: 'delete_playlist_title'.tr,
          color: Colors.white,
          size: 18.sp,
          textAlign: TextAlign.center,
        ),
        content: MyText(
          text: 'delete_playlist_message'.trParams({'name': playlist['name'] ?? ''}),
          color: Colors.white70,
          size: 16.sp,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: MyText(
              text: 'cancel'.tr,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await playlistController.deletePlaylist(playlist['id']);
              Get.back();
            },
            child: MyText(
              text: 'delete'.tr,
              color: Colors.red,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptionsDialog(BuildContext context, Map<String, dynamic> playlist) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          surfaceTintColor: Colors.white,
          title: MyText(
            text: 'playlist_options'.tr,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  text: playlist['name'] ?? 'unnamed_playlist'.tr,
                  color: Colors.yellow,
                  size: 16.sp,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                MyText(
                  text: 'playlist_options_message'.tr,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            // Connect/Disconnect button - disabled if already connected
            if (!(playlist['isConnected'] == true))
              BorderButton(
                width: 20.w,
                borderColor: kOrangeColor,
                textColor: Colors.white,
                buttonText: 'connect'.tr,
                onTap: () async {
                  Get.back();
                  await playlistController.connectPlaylist(playlist['id']);
                  Get.snackbar(
                    'success'.tr,
                    'connected_success'.tr,
                    backgroundColor: Colors.green,
                  );
                },
              ),

            // Edit button - always enabled
            BorderButton(
              width: 20.w,
              borderColor: kOrangeColor,
              textColor: Colors.white,
              buttonText: 'edit'.tr,
              onTap: () {
                Get.back();
                Get.to(() => PlaylistTabs(playlist: playlist));
              },
            ),

            // Delete button - always enabled
            BorderButton(
              width: 20.w,
              borderColor: Colors.red,
              textColor: Colors.white,
              buttonText: 'delete'.tr,
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context, playlist);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditPlaylistDialog(BuildContext context, Map<String, dynamic> playlist) {
    final TextEditingController nameController = TextEditingController(text: playlist['name']);
    final TextEditingController urlController = TextEditingController(text: playlist['url']);

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
        title: MyText(text: 'edit_playlist'.tr, color: Colors.white),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'playlist_name'.tr, hintStyle: const TextStyle(color: Colors.white54)),
            ),
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'playlist_url'.tr, hintStyle: const TextStyle(color: Colors.white54)),
            ),
          ],
        ),
        actions: [
          MyButton(
            backgroundColor: kOrangeColor,
            buttonText: 'save'.tr,
            onTap: () async {
              await playlistController.updatePlaylist(playlist['id'], {
                'name': nameController.text.trim(),
                'url': urlController.text.trim(),
              });
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

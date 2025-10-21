import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/modules/playlists/views/playlist_tabs.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';
import '../../../const/appColors.dart';
import '../../../widgets/side_pannel.dart';
import '../controllers/playlists_controller.dart';

class PlaylistsPage extends GetView<PlaylistController> {
  const PlaylistsPage({super.key});

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
                        SizedBox(width: 2.w),
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
                    padding: EdgeInsets.only(left: 5.w, top: 4.h),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Obx(() {
                        return Wrap(
                          spacing: 3.w,
                          runSpacing: 3.w,
                          children: [
                            ...controller.playlists.map((playlist) => _PlaylistCard(
                              playlist: playlist,
                              onTap: () => _showPlaylistOptions(context, playlist),
                            ),
                            ),
                            _AddPlaylistCard(
                              onTap: () => Get.to(() => const PlaylistTabs()),
                            ),
                          ],
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: .3.w,
              height: double.infinity,
              color: Colors.white,
            ),
            const Expanded(flex: 1, child: SidePannel())
          ],
        ),
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, Map<String, dynamic> playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: kSecColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link, color: Colors.white),
              title: MyText(
                text: 'Connect',
                color: Colors.white,
                size: 16.sp,
              ),
              onTap: () {
                Navigator.pop(context);
                // Connect logic here
              },
            ),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: MyText(
                text: 'Edit',
                color: Colors.white,
                size: 16.sp,
              ),
              onTap: () {
                Navigator.pop(context);
                // Edit logic here
              },
            ),
            const Divider(color: Colors.white54),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: MyText(
                text: 'Delete',
                color: Colors.red,
                size: 16.sp,
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, playlist);
              },
            ),
            SizedBox(height: 2.h),
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
          text: 'Delete Playlist?',
          color: Colors.white,
          size: 18.sp,
          textAlign: TextAlign.center,
        ),
        content: MyText(
          text: 'Are you sure you want to delete "${playlist['name']}"?',
          color: Colors.white70,
          size: 16.sp,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: MyText(
              text: 'CANCEL',
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          TextButton(
            onPressed: () {
              // Delete logic here
              Navigator.pop(context);
            },
            child: MyText(
              text: 'DELETE',
              color: Colors.red,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final VoidCallback onTap;

  const _PlaylistCard({required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 27.w,
        height: 37.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: kSecColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: playlist['name'] ?? 'Unnamed Playlist',
              color: Colors.white,
              size: 18.sp,
              weight: FontWeight.w600,
            ),
            SizedBox(height: 1.h),
            MyText(
              text: playlist['url'] ?? playlist['baseUrl'] ?? '',
              color: Colors.yellow,
              size: 14.sp,
              maxLines: 2,
              // overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: MyText(
                text: 'CONNECTED',
                color: Colors.white,
                size: 14.sp,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlaylistCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPlaylistCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 27.w,
        height: 37.h,
        decoration: BoxDecoration(
          color: kSecColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: kPrimColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 3.h),
            MyText(
              text: 'Add Playlist',
              color: Colors.white,
              size: 17.sp,
              weight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
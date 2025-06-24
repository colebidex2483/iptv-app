import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/playlists/views/playlist_tabs.dart';
import 'package:ibo_clone/app/widgets/hide_live_categories.dart';
import 'package:ibo_clone/app/widgets/hide_series_categories.dart';
import 'package:ibo_clone/app/widgets/live_channel_sort.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:ibo_clone/app/widgets/select_language.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/add_playlist_dialog.dart';
import '../../../widgets/hide_vode_categorie.dart';
import '../../../widgets/layout.dart';
import '../../../widgets/parantal_control.dart';
import '../controllers/settings_controller.dart';
import '../../vpn/controllers/vpn_controller.dart';
final vpnController = Get.put(VPNController());
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': CupertinoIcons.square_list,
        'label': 'Add Playlist',
        'onTap': () => _showAddPlaylistDialog(context)
      },
      {
        'icon': Icons.vpn_lock,
        'label': 'VPN Connection',
        'onTap': () => _showVPNModal(context, vpnController),
      },
      {
        'icon': CupertinoIcons.lock,
        'label': 'Parental Control',
        'onTap': () => _showParentalControlDialog(context)
      },
      {
        'icon': CupertinoIcons.square_list,
        'label': 'Change Playlist',
        'onTap': () => Get.toNamed('/playlists')
      },
      {
        'icon': Icons.language_sharp,
        'label': 'Change Language',
        'onTap': () => _showChangeLanguageDialog(context)
      },
      {
        'icon': Icons.grid_view,
        'label': 'Change Layout',
        'onTap': () => _showLayoutDialog(context)
      },
      {
        'icon': CupertinoIcons.eye_slash_fill,
        'label': 'Hide Live Categories',
        'onTap': () => _showHideCategoriesDialog(context, 'Live Categories')
      },
      {
        'icon': CupertinoIcons.eye_slash_fill,
        'label': 'Hide Vod Categories',
        'onTap': () => _showVodCategoriesDialog(context, 'VOD Categories')
      },
      {
        'icon': CupertinoIcons.eye_slash_fill,
        'label': 'Hide Series Categories',
        'onTap': () => _showSeriesCategoriesDialog(context, 'Series Categories')
      },
      {
        'icon': CupertinoIcons.trash_fill,
        'label': 'Clear History Channel',
        'onTap': () =>
            Get.snackbar('Clear History', 'Channels history cleared!'),
      },
      {
        'icon': CupertinoIcons.trash_fill,
        'label': 'Clear History Movies',
        'onTap': () => Get.snackbar('Clear History', 'Movies history cleared!'),
      },
      {
        'icon': CupertinoIcons.trash_fill,
        'label': 'Clear History Series',
        'onTap': () => Get.snackbar('Clear History', 'Series history cleared!'),
      },
      {
        'icon': Icons.sort_by_alpha,
        'label': 'Live Channel Sort',
        'onTap': () => _showLiveChannelSortDialog(context)
      },
      {
        'icon': Icons.connected_tv_sharp,
        'label': 'Live Stream Format',
        'onTap': () {},
      },
      {
        'icon': Icons.change_circle_outlined,
        'label': 'Change Player',
        'onTap': () =>
            Get.snackbar('Automatic', 'Settings updated automatically!')
      },
      {
        'icon': Icons.play_circle_outline,
        'label': 'External Players',
        'onTap': () =>
            Get.snackbar('Automatic', 'Settings updated automatically!')
      },
      {
        'icon': Icons.settings_backup_restore,
        'label': 'Automatic',
        'onTap': () =>
            Get.snackbar('Automatic', 'Settings updated automatically!')
      },
      {
        'icon': Icons.access_time,
        'label': 'Time Format',
        'onTap': () => Get.snackbar('Time Format', 'Updated to 24-hour format!')
      },
      {
        'icon': Icons.subtitles,
        'label': 'Subtitle Settings',
        'onTap': () => Get.toNamed('/subtitleSettings')
      },
      {
        'icon': Icons.important_devices_sharp,
        'label': 'Select Device Type',
        'onTap': () => Get.toNamed('/selectDeviceType')
      },
      {
        'icon': Icons.browser_updated_rounded,
        'label': 'Update Now',
        'onTap': () => Get.snackbar('Update', 'Application is up to date!')
      },
    ];
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Row(
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
                        text: 'Settings',
                        weight: FontWeight.w600,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 0.5.h,
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Four columns
                  crossAxisSpacing: 1.w,
                  mainAxisSpacing: 1.h,
                  childAspectRatio: .97.h, // Adjust for grid proportions
                ),
                itemCount: settingsOptions.length,
                itemBuilder: (context, index) {
                  final option = settingsOptions[index];
                  return _buildSettingsOption(
                    icon: option['icon'],
                    label: option['label'],
                    onTap: option['onTap'],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: .2.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                      text: 'Mac Address: 11:f4:ef:08:6f:ba',
                      color: Colors.white,
                      size: 14.sp),
                  MyText(
                    text: 'Device Key: 278281',
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: kPrimColor,
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSecColor,
          borderRadius: BorderRadius.circular(2),
          //border: Border.all(color: Colors.white, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 1.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 18.sp),
              SizedBox(width: 1.h),
              MyText(
                text: label,
                textAlign: TextAlign.center,
                color: Colors.white,
                size: 15.sp,
                weight: FontWeight.w700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPlaylistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PlaylistTabs(),
    );
  }
  void _showVPNModal(BuildContext context, VPNController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSecColor,
        title: Row(
          children: [
            Icon(Icons.vpn_lock, color: Colors.white),
            SizedBox(width: 10),
            Text("VPN Settings", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Obx(() {
          final isConnected = controller.vpnState.value == 'connected';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isConnected ? "VPN is currently connected." : "VPN is not connected.",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.toggleVPN,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? Colors.red : Colors.green,
                ),
                child: Text(isConnected ? "Disconnect VPN" : "Connect VPN"),
              ),
            ],
          );
        }),
      ),
    );
  }
  void _showParentalControlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ParentalControl(),
    );
  }

  void _showChangeLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SelectLanguage(),
    );
  }

  void _showLayoutDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => Selectlayout());
  }

  void _showHideCategoriesDialog(BuildContext context, String categoryType) {
    showDialog(
      context: context,
      builder: (context) => HideLiveCategories(),
    );
  }

  void _showVodCategoriesDialog(BuildContext context, String categoryType) {
    showDialog(
      context: context,
      builder: (context) => HideVodeCategories(),
    );
  }

  void _showSeriesCategoriesDialog(BuildContext context, String categoryType) {
    showDialog(
      context: context,
      builder: (context) => HideSeriesCategories(),
    );
  }

  void _showLiveChannelSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LiveChannelSort(),
    );
  }
}

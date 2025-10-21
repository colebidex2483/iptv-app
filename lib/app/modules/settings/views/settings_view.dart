import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/on_boarding/controllers/onboarding_controller.dart';
import 'package:ibo_clone/app/modules/playlists/views/playlist_tabs.dart';
import 'package:ibo_clone/app/widgets/hide_live_categories.dart';
import 'package:ibo_clone/app/widgets/hide_series_categories.dart';
import 'package:ibo_clone/app/widgets/live_channel_sort.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:ibo_clone/app/widgets/select_language.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/hide_vode_categorie.dart';
import '../../../widgets/layout.dart';
import '../../../widgets/parantal_control.dart';
import '../controllers/settings_controller.dart';
import '../../vpn/controllers/vpn_controller.dart';
import '../../../core/hive_service.dart';
import '../../playlists/controllers/playlists_controller.dart'; // <-- added

final vpnController = Get.put(VPNController());

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingController = Get.find<OnboardingController>();
    final playlistController = Get.find<PlaylistController>(); // <-- for in-memory updates

    final List<Map<String, dynamic>> settingsOptions = [
      {
        'icon': CupertinoIcons.square_list,
        'label': 'add_playlist'.tr,
        'onTap': () => _showAddPlaylistDialog(context)
      },
      {
        'icon': Icons.vpn_lock,
        'label': 'vpn_connection'.tr,
        'onTap': () => _showVPNModal(context, vpnController),
      },
      {
        'icon': CupertinoIcons.lock,
        'label': 'parental_control'.tr,
        'onTap': () => _showParentalControlDialog(context)
      },
      {
        'icon': CupertinoIcons.square_list,
        'label': 'change_playlist'.tr,
        'onTap': () => Get.toNamed('/playlists')
      },
      {
        'icon': Icons.language_sharp,
        'label': 'change_language'.tr,
        'onTap': () => _showChangeLanguageDialog(context)
      },
      {
        'icon': Icons.grid_view,
        'label': 'change_layout'.tr,
        'onTap': () => _showLayoutDialog(context)
      },
      {
        'icon': CupertinoIcons.eye_slash_fill,
        'label': 'hide_live_categories'.tr,
        'onTap': () => _showHideCategoriesDialog(context, 'Live Categories')
      },
      {
        'icon': CupertinoIcons.eye_slash_fill,
        'label': 'hide_vod_categories'.tr,
        'onTap': () => _showVodCategoriesDialog(context, 'VOD Categories')
      },
      {
        'icon': CupertinoIcons.eye_slash_fill,
        'label': 'hide_series_categories'.tr,
        'onTap': () => _showSeriesCategoriesDialog(context, 'Series Categories')
      },
      {
        'icon': CupertinoIcons.trash_fill,
        'label': 'clear_history_channel'.tr,
        'onTap': () => Get.snackbar('clear_history'.tr, 'channels_history_cleared'.tr),
      },
      // ---------- Movies history: replaced placeholder with real implementation ----------
      {
        'icon': CupertinoIcons.trash_fill,
        'label': 'clear_history_movies'.tr,
        'onTap': () => _confirmClearMovieHistory(context),
      },
      {
        'icon': CupertinoIcons.trash_fill,
        'label': 'clear_history_series'.tr,
        'onTap': () => Get.snackbar('clear_history'.tr, 'series_history_cleared'.tr),
      },
      {
        'icon': Icons.sort_by_alpha,
        'label': 'live_channel_sort'.tr,
        'onTap': () => _showLiveChannelSortDialog(context)
      },
      {
        'icon': Icons.connected_tv_sharp,
        'label': 'live_stream_format'.tr,
        'onTap': () {},
      },
      {
        'icon': Icons.change_circle_outlined,
        'label': 'change_player'.tr,
        'onTap': () => Get.snackbar('automatic'.tr, 'settings_updated'.tr)
      },
      {
        'icon': Icons.play_circle_outline,
        'label': 'external_players'.tr,
        'onTap': () => Get.snackbar('automatic'.tr, 'settings_updated'.tr)
      },
      {
        'icon': Icons.settings_backup_restore,
        'label': 'automatic'.tr,
        'onTap': () => Get.snackbar('automatic'.tr, 'settings_updated'.tr)
      },
      {
        'icon': Icons.access_time,
        'label': 'time_format'.tr,
        'onTap': () => Get.snackbar('time_format'.tr, 'updated_24hr'.tr)
      },
      {
        'icon': Icons.subtitles,
        'label': 'subtitle_settings'.tr,
        'onTap': () => Get.toNamed('/subtitleSettings')
      },
      {
        'icon': Icons.important_devices_sharp,
        'label': 'select_device_type'.tr,
        'onTap': () => Get.toNamed('/selectDeviceType')
      },
      {
        'icon': Icons.browser_updated_rounded,
        'label': 'update_now'.tr,
        'onTap': () => Get.snackbar('update'.tr, 'app_up_to_date'.tr)
      },
    ];

    return Scaffold(
      backgroundColor: kPrimColor,
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
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Center(
                      child: MyText(
                        text: 'settings'.tr,
                        weight: FontWeight.w600,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.5.h),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 1.w,
                  mainAxisSpacing: 1.h,
                  childAspectRatio: .97.h,
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
            Obx(() {
              final deviceId = onboardingController.deviceId.value;
              final deviceKey = onboardingController.deviceKey.value;

              return Padding(
                padding: EdgeInsets.only(top: 0.2.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText(
                      text: '${'mac_address'.tr}: $deviceId',
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    MyText(
                      text: '${'device_key'.tr}: $deviceKey',
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({required IconData icon, required String label, required VoidCallback onTap,}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSecColor,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 1.w, right: 1.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18.sp),
              SizedBox(width: 1.h),
              Expanded(
                child: MyText(
                  text: label, // already localized with .tr
                  textAlign: TextAlign.start,
                  color: Colors.white,
                  size: 15.sp,
                  weight: FontWeight.w700,
                  overflow: TextOverflow.ellipsis, // ✅ prevents overflow
                  maxLines: 1, // ✅ keeps it single-line
                ),
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
            const Icon(Icons.vpn_lock, color: Colors.white),
            const SizedBox(width: 10),
            Text("vpn_settings".tr, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Obx(() {
          final isConnected = controller.vpnState.value == 'connected';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isConnected ? "vpn_connected".tr : "vpn_not_connected".tr,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.toggleVPN,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isConnected ? Colors.red : Colors.green,
                ),
                child: Text(
                  isConnected ? "disconnect_vpn".tr : "connect_vpn".tr,
                ),
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
    showDialog(
      context: context,
      builder: (context) => Selectlayout(),
    );
  }

  // ---------------------- NEW: Confirm + Clear Movie History ----------------------
  Future<void> _confirmClearMovieHistory(BuildContext context) async {
    final playlistController = Get.find<PlaylistController>();
    final playlistId = HiveService.getConnectedPlaylistId();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: kSecColor,
          title: Row(
            children: [
              Icon(CupertinoIcons.trash, color: Colors.white),
              const SizedBox(width: 10),
              Text('confirm'.tr, style: const TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'clear_history_movies_confirmation'.trArgs([
              // a short human readable description we expect in translations
              'This will remove cached movies (if any), movie favorites and resume points.'
            ]),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('cancel'.tr, style: const TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text('confirm'.tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // show a simple loading dialog while the operation runs
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Clear persisted movie history (scoped to current playlist if available)
      await HiveService.clearMovieHistory(playlistId: playlistId);

      // Update in-memory state so UI immediately reflects the change
      playlistController.movies.clear();
      playlistController.resumeMovies.clear();
      playlistController.favoriteMovieIds.clear();

      // persist cleared favorites in controller as well
      await HiveService.saveFavoriteMovies([]);

      // close the loading dialog
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();

      // show success
      Get.snackbar('clear_history'.tr, 'movies_history_cleared'.tr,
          backgroundColor: Colors.green);
    } catch (e) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      Get.snackbar('Error', 'Failed to clear movie history: ${e.toString()}',
          backgroundColor: Colors.red);
    }
  }
  // -------------------------------------------------------------------------------

  void _showHideCategoriesDialog(BuildContext context, String categoryType) async {
    final playlistId = HiveService.getConnectedPlaylistId();
    if (playlistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active playlist found')),
      );
      return;
    }

    // Determine the key for this type
    final key = categoryType.toLowerCase().contains('vod')
        ? 'vod'
        : categoryType.toLowerCase().contains('series')
        ? 'series'
        : 'live';

    // Try to fetch pre-cached categories (Xtream playlists)
    final cached = HiveService.getCachedCategories(playlistId);
    // print(cached);
    List<String> availableCategories = [];

    if (cached != null && cached[key] != null) {
      // ✅ Xtream playlists already have structured categories
      final rawList = cached[key] ?? [];
      availableCategories = rawList.map<String>((entry) {
        final map = Map<String, dynamic>.from(entry);
        return (map['category_name'] ??
            map['name'] ??
            map['category'] ??
            map['group-title'] ??
            '')
            .toString();
      }).where((s) => s.isNotEmpty).toList();
    } else {
      // ✅ M3U playlists: derive categories from items in Hive
      final cachedItems = HiveService.getCachedItems(playlistId, key);
      if (cachedItems != null) {
        final categorySet = <String>{};
        for (final item in cachedItems) {
          final map = Map<String, dynamic>.from(item);
          final cat = (map['group-title'] ?? map['category'] ?? '').toString();
          if (cat.isNotEmpty) categorySet.add(cat);
        }
        availableCategories = categorySet.toList()..sort();
      }
    }

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $categoryType found')),
      );
      return;
    }

    // ✅ Show the dialog
    showDialog(
      context: context,
      builder: (_) => HideLiveCategories(
        allCategories: availableCategories,
        onSaved: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hidden $categoryType updated')),
          );
        },
      ),
    );
  }

  void _showVodCategoriesDialog(BuildContext context, String categoryType) async {
    final playlistId = HiveService.getConnectedPlaylistId();
    if (playlistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active playlist found')),
      );
      return;
    }

    // Load cached categories for VOD
    final cached = HiveService.getCachedCategories(playlistId);
    List<String> availableCategories = [];

    if (cached != null && cached['vod'] is List) {
      final rawList = cached['vod'] as List;
      availableCategories = rawList
          .whereType<Map>()
          .map((map) => (map['category_name'] ??
          map['name'] ??
          map['category'] ??
          map['group-title'] ??
          '')
          .toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    } else {
      // Handle M3U playlists
      final cachedItems = HiveService.getCachedItems(playlistId, 'vod');
      if (cachedItems != null) {
        final categorySet = <String>{};
        for (final item in cachedItems) {
          final map = Map<String, dynamic>.from(item);
          final cat = (map['group-title'] ?? map['category'] ?? '').toString();
          if (cat.isNotEmpty) categorySet.add(cat);
        }
        availableCategories = categorySet.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
    }

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $categoryType found')),
      );
      return;
    }

    // ✅ Show the HideVodeCategories dialog
    showDialog(
      context: context,
      builder: (_) => HideVodeCategories(
        allCategories: availableCategories,
        onSaved: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hidden $categoryType updated')),
          );
        },
      ),
    );
  }

  void _showSeriesCategoriesDialog(BuildContext context, String categoryType) async {
    final playlistId = HiveService.getConnectedPlaylistId();
    if (playlistId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active playlist found')),
      );
      return;
    }

    // Load cached categories for SERIES
    final cached = HiveService.getCachedCategories(playlistId);
    List<String> availableCategories = [];

    if (cached != null && cached['series'] is List) {
      final rawList = cached['series'] as List;
      availableCategories = rawList
          .whereType<Map>()
          .map((map) => (map['category_name'] ??
          map['name'] ??
          map['category'] ??
          map['group-title'] ??
          '')
          .toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    } else {
      // Handle M3U playlists
      final cachedItems = HiveService.getCachedItems(playlistId, 'series');
      if (cachedItems != null) {
        final categorySet = <String>{};
        for (final item in cachedItems) {
          final map = Map<String, dynamic>.from(item);
          final cat = (map['group-title'] ?? map['category'] ?? '').toString();
          if (cat.isNotEmpty) categorySet.add(cat);
        }
        availableCategories = categorySet.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      }
    }

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $categoryType found')),
      );
      return;
    }

    // ✅ Show the HideSeriesCategories dialog
    showDialog(
      context: context,
      builder: (_) => HideSeriesCategories(
        allCategories: availableCategories,
        onSaved: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hidden $categoryType updated')),
          );
        },
      ),
    );
  }


  void _showLiveChannelSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LiveChannelSort(),
    );
  }
}

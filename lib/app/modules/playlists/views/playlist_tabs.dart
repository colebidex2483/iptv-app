import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/playlists/views/add_playlist_full_text_page.dart';
import 'package:ibo_clone/app/widgets/custom_playlist_tab.dart';
import 'package:ibo_clone/app/widgets/my_text_field_widget.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:ibo_clone/app/modules/playlists/controllers/playlists_controller.dart';
// import '../../../widgets/loading_dialog.dart';
import 'package:ibo_clone/app/modules/on_boarding/controllers/onboarding_controller.dart';

class PlaylistTabs extends StatefulWidget {
  final Map<String, dynamic>? playlist;

  const PlaylistTabs({super.key, this.playlist});

  @override
  State<PlaylistTabs> createState() => _PlaylistTabsState();
}

class _PlaylistTabsState extends State<PlaylistTabs> with SingleTickerProviderStateMixin {
  final TextEditingController playlistNameOneController = TextEditingController();
  final TextEditingController playlistNameTwoController = TextEditingController();
  final TextEditingController m3uController = TextEditingController();
  final TextEditingController urlPortController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late TabController _tabController;
  final PlaylistController playlistController = Get.put(PlaylistController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.playlist != null) {
      playlistNameOneController.text = widget.playlist!['name'] ?? '';
      playlistNameTwoController.text = widget.playlist!['name'] ?? '';
      m3uController.text = widget.playlist!['url'] ?? '';
      urlPortController.text = widget.playlist!['url'] ?? '';
      usernameController.text = widget.playlist!['username'] ?? '';
      passwordController.text = widget.playlist!['password'] ?? '';
    }
  }

  Future<void> _navigateAndEdit(TextEditingController controller, String hintText) async {
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
    _tabController.dispose();
    playlistNameOneController.dispose();
    playlistNameTwoController.dispose();
    m3uController.dispose();
    urlPortController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
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
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Center(
                  child: MyText(
                    text: widget.playlist != null ? 'Edit Playlist' : 'Add Playlist',
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
                onTap: () => setState(() => _tabController.index = 0),
              ),
              SizedBox(width: 10),
              CustomTab(
                title: 'XTREAM-CODES-API',
                isSelected: _tabController.index == 1,
                onTap: () => setState(() => _tabController.index = 1),
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
                  _buildM3UTab(),
                  _buildXtreamTab(),
                ],
              ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildM3UTab() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
          color: kSecColor,
          child: Column(
            children: [
              _buildMacRow(),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(child: _buildFieldColumn('Playlist Name', playlistNameOneController, 'Playlist Name')),
                  SizedBox(width: 4.w),
                  Expanded(child: _buildFieldColumn('Enter M3U', m3uController, 'Add M3U')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildXtreamTab() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
          color: kSecColor,
          child: Column(
            children: [
              _buildMacRow(),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildFieldColumn('Playlist Name', playlistNameTwoController, 'Playlist Name'),
                        SizedBox(height: 2.h),
                        _buildFieldColumn('Username', usernameController, 'Username'),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      children: [
                        _buildFieldColumn('URL + PORT', urlPortController, 'URL + PORT'),
                        SizedBox(height: 2.h),
                        _buildFieldColumn('Password', passwordController, 'Enter Password'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldColumn(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(text: label, size: 16.sp, color: Colors.white, weight: FontWeight.w500),
        SizedBox(height: 1.h),
        MyTextField(
          hint: hint,
          controller: controller,
          readOnly: true,
          onTap: () => _navigateAndEdit(controller, hint),
        ),
      ],
    );
  }

  Widget _buildMacRow() {
    final onboardingController = Get.find<OnboardingController>();
    final deviceId = onboardingController.deviceId.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.person_alt_circle, color: Colors.white),
            SizedBox(width: 2.w),
            MyText(text: 'Mac Address', size: 17.sp, color: Colors.white, weight: FontWeight.w700),
          ],
        ),
        MyText(text: deviceId, size: 17.sp, color: Colors.white, weight: FontWeight.w700),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      color: kPrimColor,
      padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 1.h),
      child: ElevatedButton(
        onPressed: () async {
          try {
            if (widget.playlist != null) {
              await playlistController.updatePlaylist(widget.playlist!['id'], {
                'name': _tabController.index == 0
                    ? playlistNameOneController.text.trim()
                    : playlistNameTwoController.text.trim(),
                'url': _tabController.index == 0
                    ? m3uController.text.trim()
                    : urlPortController.text.trim(),
                'username': usernameController.text.trim(),
                'password': passwordController.text.trim(),
              });
              if (Get.isDialogOpen!) Get.back();
              await Future.delayed(const Duration(milliseconds: 200));
              Get.back(result: true);
              Get.snackbar('Success', 'Playlist updated successfully', backgroundColor: Colors.green);
            } else {
              if (_tabController.index == 0) {
                try {
                  final count = await playlistController.addM3UPlaylist(
                    playlistNameOneController.text.trim(),
                    m3uController.text.trim(),
                  );
                  if (Get.isDialogOpen!) Get.back();
                  await Future.delayed(const Duration(milliseconds: 200));
                  Get.back(result: true);
                  Get.snackbar('Success', 'Playlist added with $count channels', backgroundColor: Colors.green);
                } catch (e) {
                  if (Get.isDialogOpen!) Get.back();
                  Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
                }
              } else {
                try {
                  await playlistController.addXtreamPlaylist(
                    playlistNameTwoController.text.trim(),
                    urlPortController.text.trim(),
                    usernameController.text.trim(),
                    passwordController.text.trim(),
                  );
                  if (Get.isDialogOpen!) Get.back();
                  await Future.delayed(const Duration(milliseconds: 200));
                  Get.back(result: true);
                  Get.snackbar('Success', 'Xtream Playlist added successfully', backgroundColor: Colors.green);
                } catch (e) {
                  if (Get.isDialogOpen!) Get.back();
                  Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
                }
              }
            }
          } catch (e) {
            if (Get.isDialogOpen!) Get.back();
            Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kSecColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 8.w),
        ),
        child: Text(
          widget.playlist != null ? 'Save Changes' : 'Add Playlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ),
    );
  }
}

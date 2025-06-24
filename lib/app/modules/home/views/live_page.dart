import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/widgets/row_widget.dart';
import 'package:sizer/sizer.dart';

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isInitialized = false;
  int _selectedLanguageIndex = -1; // Track selected language index
  final List<Map<String, dynamic>> languages = [
    {'text': 'Arabic', 'icon': Icons.live_tv_sharp, 'counter': 1},
    {'text': 'English', 'icon': Icons.live_tv_sharp, 'counter': 1},
    {'text': 'French', 'icon': Icons.live_tv_sharp, 'counter': 1},
    {'text': 'German', 'icon': Icons.live_tv_sharp, 'counter': 1},
    {'text': 'Portuguese', 'icon': Icons.live_tv_sharp, 'counter': 1},
    {'text': 'Spanish', 'icon': Icons.live_tv_sharp, 'counter': 1},
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
      ),
    );

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: false,
      );
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing video player: $e');
    }
  }

  Future<void> _restartVideo() async {
    await _videoPlayerController.seekTo(Duration.zero);
    _videoPlayerController.play();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimColor,
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            margin: EdgeInsets.only(left: 7),
            child: Column(
              children: [
                Container(
                  height: 9.h,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      Text(
                        'Add Group',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                RowWidget(
                  text1: 'Recently Viewed',
                  text2: '1',
                  isSelected: true,
                ),
                SizedBox(
                  height: 1.h,
                ),
                RowWidget(text1: 'All', text2: '1', isSelected: true),
                SizedBox(
                  height: 1.h,
                ),
                RowWidget(text1: 'Favourite', text2: '1', isSelected: true),
                SizedBox(
                  height: 1.h,
                ),
                RowWidget(text1: 'Lock', text2: '1', isSelected: true),
                SizedBox(
                  height: 1.h,
                ),
                RowWidget(text1: 'Demo Ibo', text2: '1', isSelected: true),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context)
                .size
                .height, // Set the height of the divider
            child: VerticalDivider(
              color: Colors.white,
              width: 10,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero, // Remove default padding
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLanguageIndex = index;
                                _restartVideo(); // Restart the video when a language is clicked
                              });
                              print('${language['text']} clicked');
                            },
                            child: LanguageRowWidget(
                              text1: language['text'],
                              icon: language['icon'],
                              counter: index + 1,
                              isSelected: _selectedLanguageIndex == index,
                            ),
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context)
                .size
                .height, // Set the height of the divider
            child: VerticalDivider(
              color: Colors.white,
              width: 10,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 17.5.h),
              color: Colors.black,
              child: _isInitialized
                  ? Chewie(controller: _chewieController)
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageRowWidget extends StatelessWidget {
  const LanguageRowWidget({
    required this.text1,
    required this.icon,
    required this.counter,
    required this.isSelected,
    super.key,
  });

  final String text1;
  final IconData icon;
  final int counter; // Counter up to 6
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 9.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Text(
              counter.toString(),
              style: TextStyle(
                fontSize: 16.sp,
                color: isSelected ? Colors.yellow : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.yellow : Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                text1,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isSelected ? Colors.yellow : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

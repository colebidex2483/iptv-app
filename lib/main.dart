import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for SystemChrome
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/home/views/home_tabs.dart';
import 'package:ibo_clone/app/modules/settings/views/settings_view.dart';
import 'package:ibo_clone/app/widgets/my_text_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restrict to landscape mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    Sizer(
      builder: (context, orientation, deviceType) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        //home: VideoPlayerScreen(),
      ),
    ),
  );
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    //_initializeVideoPlayer();
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

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Screen')),
      body: GestureDetector(
        onTap: () {
          if (_isInitialized) {
            Get.to(FullScreenVideoPlayer(
              videoPlayerController: _videoPlayerController,
              chewieController: _chewieController,
            ));
          }
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: _isInitialized
              ? Chewie(controller: _chewieController)
              : Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final ChewieController chewieController;

  const FullScreenVideoPlayer({super.key, 
    required this.videoPlayerController,
    required this.chewieController,
  });

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  double _volume = 0.5;
  double _brightness = 0.5;

  @override
  void initState() {
    super.initState();
    _volume = widget.videoPlayerController.value.volume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Chewie(controller: widget.chewieController),
          Positioned(
            left: 2.w,
            top: 8.h,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height / 2 - 50,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _brightness = (_brightness - details.primaryDelta! / 500)
                      .clamp(0.0, 1.0);
                });
              },
              child: Icon(Icons.brightness_4, color: Colors.white),
            ),
          ),
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 50,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _volume =
                      (_volume - details.primaryDelta! / 1000).clamp(0.0, 1.0);
                  widget.videoPlayerController.setVolume(_volume);
                });
              },
              child: Icon(Icons.volume_up, color: Colors.white),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 75,
            bottom: MediaQuery.of(context).size.height / 2,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous, color: Colors.white),
                  onPressed: () {
                    widget.videoPlayerController.seekTo(Duration(seconds: 0));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.pause, color: Colors.white),
                  onPressed: () {
                    widget.videoPlayerController.pause();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.skip_next, color: Colors.white),
                  onPressed: () {
                    widget.videoPlayerController.seekTo(Duration(seconds: 10));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class FullScreenTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//
//   FullScreenTextField({required this.controller, required this.hintText});
//
//   @override
//   Widget build(BuildContext context) {
//     final tempController = TextEditingController(text: controller.text);
//
//     return Scaffold(
//       backgroundColor: kPrimColor,
//       body: Padding(
//         padding: EdgeInsets.only(top: 8.h, left: 2.w, right: 2.w),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: tempController,
//                 autofocus: true,
//                 maxLines: 6,
//                 decoration: InputDecoration(
//                   hintText: hintText,
//                   hintStyle: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//             SizedBox(width: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, tempController.text);
//               },
//               style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 3.w,
//                   ),
//                   textStyle: TextStyle(fontSize: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                   backgroundColor: kSecColor),
//               child: MyText(
//                 text: 'Done',
//                 size: 16.sp,
//                 weight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   final TextEditingController _controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Main Screen'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               readOnly: true,
//               onTap: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FullScreenTextField(
//                       controller: _controller,
//                       hintText: 'Enter your text here',
//                     ),
//                   ),
//                 );
//
//                 if (result != null) {
//                   setState(() {
//                     _controller.text = result;
//                   });
//                 }
//               },
//               decoration: InputDecoration(
//                 hintText: 'Tap to enter text',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

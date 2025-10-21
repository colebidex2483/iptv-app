import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';

import '../../../core/hive_service.dart';
import '../../playlists/controllers/playlists_controller.dart';

class WatchPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final Map<String, dynamic>? movieData;
  final List<Map<String, dynamic>> movies;
  final int currentIndex;
  final Duration? startPosition;

  const WatchPage({
    super.key,
    required this.videoUrl,
    required this.title,
    this.movieData,
    required this.movies,
    required this.currentIndex,
    this.startPosition,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";

  final PlaylistController playlistController = Get.find<PlaylistController>();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WakelockPlus.enable();
    _initializePlayer(widget.videoUrl);
  }

  Future<void> _initializePlayer(String url) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      _videoPlayerController?.dispose();
      _chewieController?.dispose();

      _videoPlayerController = VideoPlayerController.network(url);
      await _videoPlayerController!.initialize();

      if (widget.startPosition != null) {
        await _videoPlayerController!.seekTo(widget.startPosition!);
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowMuting: true,
        allowFullScreen: true,
        showControls: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _saveProgress() async {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      final pos = _videoPlayerController!.value.position;
      final dur = _videoPlayerController!.value.duration;

      if (dur.inSeconds > 30 && pos.inSeconds < dur.inSeconds - 10) {
        final id = widget.movieData?['id'] ?? widget.title;

        await HiveService.saveResumePoint(
          id: id.toString(),
          position: pos.inSeconds,
          duration: dur.inSeconds,
          isSeries: widget.movieData?['isSeries'] == true,
          episodeId: widget.movieData?['episodeId'],
        );

        await playlistController.loadResumeMovies();
      } else {
        final id = widget.movieData?['id'] ?? widget.title;
        await HiveService.deleteResumePoint(id.toString());
        await playlistController.loadResumeMovies();
      }
    }
  }

  @override
  void dispose() {
    _saveProgress();
    WakelockPlus.disable();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _hasError
                ? Text(
              "❌ Error: $_errorMessage",
              style: const TextStyle(color: Colors.red),
            )
                : _chewieController != null
                ? Chewie(controller: _chewieController!)
                : const Text("No video",
                style: TextStyle(color: Colors.white)),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () async {
                  await _saveProgress();
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

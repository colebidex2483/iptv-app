import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../widgets/my_text_widget.dart';
import 'package:ibo_clone/app/modules/playlists/controllers/playlists_controller.dart';
import 'package:ibo_clone/app/modules/watch/views/watch_page.dart';

class SeasonPage extends StatelessWidget {
  final Map<String, dynamic> series;
  SeasonPage({super.key, required this.series});

  final PlaylistController playlistController = Get.find();

  @override
  Widget build(BuildContext context) {
    final episodesData = series['episodes'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          series['name'] ?? "Seasons",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.5.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.black.withOpacity(0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSeasons(episodesData),
        ),
      ),
    );
  }

  List<Widget> _buildSeasons(dynamic episodesData) {
    print(episodesData);
    if (episodesData == null) {
      return const [
        Center(
          child: Text("No seasons available",
              style: TextStyle(color: Colors.white70)),
        ),
      ];
    }

    final episodesMap = episodesData is Map
        ? Map<String, dynamic>.from(episodesData)
        : <String, dynamic>{};

    if (episodesMap.isEmpty) {
      return const [
        Center(
          child: Text("No seasons available",
              style: TextStyle(color: Colors.white70)),
        ),
      ];
    }

    return episodesMap.entries.map((entry) {
      final seasonNumber = entry.key;
      final episodes = entry.value is List ? entry.value as List<dynamic> : [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 2.h,
                  decoration: BoxDecoration(
                    color: Colors.redAccent, // brand/accent color
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  "Season $seasonNumber",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 38.h,
            child: Stack(
              children: [
                ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: episodes.length,
                  separatorBuilder: (_, __) => SizedBox(width: 3.w),
                  itemBuilder: (context, i) {
                    final ep = episodes[i];
                    final episodeData =
                    ep is Map ? Map<String, dynamic>.from(ep) : {};

                    final title = episodeData['title'] ??
                        episodeData['name'] ??
                        "Episode";

                    final duration = episodeData['info'] is Map
                        ? (episodeData['info'] as Map)['duration']
                        : episodeData['duration'];

                    final episodeId = episodeData['id']?.toString() ??
                        episodeData['episode_id']?.toString();

                    final episodeExtension = episodeData['extension']?.toString() ??
                        episodeData['container_extension']?.toString();

                    final thumb = episodeData['info'] is Map
                        ? (episodeData['info']['movie_image'] ??
                        episodeData['info']['cover'] ??
                        '')
                        .toString()
                        : '';

                    return GestureDetector(
                      onTap: () {
                        if (episodeId == null) return;

                        final playlist = playlistController.currentPlaylist;
                        if (playlist == null) return;

                        var baseUrl = (playlist['baseUrl'] ?? '').toString();
                        if (baseUrl.endsWith('/')) {
                          baseUrl = baseUrl.substring(0, baseUrl.length - 1);
                        }

                        final videoUrl =
                            "$baseUrl/series/${playlist['username']}/${playlist['password']}/$episodeId.$episodeExtension";

                        final episodesList =
                        episodes.map<Map<String, dynamic>>((ep) {
                          return ep is Map ? Map<String, dynamic>.from(ep) : {};
                        }).toList();

                        final currentEpisodeIndex = i;

                        Get.to(() => WatchPage(
                          videoUrl: videoUrl,
                          title: title.toString(),
                          movieData: Map<String, dynamic>.from(episodeData),
                          movies: episodesList,
                          currentIndex: currentEpisodeIndex,
                        ));
                      },
                      child: Container(
                        width: 38.w, // 👈 smaller width for better carousel look
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(14)),
                                  child: thumb.isNotEmpty
                                      ? Image.network(
                                    thumb,
                                    width: double.infinity,
                                    height: 30.h,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    width: double.infinity,
                                    height: 30.h,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.tv,
                                        color: Colors.white70),
                                  ),
                                ),
                                Container(
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(14)),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.5),
                                        Colors.transparent
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white.withOpacity(0.85),
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Title + duration
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 1.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (duration != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 0.3.h),
                                      child: Text(
                                        "$duration",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 9.sp,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Right fade effect
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      );
    }).toList();
  }
}

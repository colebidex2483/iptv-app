// movie_details_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

import '../const/appColors.dart';
import '../modules/playlists/controllers/playlists_controller.dart';
import '../modules/watch/views/watch_page.dart';

class MovieDetailsPage extends StatefulWidget {
  final Map<String, dynamic> movie;
  final List<Map<String, dynamic>> movies;
  final int currentIndex;

  const MovieDetailsPage({
    super.key,
    required this.movie,
    required this.movies,
    required this.currentIndex,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final PlaylistController playlistController = Get.find<PlaylistController>();

  Map<String, dynamic> get m => widget.movie;

  // --- Getters with fallbacks ---
  String get poster =>
      (m['poster'] ??
          m['cover_big'] ??
          m['movie_image'] ??
          m['stream_icon'] ??
          m['cover'] ??
          '')
          .toString();

  String get backdrop {
    if (m['backdrop_path'] is List && m['backdrop_path'].isNotEmpty) {
      return m['backdrop_path'][0].toString();
    }
    return (m['backdrop'] ??
        m['fanart'] ??
        m['cover_big'] ??
        m['movie_image'] ??
        m['cover'] ??
        '')
        .toString();
  }

  String get title =>
      (m['name'] ??
          m['o_name'] ??
          m['title'] ??
          m['movie_name'] ??
          'Untitled')
          .toString();

  String get year {
    final released =
    (m['releasedate'] ?? m['release_date'] ?? m['year'] ?? '').toString();
    if (released.isNotEmpty && released.length >= 4) {
      return released.substring(0, 4);
    }
    return '';
  }

  String get duration =>
      (m['duration'] ??
          m['runtime'] ??
          m['duration_secs']?.toString() ??
          m['episode_run_time']?.toString() ??
          '')
          .toString();

  double get rating {
    final r = (m['rating'] ??
        m['rating_kinopoisk'] ??
        m['imdb_rating'] ??
        m['vote_average']);
    if (r == null) return 0;
    return double.tryParse(r.toString()) ?? 0;
  }

  String get genres => (m['genres'] ?? m['genre'] ?? '').toString();

  String get overview =>
      (m['overview'] ?? m['plot'] ?? m['description'] ?? '').toString();

  String get director => (m['director'] ?? '').toString();

  String get actors => (m['actors'] ?? '').toString();

  String get added => (m['year'] ?? '').toString();

  String? get trailer =>
      (m['youtube_trailer'] ?? m['trailer'] ?? m['trailer_url'])?.toString();

  String? get streamUrl => (m['url'] ?? m['direct_source'] ?? '').toString();

  // ✅ Use isSeries: false because this page is for movies
  bool get isFavorite =>
      playlistController.isFavorite(m['id']?.toString(), isSeries: false);

  // --- Resume detection ---
  Map<String, dynamic>? get resumeData =>
      playlistController.getResumeProgress(m['id']?.toString());

  bool get hasResume {
    final pos = resumeData?['position'] as Duration?;
    final dur = resumeData?['duration'] as Duration?;
    return pos != null && dur != null && pos > Duration.zero;
  }

  void _toggleFavorite() {
    final newVal = !isFavorite;
    playlistController.updateFavorite(
      m['id']?.toString(),
      newVal,
      isSeries: false, // ✅ ensure it updates movie favorites only
    );
    setState(() {}); // rebuild to reflect change
  }

  void _watchNow({bool resume = false}) {
    if (streamUrl == null || streamUrl!.isEmpty) {
      Get.snackbar("Error", "No stream available",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Duration? start;
    if (resume && resumeData != null) {
      start = resumeData!['position'] as Duration?;
    }

    Get.to(() => WatchPage(
      videoUrl: streamUrl!,
      title: title,
      movieData: m,
      movies: widget.movies,
      currentIndex: widget.currentIndex,
      startPosition: start,
    ));
  }

  void _playTrailer() {
    if (trailer == null || trailer!.isEmpty) {
      Get.snackbar('Trailer', 'No trailer available',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.to(() => WatchPage(
      videoUrl: trailer!,
      title: '$title • Trailer',
      movieData: m,
      movies: widget.movies,
      currentIndex: widget.currentIndex,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cast = (m['cast'] is List)
        ? List<Map>.from(m['cast'])
        : (actors.isNotEmpty
        ? actors.split(',').map((e) => {'name': e.trim()}).toList()
        : const <Map>[]);

    final double posterW = 120;
    final double posterH = 170;

    final metaParts = <String>[
      if (year.isNotEmpty) year,
      if (genres.isNotEmpty) genres,
      if (duration.isNotEmpty) duration,
    ];
    final metaLine = metaParts.join(', ');

    // progress percentage
    final pos = resumeData?['position'] as Duration?;
    final dur = resumeData?['duration'] as Duration?;
    final double progress =
    (pos != null && dur != null && dur.inSeconds > 0)
        ? pos.inSeconds / dur.inSeconds
        : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (backdrop.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: backdrop,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(height: 1.h),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: poster.isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: poster,
                                    width: posterW,
                                    height: posterH,
                                    fit: BoxFit.cover,
                                  )
                                      : _posterFallbackSized(posterW, posterH),
                                ),
                                if (hasResume)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: posterW,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: progress,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 4.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (hasResume)
                                        _actionPill(
                                          Icons.play_arrow,
                                          "Resume",
                                              () => _watchNow(resume: true),
                                        )
                                      else
                                        _actionPill(
                                          Icons.play_arrow,
                                          "Watch Now",
                                              () => _watchNow(resume: false),
                                        ),
                                      SizedBox(width: 8),
                                      _outlinePill(Icons.ondemand_video,
                                          "Trailer", _playTrailer),
                                      SizedBox(width: 8),
                                      _iconPill(
                                        isFavorite
                                            ? Icons.star
                                            : Icons.star_border,
                                        _toggleFavorite,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.5.h),

                                  Text(
                                    "$title",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.5.sp,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  if (metaLine.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 0.8.h),
                                      child: Text(
                                        metaLine,
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.5.sp),
                                      ),
                                    ),

                                  Padding(
                                    padding: EdgeInsets.only(top: 1.2.h),
                                    child: Row(
                                      children: [
                                        _stars(rating),
                                        SizedBox(width: 10),
                                        Text(
                                          rating == 0
                                              ? '--'
                                              : rating.toStringAsFixed(
                                              rating % 1 == 0 ? 0 : 1),
                                          style: const TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (added.isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 0.8.h),
                                      child: Text(
                                        "Date Added: $added",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.5.sp),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        if (overview.isNotEmpty)
                          Text(
                            overview,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 13.8.sp,
                                height: 1.8),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  if (director.isNotEmpty) ...[
                    Text(
                      "Director: $director",
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 17.sp),
                    ),
                    SizedBox(height: 2.h),
                  ],

                  if (cast.isNotEmpty) ...[
                    Text(
                      "Cast:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 1.h),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: cast.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final item = cast[i];
                          final name =
                          (item['name'] ?? item['actor'] ?? '').toString();
                          final photo =
                          (item['photo'] ?? item['image'] ?? '').toString();
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: photo.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: photo,
                                  width: 110,
                                  height: 72,
                                  fit: BoxFit.cover,
                                )
                                    : _avatarFallbackRect(110, 72),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 110,
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _actionPill(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2F8AF6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
    );
  }

  Widget _outlinePill(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.18)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Widget _iconPill(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.amber),
      ),
    );
  }

  Widget _posterFallbackSized(double w, double h) => Container(
    width: w,
    height: h,
    alignment: Alignment.center,
    decoration: BoxDecoration(
        color: Colors.white10, borderRadius: BorderRadius.circular(12)),
    child: const Icon(Icons.movie, color: Colors.white70, size: 36),
  );

  Widget _avatarFallbackRect(double w, double h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
        color: Colors.white10, borderRadius: BorderRadius.circular(10)),
    alignment: Alignment.center,
    child: const Icon(Icons.person, color: Colors.white54, size: 32),
  );

  Widget _stars(double value) {
    const total = 5;
    final v5 = (value / 2).clamp(0, 5);
    final full = v5.floor();
    final hasHalf = (v5 - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        if (i < full) {
          return const Icon(Icons.star, color: Colors.amber, size: 20);
        }
        if (i == full && hasHalf) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
        }
        return const Icon(Icons.star_border, color: Colors.amber, size: 20);
      }),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modules/playlists/controllers/playlists_controller.dart';
import 'season_page.dart';

class SeriesDetailsPage extends StatefulWidget {
  final Map<String, dynamic> series;
  final List<Map<String, dynamic>> seriesList;
  final int currentIndex;

  const SeriesDetailsPage({
    super.key,
    required this.series,
    required this.seriesList,
    required this.currentIndex,
  });

  @override
  State<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends State<SeriesDetailsPage> {
  final PlaylistController playlistController = Get.find();

  Map<String, dynamic> get s => widget.series;

  // --- Getters with fallbacks ---
  String get poster =>
      (s['cover'] ??
          s['series_image'] ??
          s['poster'] ??
          s['stream_icon'] ??
          '')
          .toString();

  String get backdrop {
    if (s['backdrop_path'] is List && s['backdrop_path'].isNotEmpty) {
      return s['backdrop_path'][0].toString();
    }
    return (s['backdrop'] ??
        s['fanart'] ??
        s['cover'] ??
        s['series_image'] ??
        '')
        .toString();
  }

  String get title => (s['name'] ?? s['title'] ?? 'Untitled').toString();

  String get year {
    final released =
    (s['releaseDate'] ?? s['releasedate'] ?? s['year'] ?? '').toString();
    if (released.isNotEmpty && released.length >= 4) {
      return released.substring(0, 4);
    }
    return '';
  }

  String get duration => (s['episode_run_time']?.toString() ?? '').toString();

  double get rating {
    final r = (s['rating'] ??
        s['rating_kinopoisk'] ??
        s['imdb_rating'] ??
        s['vote_average']);
    if (r == null) return 0;
    return double.tryParse(r.toString()) ?? 0;
  }

  String get genres => (s['genre'] ?? '').toString();

  String get overview => (s['plot'] ?? s['description'] ?? '').toString();

  String get director => (s['director'] ?? '').toString();

  String get actors => (s['cast'] ?? '').toString();

  String get added => (s['year'] ?? '').toString();

  String? get trailer =>
      (s['youtube_trailer'] ?? s['trailer'] ?? s['trailer_url'])?.toString();

  // Use controller-backed favorite state (Hive / reactive)
  bool get isFavorite =>
      playlistController.isFavorite(s['id']?.toString(), isSeries: true);

  // --- Resume detection (optional for series episodes) ---
  Map<String, dynamic>? get resumeData =>
      playlistController.getResumeProgress(s['id']?.toString());

  bool get hasResume {
    final pos = resumeData?['position'] as Duration?;
    final dur = resumeData?['duration'] as Duration?;
    return pos != null && dur != null && pos > Duration.zero;
  }

  void _toggleFavorite() {
    final newVal = !isFavorite;
    playlistController.updateFavorite(
      s['id']?.toString(),
      newVal,
      isSeries: true, // ✅ ensure it updates movie favorites only
    );
    setState(() {}); // rebuild to reflect change
  }

  void _watchSeason() {
    Get.to(() => SeasonPage(series: s));
  }

  void _playTrailer() async {
    if (trailer == null || trailer!.isEmpty) {
      Get.snackbar(
        'Trailer',
        'No trailer available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withOpacity(0.8), // darker background
        colorText: Colors.white,                        // make text white
        margin: const EdgeInsets.all(12),               // optional padding around
        borderRadius: 8,                                // rounded corners
        // snackStyle: SnackStyle.FLOATING,                // modern floating look
      );
      return;
    }

    // Build a proper YouTube URL
    final youtubeUrl = Uri.parse("https://www.youtube.com/watch?v=$trailer");

    // Try to launch YouTube
    if (await canLaunchUrl(youtubeUrl)) {
      await launchUrl(
        youtubeUrl,
        mode: LaunchMode.externalApplication, // Ensures default app (YouTube)
      );
    } else {
      Get.snackbar(
        'Error',
        'Could not open trailer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withOpacity(0.8), // darker background
        colorText: Colors.white,                        // make text white
        margin: const EdgeInsets.all(12),               // optional padding around
        borderRadius: 8,                                // rounded corners
        // snackStyle: SnackStyle.FLOATING,                // modern floating look
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cast = (s['cast'] is List)
        ? List<Map>.from(s['cast'])
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (backdrop.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: backdrop,
                fit: BoxFit.cover, // fills the screen, crops proportionally
                alignment: Alignment.center, // centers the image
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
                              ],
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      _actionPill(Icons.tv, "Watch Season",
                                          _watchSeason),
                                      SizedBox(width: 8),
                                      _outlinePill(Icons.ondemand_video,
                                          "Trailer", _playTrailer),
                                      SizedBox(width: 8),
                                      // Make the star reactive using Obx and the controller's favoriteIds
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
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
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

  // --- Helpers (copied from movie details) ---
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
    child: const Icon(Icons.tv, color: Colors.white70, size: 36),
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

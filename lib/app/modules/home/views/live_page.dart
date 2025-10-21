import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/core/hive_service.dart';
import 'package:sizer/sizer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import '../../playlists/controllers/playlists_controller.dart';
import 'package:get/get.dart';

class LivePage extends StatefulWidget {
  final String? searchQuery;
  const LivePage({Key? key, this.searchQuery}) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  List<Map<String, dynamic>> allPlaylists = [];
  List<Map<String, dynamic>> allChannels = [];
  List<Map<String, dynamic>> filteredChannels = [];
  List<Map<String, dynamic>> recentlyViewed = [];
  List<Map<String, dynamic>> favorites = [];
  Map<String, dynamic>? connectedPlaylist;
  String get connectedPlaylistId => connectedPlaylist?['id']?.toString() ?? '';
  final PlaylistController controller = Get.find<PlaylistController>();

  Map<String, int> categoryCountMap = {};
  List<String> availableCategories = ['all', 'recently_viewed'];
  String selectedCategory = 'all';
  String? selectedPlaylistId;

  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  bool _isInitialized = false;
  int _selectedChannelIndex = -1;
  bool _isXtreamPlaylist = false;
  List<String> hiddenCategories = [];

  final Map<String, List<String>> categoryKeywords = {
    'Sports': ['sport', 'football', 'futbol', 'nba', 'nfl', 'ufc', 'wwe', 'mma'],
    'News': ['news', 'cnn', 'bbc', 'al jazeera', 'sky news'],
    'Movies': ['film', 'movie', 'cinema', 'hollywood', 'bollywood'],
    'Series': ['series', 'episode', 'tv show'],
    'Kids': ['kids', 'cartoon', 'disney', 'nick', 'baby', 'panda', 'cbeebies'],
    'Music': ['music', 'mtv', 'radio', 'trace', 'hits'],
    'Documentaries': ['docu', 'history', 'discovery', 'natgeo', 'geo'],
    'Religious': ['church', 'islam', 'muslim', 'bible', 'god', 'jesus', 'quran'],
    'Entertainment': ['entertainment', 'comedy', 'fun'],
  };

  final Map<String, IconData> categoryIcons = {
    'all': Icons.apps_rounded,
    'recently_viewed': Icons.history_rounded,
    'sports': Icons.sports_soccer_rounded,
    'news': Icons.newspaper_rounded,
    'movies': Icons.movie_creation_rounded,
    'kids': Icons.child_care_rounded,
    'religious': Icons.self_improvement_rounded,
  };

  bool _isChannelFavorite(Map<String, dynamic> channel) {
    return favorites.any((fav) => fav['url'] == channel['url']);
  }

  Future<void> _toggleFavorite(Map<String, dynamic> channel) async {
    final exists = favorites.any((fav) => fav['url'] == channel['url']);
    if (exists) {
      favorites.removeWhere((fav) => fav['url'] == channel['url']);
    } else {
      favorites.add(channel);
    }
    await HiveService.saveLiveFavorites(favorites);
    setState(() {});
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('sport')) return Icons.sports_soccer_rounded;
    if (lowerName.contains('news')) return Icons.newspaper_rounded;
    if (lowerName.contains('movie') || lowerName.contains('cinema')) return Icons.movie_creation_rounded;
    if (lowerName.contains('kid') || lowerName.contains('cartoon') || lowerName.contains('children')) return Icons.child_care_rounded;
    if (lowerName.contains('religious') || lowerName.contains('god') || lowerName.contains('jesus') || lowerName.contains('islam')) return Icons.self_improvement_rounded;
    if (lowerName.contains('music')) return Icons.music_note_rounded;
    if (lowerName.contains('documentary')) return Icons.nature_rounded;
    if (lowerName.contains('entertainment')) return Icons.theater_comedy_rounded;
    return Icons.tv_rounded;
  }

  String _getCategoryDisplayName(String category) {
    if (category == 'all') return 'all'.tr;
    if (category == 'recently_viewed') return 'recently_viewed'.tr;
    return category;
  }

  @override
  void initState() {
    super.initState();
    _initializeLivePage();
  }

  Future<void> _initializeLivePage() async {
    await loadHiddenCategories();
    allPlaylists = HiveService.getCachedPlaylists() ?? [];
    connectedPlaylist = allPlaylists.firstWhereOrNull((p) => p['isConnected'] == true);
    recentlyViewed = await HiveService.getLiveRecentlyViewed(connectedPlaylistId);
    await loadAllChannels();
  }

  Future<void> loadAllChannels() async {
    allPlaylists = HiveService.getCachedPlaylists() ?? [];
    if (allPlaylists.isEmpty) return;

    selectedPlaylistId ??= allPlaylists
        .firstWhere((p) => p['isConnected'] == true, orElse: () => allPlaylists.first)['id'];

    _loadChannelsForSelectedPlaylist();
  }

  Future<void> _loadChannelsForSelectedPlaylist() async {
    if (selectedPlaylistId == null) return;

    final currentPlaylist = allPlaylists.firstWhere(
          (p) => p['id'] == selectedPlaylistId,
      orElse: () => allPlaylists.first,
    );

    _isXtreamPlaylist = currentPlaylist['type'] == 'xtream' ||
        (currentPlaylist['url']?.contains('/player_api.php') ?? false);

    await loadHiddenCategories();

    if (_isXtreamPlaylist) {
      await controller.loadXtreamChannels(selectedPlaylistId!);
      final raw = controller.channels;
      allChannels = raw
          .map<Map<String, dynamic>>((ch) => Map<String, dynamic>.from(ch))
          .where((ch) => ch['url'] != null)
          .toList();
      _generateXtreamCategories();
    } else {
      final raw = HiveService.getCachedChannels(selectedPlaylistId!) ?? [];
      allChannels = raw
          .map<Map<String, dynamic>>((ch) => Map<String, dynamic>.from(ch))
          .where((ch) => ch['url'] != null)
          .toList();
      _generateM3uCategories();
    }

    _applyCategoryFilter();
  }

  Future<void> loadHiddenCategories() async {
    try {
      hiddenCategories = await HiveService.getHiddenLiveCategories() ?? [];
    } catch (_) {
      hiddenCategories = [];
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _generateXtreamCategories() {
    availableCategories = ['all', 'recently_viewed', 'favorites'];
    categoryCountMap = {
      'all': allChannels.length,
      'recently_viewed': recentlyViewed.length,
      'favorites': favorites.length,
    };

    final normalizedHidden = hiddenCategories.map((c) => _toTitleCase(c)).toList();
    final Map<String, int> xtreamCounts = {};

    for (var ch in allChannels) {
      final rawCat = (ch['category_name'] ?? '').toString().trim();
      final catKey = _toTitleCase(rawCat).isEmpty ? 'Others' : _toTitleCase(rawCat);

      if (!normalizedHidden.contains(catKey)) {
        xtreamCounts[catKey] = (xtreamCounts[catKey] ?? 0) + 1;
        ch['normalizedCategory'] = catKey;
      }
    }

    final sortedCats = xtreamCounts.keys.toList()..sort();
    availableCategories.addAll(sortedCats.map((c) => _toTitleCase(c)));
    categoryCountMap.addAll(xtreamCounts);
    setState(() {});
  }

  void _generateM3uCategories() {
    availableCategories = ['all', 'recently_viewed', 'favorites'];
    categoryCountMap = {
      'all': allChannels.length,
      'recently_viewed': recentlyViewed.length,
      'favorites': favorites.length,
    };

    final normalizedHidden = hiddenCategories.map((c) => _toTitleCase(c)).toList();
    final Map<String, int> m3uCounts = {};

    for (var ch in allChannels) {
      final rawCat = (ch['category'] ?? '').toString();
      final matches = rawCat.split(RegExp(r'[;,]')).map((e) => e.trim().toLowerCase());

      bool matched = false;
      for (var defCat in categoryKeywords.entries) {
        if (matches.any((m) => defCat.value.any((k) => m.contains(k)))) {
          final catKey = defCat.key;
          if (!normalizedHidden.contains(catKey)) {
            m3uCounts[catKey] = (m3uCounts[catKey] ?? 0) + 1;
            ch['normalizedCategory'] = catKey;
          }
          matched = true;
          break;
        }
      }

      if (!matched) {
        const fallback = 'Others';
        if (!normalizedHidden.contains(fallback)) {
          ch['normalizedCategory'] = fallback;
          m3uCounts[fallback] = (m3uCounts[fallback] ?? 0) + 1;
        }
      }
    }

    final filteredM3uCats = m3uCounts.keys.toList()..sort();
    availableCategories.addAll(filteredM3uCats.map((c) => _toTitleCase(c)));
    categoryCountMap.addAll(m3uCounts);
    setState(() {});
  }

  void _applyCategoryFilter() {
    List<Map<String, dynamic>> baseList = [];

    if (selectedCategory == 'all') {
      baseList = allChannels;
    } else if (selectedCategory == 'recently_viewed') {
      baseList = recentlyViewed.reversed.toList();
    } else if (selectedCategory == 'favorites') {
      baseList = favorites.reversed.toList();
    } else if (_isXtreamPlaylist) {
      baseList = allChannels
          .where((ch) =>
      (ch['category_name']?.toString().trim() ?? '').toLowerCase() ==
          selectedCategory.toLowerCase())
          .toList();
    } else {
      baseList = allChannels
          .where((ch) =>
      (ch['normalizedCategory'] ?? '').toLowerCase() ==
          selectedCategory.toLowerCase())
          .toList();
    }

    baseList = baseList.where((ch) {
      final xtreamCat = (ch['category_name']?.toString().trim().toLowerCase() ?? '');
      final m3uCat = (ch['normalizedCategory']?.toString().toLowerCase() ?? '');
      return !hiddenCategories.contains(xtreamCat) && !hiddenCategories.contains(m3uCat);
    }).toList();

    setState(() {
      filteredChannels = baseList;
      _selectedChannelIndex = -1;
    });
  }

  @override
  void didUpdateWidget(covariant LivePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _applySearchFilter();
    }
  }

  void _applySearchFilter() {
    final query = (widget.searchQuery ?? '').toLowerCase().trim();

    List<Map<String, dynamic>> baseList;
    if (selectedCategory == 'all') {
      baseList = allChannels;
    } else if (selectedCategory == 'recently_viewed') {
      baseList = recentlyViewed.reversed.toList();
    } else if (_isXtreamPlaylist) {
      baseList = allChannels
          .where((ch) => ch['category_name']?.toString().trim() == selectedCategory)
          .toList();
    } else {
      baseList = allChannels
          .where((ch) => ch['normalizedCategory'] == selectedCategory)
          .toList();
    }

    if (query.isEmpty) {
      filteredChannels = baseList;
    } else {
      filteredChannels = baseList.where((ch) {
        final name = (ch['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    }

    setState(() {
      _selectedChannelIndex = -1;
    });
  }

  Future<void> _playChannel(String url, int index) async {
    if (url.isEmpty) return;

    setState(() {
      _selectedChannelIndex = index;
      _isInitialized = false;
    });

    bool wasFullScreen = _chewieController?.isFullScreen ?? false;

    try {
      _chewieController?.pause();
      _chewieController?.dispose();
      if (_videoPlayerController.value.isInitialized) {
        await _videoPlayerController.dispose();
      }
    } catch (_) {}

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoPlayerController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        customControls: _CustomChewieControls(
          onNext: _playNext,
          onPrevious: _playPrevious,
          onExitFullscreen: _exitFullscreen,
        ),
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        allowFullScreen: true,
      );

      await WakelockPlus.enable();

      if (wasFullScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _chewieController != null) {
            _chewieController!.enterFullScreen();
          }
        });
      }

      final selectedChannel = filteredChannels[index];
      if (!recentlyViewed.any((ch) => ch['url'] == selectedChannel['url'])) {
        recentlyViewed.add(selectedChannel);
        if (recentlyViewed.length > 10) recentlyViewed.removeAt(0);
        await HiveService.saveLiveRecentlyViewed(connectedPlaylistId ?? '', recentlyViewed);
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed_to_load_channel'.tr)),
      );
    }
  }

  void _exitFullscreen() {
    if (_chewieController != null && _chewieController!.isFullScreen) {
      _chewieController!.exitFullScreen();
    }
  }

  void _playNext() {
    if (_selectedChannelIndex < filteredChannels.length - 1) {
      final nextIndex = _selectedChannelIndex + 1;
      final nextUrl = filteredChannels[nextIndex]['url'] ?? '';
      if (nextUrl.isNotEmpty) {
        _playChannel(nextUrl, nextIndex);
      }
    }
  }

  void _playPrevious() {
    if (_selectedChannelIndex > 0) {
      final prevIndex = _selectedChannelIndex - 1;
      final prevUrl = filteredChannels[prevIndex]['url'] ?? '';
      if (prevUrl.isNotEmpty) {
        _playChannel(prevUrl, prevIndex);
      }
    }
  }

  Widget _buildCategoryTile(String label) {
    final isSelected = selectedCategory == label;
    final count = categoryCountMap[label] ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.4.h, horizontal: 1.2.w),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Color(0xFFFF6B35).withOpacity(0.5), width: 1)
            : null,
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedCategory = label;
              _selectedChannelIndex = -1;
            });
            _applyCategoryFilter();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.5.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(0.6.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryIcons[label] ?? _getCategoryIcon(label),
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCategoryDisplayName(label),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 0.2.h),
                      Text(
                        '$count ${count == 1 ? "channel" : "channels"}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white.withOpacity(0.5),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelCard(Map<String, dynamic> channel, int index) {
    final isSelected = _selectedChannelIndex == index;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.4.h, horizontal: 1.w),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF0A0A0A)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: Color(0xFFFF6B35), width: 2)
            : Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: Color(0xFFFF6B35).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 3),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final url = channel['url'] ?? '';
            if (url.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _playChannel(url, index);
              });
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 1.5.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(0.8.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(0xFFFF6B35).withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.live_tv_rounded,
                    color: isSelected ? Color(0xFFFF6B35) : Colors.white.withOpacity(0.7),
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 1.5.w),
                Expanded(
                  child: Text(
                    channel['name'] ?? 'Unnamed Channel'.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF6B35).withOpacity(0.4),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.white, size: 12.sp),
                        SizedBox(width: 0.3.w),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      _videoPlayerController.dispose();
      _chewieController?.dispose();
    } catch (_) {}
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0A0A),
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          // Categories Panel
          Flexible(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D0D0D), Color(0xFF050505)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                ),
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                children: availableCategories.map(_buildCategoryTile).toList(),
              ),
            ),
          ),

          // Channels Panel
          Flexible(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
                ),
              ),
              child: filteredChannels.isEmpty
                  ? Center(
                child: Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tv_off_rounded,
                        size: 40.sp,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'no_channels_found'.trParams({
                          'category': _getCategoryDisplayName(selectedCategory)
                        }),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                itemCount: filteredChannels.length,
                itemBuilder: (context, index) =>
                    _buildChannelCard(filteredChannels[index], index),
              ),
            ),
          ),

          // Video Player Panel
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF000000), Color(0xFF0A0A0A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.all(1.5.h),
              child: Column(
                children: [
                  // Video Player
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _isInitialized && _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF6B35),
                                ),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Loading Stream...',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Now Playing Card - Directly attached (no gap)
                  if (_selectedChannelIndex >= 0 &&
                      _selectedChannelIndex < filteredChannels.length)
                    Container(
                      margin: EdgeInsets.only(top: 1.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFFF6B35).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFF6B35).withOpacity(0.15),
                            blurRadius: 16,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(1.8.h),
                        child: Row(
                          children: [
                            // Channel Logo
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color(0xFF252525),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFFFF6B35).withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: filteredChannels[_selectedChannelIndex]['logo'] !=
                                    null &&
                                    filteredChannels[_selectedChannelIndex]['logo']
                                        .isNotEmpty
                                    ? Image.network(
                                  filteredChannels[_selectedChannelIndex]['logo'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.tv_rounded,
                                        color: Colors.white.withOpacity(0.5),
                                        size: 24.sp,
                                      ),
                                )
                                    : Icon(
                                  Icons.tv_rounded,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 24.sp,
                                ),
                              ),
                            ),

                            SizedBox(width: 2.w),

                            // Channel Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // "Now Playing" with pulsing dot
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFF3B30),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFFFF3B30).withOpacity(0.6),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 0.8.w),
                                      Text(
                                        "NOW PLAYING".tr.toUpperCase(),
                                        style: TextStyle(
                                          color: Color(0xFFFF3B30),
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 0.8.h),

                                  // Channel Name
                                  Text(
                                    filteredChannels[_selectedChannelIndex]['name'] ??
                                        "Unknown Channel".tr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      letterSpacing: 0.3,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: 0.5.h),

                                  // Category Badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 1.2.w,
                                      vertical: 0.4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B35).withOpacity(0.2),
                                          Color(0xFFFF8E53).withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Color(0xFFFF6B35).withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getCategoryIcon(
                                            _isXtreamPlaylist
                                                ? (filteredChannels[_selectedChannelIndex]
                                            ['category_name'] ??
                                                "")
                                                : (filteredChannels[_selectedChannelIndex]
                                            ['normalizedCategory'] ??
                                                ""),
                                          ),
                                          color: Color(0xFFFF6B35),
                                          size: 11.sp,
                                        ),
                                        SizedBox(width: 0.5.w),
                                        Text(
                                          _isXtreamPlaylist
                                              ? (filteredChannels[_selectedChannelIndex]
                                          ['category_name'] ??
                                              "Live Stream")
                                              : (filteredChannels[_selectedChannelIndex]
                                          ['normalizedCategory'] ??
                                              "Live Stream")
                                              .toString()
                                              .tr,
                                          style: TextStyle(
                                            color: Color(0xFFFF6B35),
                                            fontSize: 9.5.sp,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Favorite Button
                            Container(
                              decoration: BoxDecoration(
                                color: _isChannelFavorite(
                                    filteredChannels[_selectedChannelIndex])
                                    ? Color(0xFFFF3B30).withOpacity(0.15)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _isChannelFavorite(
                                      filteredChannels[_selectedChannelIndex])
                                      ? Color(0xFFFF3B30).withOpacity(0.4)
                                      : Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.all(1.2.h),
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  _isChannelFavorite(
                                      filteredChannels[_selectedChannelIndex])
                                      ? Icons.favorite
                                      : Icons.favorite_border_rounded,
                                  color: _isChannelFavorite(
                                      filteredChannels[_selectedChannelIndex])
                                      ? Color(0xFFFF3B30)
                                      : Colors.white.withOpacity(0.6),
                                  size: 20.sp,
                                ),
                                onPressed: () => _toggleFavorite(
                                    filteredChannels[_selectedChannelIndex]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------- CUSTOM CHEWIE CONTROLS -------------------
class _CustomChewieControls extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onExitFullscreen;

  const _CustomChewieControls({
    this.onNext,
    this.onPrevious,
    this.onExitFullscreen,
    Key? key,
  }) : super(key: key);

  @override
  State<_CustomChewieControls> createState() => _CustomChewieControlsState();
}

class _CustomChewieControlsState extends State<_CustomChewieControls>
    with SingleTickerProviderStateMixin {
  late ChewieController chewieController;
  late VideoPlayerController controller;

  bool _hideControls = false;
  Timer? _hideTimer;

  late AnimationController _centerButtonsAnimation;
  late Animation<double> _centerScale;

  VideoPlayerValue get _latestValue => controller.value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;
    controller.addListener(_updateState);
    _updateState();
    _startHideTimer();

    _centerButtonsAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _centerScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _centerButtonsAnimation, curve: Curves.easeOut),
    );
    _centerButtonsAnimation.forward();
  }

  void _updateState() {
    if (!mounted) return;
    setState(() {});
  }

  void _onUserInteraction() {
    if (!mounted) return;
    setState(() => _hideControls = false);
    _centerButtonsAnimation.forward();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _hideControls = true);
        _centerButtonsAnimation.reverse();
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    controller.removeListener(_updateState);
    _centerButtonsAnimation.dispose();
    super.dispose();
  }

  String _formatDuration(Duration position) {
    final twoDigits = (int n) => n.toString().padLeft(2, "0");
    final twoDigitMinutes = twoDigits(position.inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(position.inSeconds.remainder(60));
    return "${twoDigits(position.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onUserInteraction,
      child: Stack(
        children: [
          // Gradient Overlays for better control visibility
          if (!_hideControls)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: [0.0, 0.2, 0.7, 1.0],
                  ),
                ),
              ),
            ),

          // Back arrow in fullscreen mode (top-left)
          if (chewieController.isFullScreen)
            Positioned(
              top: 2.h,
              left: 2.w,
              child: AnimatedOpacity(
                opacity: _hideControls ? 0 : 1,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: () {
                        if (widget.onExitFullscreen != null) {
                          widget.onExitFullscreen!();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

          // Center controls: Prev | Play/Pause | Next
          AnimatedOpacity(
            opacity: _hideControls ? 0 : 1,
            duration: const Duration(milliseconds: 250),
            child: Align(
              alignment: Alignment.center,
              child: ScaleTransition(
                scale: _centerScale,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(0xFFFF6B35).withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.skip_previous_rounded,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                          onPressed: widget.onPrevious,
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // Play/Pause Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF6B35).withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _latestValue.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40.sp,
                          ),
                          onPressed: () {
                            _onUserInteraction();
                            setState(() {
                              _latestValue.isPlaying
                                  ? controller.pause()
                                  : controller.play();
                            });
                          },
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // Next Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                          onPressed: widget.onNext,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom progress bar with enhanced styling
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedOpacity(
              opacity: _hideControls ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(_latestValue.position),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          padding: EdgeInsets.zero,
                          colors: VideoProgressColors(
                            playedColor: Color(0xFFFF6B35),
                            bufferedColor: Colors.white.withOpacity(0.3),
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(_latestValue.duration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          chewieController.isFullScreen
                              ? Icons.fullscreen_exit_rounded
                              : Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                        onPressed: () {
                          _onUserInteraction();
                          if (mounted) chewieController.toggleFullScreen();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
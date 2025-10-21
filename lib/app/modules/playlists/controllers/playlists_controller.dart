import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/firebase_service.dart';
import '../../../core/hive_service.dart'; // make sure you have this import
import '../../../widgets/loading_dialog.dart';
import 'package:flutter/foundation.dart';
import '../../change_playlist/views/change_playlist.dart';
import '../../on_boarding/controllers/onboarding_controller.dart';

// M3U parsing logic
List<Map<String, String>> parseM3UContent(String content) {
  final channels = <Map<String, String>>[];
  final lines = LineSplitter.split(content);
  String? currentName;
  String? currentCategory;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('#EXTINF:')) {
      currentName = RegExp(r'tvg-name="([^"]*)"').firstMatch(trimmed)?.group(1) ??
          trimmed.split(',').last;
      currentCategory = RegExp(r'group-title="([^"]*)"').firstMatch(trimmed)?.group(1);
    } else if (trimmed.isNotEmpty && !trimmed.startsWith('#') && currentName != null) {
      final name = currentName!;
      final url = trimmed;
      final inferredCategory = _inferCategory(currentCategory, name);

      channels.add({
        'name': name,
        'url': url,
        'category': inferredCategory,
      });

      currentName = null;
      currentCategory = null;
    }
  }

  return channels;
}
String _inferCategory(String? rawCategory, String name) {
  final allCategories = {
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

  final source = '${rawCategory ?? ''} $name'.toLowerCase();

  for (final entry in allCategories.entries) {
    for (final keyword in entry.value) {
      if (source.contains(keyword)) return entry.key;
    }
  }

  return 'Others';
}
enum ContentType {
  live,
  movie,
  series,
}
class PlaylistController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final onboardingController = Get.find<OnboardingController>();
  final RxList<Map<String, dynamic>> playlists = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isVodLoading = false.obs;
  final RxBool isCacheLoading = false.obs;
  final RxString connectedPlaylistId = ''.obs;

// Add to PlaylistController class
  final RxList<Map<String, dynamic>> movies = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> series = <Map<String, dynamic>>[].obs;
  final Rxn<Map<String, dynamic>> selectedSeries = Rxn<Map<String, dynamic>>();
  final RxList<Map<String, dynamic>> resumeMovies = <Map<String, dynamic>>[].obs;
  final RxSet<String> favoriteMovieIds = <String>{}.obs;
  final RxSet<String> favoriteSeriesIds = <String>{}.obs;

  final RxList<Map<String, dynamic>> channels = <Map<String, dynamic>>[].obs;
  final RxBool isChannelsLoading = false.obs;

  final RxList<Map<String, dynamic>> liveCategories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> vodCategories = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> seriesCategories = <Map<String, dynamic>>[].obs;
// A helper to get the connected playlist (Map) using connectedPlaylistId

  Map<String, dynamic>? get currentPlaylist {
    final id = connectedPlaylistId.value;
    if (id.isEmpty) return null;

    // ✅ Try in-memory list first
    final fromMemory = playlists.firstWhereOrNull((p) => p['id'] == id);
    if (fromMemory != null) return fromMemory;

    // ✅ Fallback to cache
    final cached = HiveService.getCachedPlaylists() ?? [];
    return cached.firstWhereOrNull((p) => p['id'] == id);
  }

  @override
  void onInit() {
    super.onInit();
    favoriteMovieIds.addAll(HiveService.getFavoriteMovies());
    favoriteSeriesIds.addAll(HiveService.getFavoriteSeries());
    ever(onboardingController.deviceId, (String id) {
      if (id != null && id.isNotEmpty && id != "Loading...") {
        _loadConnectedPlaylist();
        loadPlaylists();
        loadCategories();
      }
    });
    // Initial check in case deviceId is already set
    if (onboardingController.deviceId.value != "Loading...") {
      initializeDefaultPlaylistIfNeeded();
      _loadConnectedPlaylist();
      loadPlaylists();
      loadCategories();
    }
  }

  /// Extract unique categories from loaded series
  void computeSeriesCategories() {
    final cats = series
        .map((s) => s['category'] ?? "Uncategorized")
        .toSet()
        .toList();

    cats.sort((a, b) {
      if (a == "Uncategorized") return 1; // push uncategorized to bottom
      if (b == "Uncategorized") return -1;
      return a.compareTo(b);
    });

    // Store as a list of maps to be consistent with your live/vod categories
    seriesCategories.assignAll(
      cats.map((c) => {'category_id': c, 'category_name': c}).toList(),
    );
  }


  /// ✅ Load categories (Hive first, then Firebase)
  Future<void> loadCategories() async {
    final playlistId = connectedPlaylistId.value;
    // if (playlistId.isEmpty) return;

    // 1. Try Hive
    final cached = HiveService.getCachedCategories(playlistId);
    if (cached != null) {
      liveCategories.assignAll(cached['live'] ?? []);
      vodCategories.assignAll(cached['vod'] ?? []);
      seriesCategories.assignAll(cached['series'] ?? []);
      return;
    }

    // 2. Fallback Firebase
    final fresh = await _firebaseService.getCategories(
      playlistId,
      onboardingController.deviceId.value,
    );
    if (fresh.isNotEmpty) {
      print(fresh);
      liveCategories.assignAll(fresh['live'] ?? []);
      vodCategories.assignAll(fresh['vod'] ?? []);
      seriesCategories.assignAll(fresh['series'] ?? []);

      // Save for offline
      await HiveService.cacheCategories(
        playlistId,
        live: liveCategories.toList(),
        vod: vodCategories.toList(),
        series: seriesCategories.toList(),
      );
    }
  }
  /// ✅ Helper to resolve category_id → name
  String resolveCategoryName(String? id, {ContentType type = ContentType.series}) {
    if (id == null) return "Uncategorized";

    List<Map<String, dynamic>> source;
    switch (type) {
      case ContentType.live:
        source = liveCategories;
        break;
      case ContentType.movie:
        source = vodCategories;
        break;
      case ContentType.series:
        source = seriesCategories;
        break;
    }

    final match = source.firstWhereOrNull((c) => c['category_id'].toString() == id);
    return match != null ? (match['category_name'] ?? "Uncategorized") : "Uncategorized";
  }

  /// ✅ Check if item is favorite
  bool isFavorite(String? id, {required bool isSeries}) {
    if (id == null) return false;
    return isSeries
        ? favoriteSeriesIds.contains(id)
        : favoriteMovieIds.contains(id);
  }

  /// ✅ Toggle favorite and persist
  void updateFavorite(String? id, bool isFav, {required bool isSeries}) {
    if (id == null) return;

    if (isSeries) {
      if (isFav) {
        favoriteSeriesIds.add(id);
      } else {
        favoriteSeriesIds.remove(id);
      }
      HiveService.saveFavoriteSeries(favoriteSeriesIds.toList());
    } else {
      if (isFav) {
        favoriteMovieIds.add(id);
      } else {
        favoriteMovieIds.remove(id);
      }
      HiveService.saveFavoriteMovies(favoriteMovieIds.toList());
    }

    // Update local VOD objects
    for (var movie in movies) {
      if (movie['id'].toString() == id) {
        movie['isFavorite'] = !isSeries && isFav;
        break;
      }
    }
    for (var s in series) {
      if (s['id'].toString() == id) {
        s['isFavorite'] = isSeries && isFav;
        break;
      }
    }

    // Refresh
    movies.refresh();
    series.refresh();
    favoriteMovieIds.refresh();
    favoriteSeriesIds.refresh();
  }


  // Future<void> loadVodContent(String playlistId) async {
  //   try {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       isVodLoading.value = true;
  //     });
  //
  //     // 1. Hive cache
  //     final cached = HiveService.getCachedVodContent(playlistId);
  //     if (cached != null && ((cached['movies'] ?? []).isNotEmpty || (cached['series'] ?? []).isNotEmpty)) {
  //      WidgetsBinding.instance.addPostFrameCallback((_) {
  //         movies.assignAll(cached['movies'] ?? []);
  //         loadResumeMovies(); // refresh resume list when movies load
  //         series.assignAll(cached['series'] ?? []);
  //         isVodLoading.value = false;
  //       });
  //       return;
  //     }
  //
  //     // 2. Firebase
  //     final content = await _firebaseService.getVodContent(
  //       playlistId,
  //       deviceId: onboardingController.deviceId.value,
  //     );
  //
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       movies.assignAll(content['movies'] ?? []);
  //        loadResumeMovies(); // refresh resume list when movies load
  //       series.assignAll(content['series'] ?? []);
  //       computeSeriesCategories();
  //       isVodLoading.value = false;
  //     });
  //
  //     // 3. Save
  //     await HiveService.cacheVodContent(playlistId, {
  //       'movies': movies.toList(),
  //       'series': series.toList(),
  //     });
  //
  //   } catch (e) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       isVodLoading.value = false;
  //     });
  //     print("❌ loadVodContent error: $e");
  //     Get.snackbar('Error', 'Failed to load VOD content: ${e.toString()}');
  //   }
  // }

  // 🔹 Load Resume Movies from Hive

  Future<void> loadVodContent(String playlistId) async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isVodLoading.value = true;
      });

      // 1️⃣ Try Hive cache
      final cached = HiveService.getCachedVodContent(playlistId);
      if (cached != null &&
          ((cached['movies'] ?? []).isNotEmpty || (cached['series'] ?? []).isNotEmpty)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          movies.assignAll(cached['movies'] ?? []);
          series.assignAll(cached['series'] ?? []);
          loadResumeMovies();
          computeSeriesCategories();
          isVodLoading.value = false;
        });
        return;
      }

      // 2️⃣ Fetch from Firebase (which auto-fetches Xtream + categories if not cached)
      final vodContent = await _firebaseService.getVodContent(
        playlistId,
        deviceId: onboardingController.deviceId.value,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        movies.assignAll(vodContent['movies'] ?? []);
        series.assignAll(vodContent['series'] ?? []);
        loadResumeMovies();
        computeSeriesCategories();
        isVodLoading.value = false;
      });

      // 3️⃣ Cache for offline access
      await HiveService.cacheVodContent(playlistId, {
        'movies': vodContent['movies'] ?? [],
        'series': vodContent['series'] ?? [],
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        isVodLoading.value = false;
      });
      print("❌ loadVodContent error: $e");
      // Get.snackbar('Error', 'Failed to load VOD content: ${e.toString()}');
    }
  }


  Future<void> loadResumeMovies() async {
    try {
      final resumePoints = HiveService.getAllResumePoints();
      final List<Map<String, dynamic>> matched = [];

      for (var m in movies) {
        final id = m['id'].toString();
        final point = resumePoints.firstWhereOrNull((p) => p['id'] == id);
        if (point != null) {
          matched.add({
            ...m,
            'resumePosition': Duration(seconds: point['position']),
            'duration': Duration(seconds: point['duration']),
          });
        }
      }

      resumeMovies.assignAll(matched);
    } catch (e) {
      resumeMovies.clear();
      print("❌ loadResumeMovies error: $e");
    }
  }

  /// Get resume progress for a specific movie by ID
  Map<String, dynamic>? getResumeProgress(String? movieId) {
    try {
      final resumePoints = HiveService.getAllResumePoints();
      final point = resumePoints.firstWhereOrNull((p) => p['id'] == movieId);

      if (point != null) {
        return {
          'position': Duration(seconds: point['position'] ?? 0),
          'duration': Duration(seconds: point['duration'] ?? 0),
          'isSeries': point['isSeries'] ?? false,
          'episodeId': point['episodeId'],
        };
      }
      return null;
    } catch (e) {
      print("❌ getResumeProgress error: $e");
      return null;
    }
  }

// Fetch series details via existing FirebaseService.fetchXtreamSeriesInfo
  Future<Map<String, dynamic>> fetchSeriesDetails({required String baseUrl, required String username, required String password, required String seriesId,}) async {
    try {
      // Normalize baseUrl (avoid trailing slash)
      var url = baseUrl;
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);

      final data = await _firebaseService.fetchXtreamSeriesInfo(
        baseUrl: url,
        username: username,
        password: password,
        seriesId: seriesId,
      );

       selectedSeries.value = data.isEmpty ? null : data;
        return data;
    } catch (e) {
      selectedSeries.value = null;
      Get.snackbar('Error', 'Failed to load series details: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchMovieDetails({required Map<String, dynamic> movie, required String baseUrl, required String username, required String password,}) async {
    final vodId = movie['id'].toString();
    return await _firebaseService.fetchXtreamMovieInfo(
      baseUrl: baseUrl,
      username: username,
      password: password,
      vodId: vodId,
    );
  }

  Future<void> fetchSeriesDetailsWithCache({required String baseUrl, required String username, required String password, required String seriesId,}) async {
    try {
      final deviceId = onboardingController.deviceId.value;
      final playlistId = connectedPlaylistId.value;

      if (playlistId.isEmpty) {
        throw 'No playlist connected';
      }

      // Normalize baseUrl
      var url = baseUrl;
      if (url.endsWith('/')) url = url.substring(0, url.length - 1);

      // Try to get from cache first
      final cachedSeries = await _getCachedSeriesDetails(deviceId, playlistId, seriesId);
      if (cachedSeries != null) {
        selectedSeries.value = cachedSeries;
        return;
      }

      // Fetch from API if not cached
      final data = await _firebaseService.getSeriesDetails(
        host: url,
        username: username,
        password: password,
        seriesId: seriesId,
        deviceId: deviceId,
        playlistId: playlistId,
      );
      selectedSeries.value = data;
    } catch (e) {
      selectedSeries.value = null;
      Get.snackbar('Error', 'Failed to load series details: $e');
    }
  }

// Helper method to get cached series details
  Future<Map<String, dynamic>?> _getCachedSeriesDetails(String deviceId, String playlistId, String seriesId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection("devices")
          .doc(deviceId)
          .collection("playlists")
          .doc(playlistId)
          .collection("series_details")
          .doc(seriesId)
          .get();

      if (doc.exists) {
        // Explicitly cast the data to Map<String, dynamic>
        return Map<String, dynamic>.from(doc.data() ?? {});
      }
      return null;
    } catch (e) {
      // log.e('Error getting cached series: $e');
      return null;
    }
  }

  Future<void> _loadConnectedPlaylist() async {
    final connectedId = await HiveService.getConnectedPlaylistId();
    if (connectedId != null) {
      connectedPlaylistId.value = connectedId;
    }
  }

  Future<void> loadPlaylists() async {
    try {
      isLoading.value = true;
      isCacheLoading.value = true;

      // 1. FIRST try fetching fresh data from Firebase
      final freshPlaylists = await _firebaseService.getPlaylists(
        onboardingController.deviceId.value,
      );

      // 2. OVERWRITE cache completely with fresh data
      await HiveService.cachePlaylists(freshPlaylists);

      // 3. Update UI
      playlists.assignAll(freshPlaylists.map(_addConnectionState));

      // 4. Add demo playlist ONLY if absolutely no playlists exist
      // final cachedPlaylists = HiveService.getCachedPlaylists();
      // if (freshPlaylists.isEmpty && (cachedPlaylists == null || cachedPlaylists.isEmpty)) {
      //   _addDemoPlaylist();
      // }
      if (freshPlaylists.isEmpty) {
        _addDemoPlaylist();
      }

    } catch (e) {
      // Fallback to cache only on error
      final cached = HiveService.getCachedPlaylists() ?? [];
      playlists.assignAll(cached.map(_addConnectionState));
      Get.snackbar('Error', 'Failed to load playlists: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isCacheLoading.value = false;
    }
  }

// Helper method
  Map<String, dynamic> _addConnectionState(Map<String, dynamic> playlist) {
    return {
      ...playlist,
      'isConnected': playlist['id'] == connectedPlaylistId.value,
    };
  }

// Add demo playlist
  void _addDemoPlaylist() async {
    final demoPlaylist = {
      'id': 'demo_001',
      'name': 'Demo Xtream Playlist',
      'baseUrl': 'http://costyv1.zapto.org:8008',
      'username': 'Danielcosti',
      'password': 'bQUu66HSqE123',
      'type': 'xtream',
      'isConnected': true,
      'createdAt': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'channelCount': 0,
    };

    // Check existing playlists in Hive
    final existing = HiveService.getCachedPlaylists() ?? [];

    // Ensure no duplicates
    if (!existing.any((p) => p['id'] == demoPlaylist['id'])) {
      existing.insert(0, demoPlaylist);
      await HiveService.cachePlaylists(existing);
    }

    playlists.assignAll(existing);

    // Ensure it’s connected if nothing else is
    final connectedId = await HiveService.getConnectedPlaylistId();
    if (connectedId == null || connectedId.isEmpty) {
      await connectPlaylist(demoPlaylist['id'] as String);
    }
  }

  /// Ensure demo playlist is always initialized
  Future<void> initializeDefaultPlaylistIfNeeded() async {
    try {
      final existing = HiveService.getCachedPlaylists();
      // print("Existin playlist: $existing");
      if (existing == null || existing.isEmpty) {
        _addDemoPlaylist();
      } else {
        // Ensure demo playlist is still there
        if (!existing.any((p) => p['id'] == 'demo_001')) {
          _addDemoPlaylist();
        } else {
          playlists.assignAll(existing);
        }
      }
    } catch (e) {
      print('❌ Error initializing demo Xtream playlist: $e');
    }
  }
  // Future<void> loadPlaylists() async {
  //   if (onboardingController.deviceId.value == "Loading..." ||
  //       onboardingController.deviceId.value.isEmpty) {
  //     print("Waiting for valid device ID...");
  //     return;
  //   }
  //   try {
  //     isLoading.value = true;
  //     isCacheLoading.value = true;
  //
  //     // Load cached playlists
  //     final cachedPlaylists = HiveService.getCachedPlaylists() ?? [];
  //     playlists.assignAll(cachedPlaylists.map((p) => {
  //       ...p,
  //       'isConnected': p['id'] == connectedPlaylistId.value,
  //     }));
  //     // Add debug prints right before Firebase call
  //     print('Fetching playlists for device: ${onboardingController.deviceId.value}');
  //     isCacheLoading.value = false;
  //
  //     // Load fresh playlists from Firebase
  //     final freshPlaylists = await _firebaseService.getPlaylists(onboardingController.deviceId.value);
  //     // Add debug print right after Firebase call
  //     print('Firebase returned ${freshPlaylists.length} playlists');
  //     print('Playlist IDs: ${freshPlaylists.map((p) => p['id']).toList()}');
  //     if (freshPlaylists.isNotEmpty) {
  //       // Find default playlist if it exists
  //       final defaultPlaylist = playlists.firstWhere(
  //             (p) => p['id'] == 'demo_001',
  //         orElse: () => <String, dynamic>{},
  //       );
  //
  //       // Merge playlists while preserving the default
  //       final mergedPlaylists = [
  //         if (defaultPlaylist.isNotEmpty) defaultPlaylist,
  //         ...freshPlaylists.where((p) => p['id'] != 'demo_001')
  //       ].map((p) => {
  //         ...p,
  //         'isConnected': p['id'] == connectedPlaylistId.value,
  //       }).toList();
  //
  //       playlists.assignAll(mergedPlaylists);
  //       await HiveService.cachePlaylists(mergedPlaylists);
  //     }
  //
  //     isLoading.value = false;
  //   } catch (e) {
  //     isLoading.value = false;
  //     isCacheLoading.value = false;
  //     Get.snackbar('Error', 'Failed to load playlists: ${e.toString()}');
  //   }
  // }

  void clearVodContent() {
    movies.clear();
    series.clear();
    resumeMovies.clear();
    selectedSeries.value = null;
    movies.refresh();
    series.refresh();
    resumeMovies.refresh();
  }

  Future<void> connectPlaylist(String playlistId) async {
    try {
      // ✅ Clear old VOD for previous playlist
      await HiveService.deleteVodContent(connectedPlaylistId.value);
      await HiveService.clearFavorites();
      clearVodContent(); // also clears in-memory observables

      playlists.forEach((p) => p['isConnected'] = p['id'] == playlistId);
      playlists.refresh();

      connectedPlaylistId.value = playlistId;
      await HiveService.cacheConnectedPlaylist(playlistId);
      await HiveService.cachePlaylists(playlists);

      final channels = await getChannels(playlistId);
      await HiveService.cacheChannels(playlistId, channels);

      final current = currentPlaylist;
      if (current?['type'] == 'xtream') {
        await loadVodContent(playlistId);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to connect playlist: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> disconnectPlaylist() async {
    try {
      playlists.forEach((p) => p['isConnected'] = false);
      playlists.refresh();

      connectedPlaylistId.value = '';
      await HiveService.clearConnectedPlaylist();

      Get.back(result: true);
      Get.snackbar('Success', 'Playlist disconnected', backgroundColor: Colors.orange);
    } catch (e) {
      Get.snackbar('Error', 'Failed to disconnect playlist: ${e.toString()}');
    }
  }

  Future<int> addM3UPlaylist(String name, String url) async {
    // 1. Validation (keep existing)
    if (name.isEmpty || url.isEmpty) throw 'Please fill all fields';
    if (!url.startsWith('http')) throw 'Invalid URL format';

    try {
      Get.dialog(const LoadingDialog(message: 'Adding playlist...'),
          barrierDismissible: false);

      // 2. Fetch and parse M3U (keep existing)
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw 'Failed to fetch M3U file (Status: ${response.statusCode})';

      final channels = await compute(parseM3UContent, response.body);
      if (channels.isEmpty) throw 'No valid channels found';

      // 3. Check for existing playlists with same URL
      final existingPlaylists = playlists.where((p) =>
      p['url'] == url || p['name'] == name).toList();

      if (existingPlaylists.isNotEmpty) {
        throw 'A playlist with this URL or name already exists';
      }

      // 4. Save ONLY to Firebase (no cache yet)
      await _firebaseService.savePlaylist(
        deviceId: onboardingController.deviceId.value,
        name: name,
        url: url,
        channels: channels.map((c) => {
          'name': c['name'] ?? '',
          'url': c['url'] ?? '',
          'category': c['category'] ?? 'Uncategorized',
        }).toList(),
      );

      // 5. Force fresh reload from Firebase
      await _refreshPlaylistsFromSource();

      // 6. UI Cleanup
      if (Get.isDialogOpen!) Get.back();
      Get.off(() => ChangePlaylist());

      Get.snackbar('Success', 'Added ${channels.length} channels',
          backgroundColor: Colors.green);
      return channels.length;

    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      rethrow;
    }
  }
  /// Fetches directly from Firebase and updates cache
  Future<void> _refreshPlaylistsFromSource() async {
    final fresh = await _firebaseService.getPlaylists(onboardingController.deviceId.value);
    playlists.assignAll(fresh);
    await HiveService.cachePlaylists(fresh); // Overwrite cache completely
  }

  Future<void> addXtreamPlaylist(String name, String baseUrl, String username, String password) async {
    if (name.isEmpty || baseUrl.isEmpty || username.isEmpty || password.isEmpty) {
      throw 'Please fill all fields';
    }

    try {
      Get.dialog(const LoadingDialog(message: 'Adding playlist...'), barrierDismissible: false);

      await _firebaseService.saveXtreamPlaylist(
        deviceId: onboardingController.deviceId.value,
        name: name,
        baseUrl: baseUrl,
        username: username,
        password: password,
      );

      await loadPlaylists();

      if (Get.isDialogOpen!) Get.back();
      await Future.delayed(const Duration(milliseconds: 200));
      Get.off(() => ChangePlaylist());

      Get.snackbar('Success', 'Xtream playlist added successfully', backgroundColor: Colors.green);
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      rethrow;
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    try {
      Get.dialog(const LoadingDialog(message: 'Deleting playlist...'),
          barrierDismissible: false);

      // Check if this is the currently connected playlist
      final isConnected = connectedPlaylistId.value == playlistId;

      // Delete from both Firebase and Hive
      await _firebaseService.deletePlaylist(
        onboardingController.deviceId.value,
        playlistId,
      );

      // Update local state
      playlists.removeWhere((p) => p['id'] == playlistId);

      // If this was the connected playlist, disconnect it
      if (isConnected) {
        connectedPlaylistId.value = '';
        await HiveService.clearConnectedPlaylist();
      }

      if (Get.isDialogOpen!) Get.back();
      Get.snackbar(
        'Success',
        'Playlist deleted permanently',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar(
        'Error',
        'Failed to delete playlist: ${e.toString()}',
        backgroundColor: Colors.red,
      );
      rethrow;
    }
  }

  Future<void> updatePlaylist(String playlistId, Map<String, dynamic> updatedData) async {
    try {
      Get.dialog(const LoadingDialog(message: 'Updating playlist...'), barrierDismissible: false);

      await _firebaseService.updatePlaylist(
        onboardingController.deviceId.value,
        playlistId,
        updatedData,
      );

      await loadPlaylists();

      if (Get.isDialogOpen!) Get.back();
      await Future.delayed(const Duration(milliseconds: 200));
      Get.off(() => ChangePlaylist());

      Get.snackbar('Success', 'Playlist updated successfully', backgroundColor: Colors.green);
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      Get.snackbar('Error', 'Failed to update playlist: ${e.toString()}', backgroundColor: Colors.red);
      rethrow;
    }
  }
  Future<void> loadXtreamChannels(String playlistId) async {
    try {
      isLoading.value = true;

      // Fetch from FirebaseService (handles cache + attachCategoryNames)
      final fetchedChannels = await _firebaseService.getChannels(playlistId, onboardingController.deviceId.value);

      if (fetchedChannels.isNotEmpty) {
        HiveService.cacheChannels(playlistId, fetchedChannels);
      }

      // Update local controller data
      channels.assignAll(fetchedChannels);
      // print("📺 Loaded ${fetchedChannels.length} channels for $playlistId");
    } catch (e) {
      print("❌ Failed to load channels: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Future<List<Map<String, dynamic>>> getChannels(String playlistId) async {
  //   try {
  //     final cachedChannels = HiveService.getCachedChannels(playlistId);
  //     if (cachedChannels != null && cachedChannels.isNotEmpty) {
  //       return cachedChannels;
  //     }
  //
  //     final channels = await _firebaseService.getChannels(
  //       playlistId,
  //       onboardingController.deviceId.value,
  //     );
  //     if (channels.isNotEmpty) {
  //       await HiveService.cacheChannels(playlistId, channels);
  //     }
  //     return channels;
  //   } catch (e) {
  //     Get.snackbar('Error', 'Failed to load channels: ${e.toString()}');
  //     return [];
  //   }
  // }
  Future<List<Map<String, dynamic>>> getChannels(String playlistId) async {
    try {
      // 1️⃣ Check Hive cache first
      final cached = HiveService.getCachedChannels(playlistId);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      // 2️⃣ Otherwise, get from Firebase (handles Xtream + attachCategoryNames internally)
      final channels = await _firebaseService.getChannels(
        playlistId,
        onboardingController.deviceId.value,
      );

      // 3️⃣ Cache locally for offline use
      if (channels.isNotEmpty) {
        await HiveService.cacheChannels(playlistId, channels);
      }

      return channels;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load channels: ${e.toString()}');
      return [];
    }
  }

}
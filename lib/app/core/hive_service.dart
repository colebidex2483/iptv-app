import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  // Box names
  static const String _playlistsBox = 'playlists';
  static const String _channelsBox = 'channels';
  static const String _moviesBox = 'movies';
  static const String _seriesBox = 'series';
  static const String _vodBox = 'vod_content'; // aggregated movies + series
  static const String _metadataBox = 'metadata';
  static const String _connectedBox = 'connected';
  static const String _settingsBox = 'settings';
  static const String _resumeBox = 'resume';
  static const String _favoritesBox = 'favorites';
  static const String _categoriesBox = 'categories';
  static const String _liveHistoryBox = 'live_history';
  static const String _liveFavoritesKey = 'live_favorites';
  static const String _liveRecentlyViewedKey = 'live_recently_viewed';

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_playlistsBox);
    await Hive.openBox(_channelsBox);
    await Hive.openBox(_moviesBox);
    await Hive.openBox(_seriesBox);
    await Hive.openBox(_vodBox);
    await Hive.openBox(_metadataBox);
    await Hive.openBox(_connectedBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_resumeBox);
    await Hive.openBox(_favoritesBox);
    await Hive.openBox(_categoriesBox);
  }

  // ---------------- VOD (aggregated movies + series) ---------------- //
  static Future<void> cacheVodContent(
      String playlistId,
      Map<String, dynamic> content,
      ) async {
    final box = Hive.box(_vodBox);
    await box.put(playlistId, {
      'movies': content['movies'],
      'series': content['series'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, dynamic>? getCachedVodContent(String playlistId) {
    final box = Hive.box(_vodBox);
    final data = box.get(playlistId);
    if (data == null) return null;

    return {
      'movies': (data['movies'] as List)
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList(),
      'series': (data['series'] as List)
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList(),
    };
  }

  static Future<void> clearFavorites() async {
    final box = Hive.box(_favoritesBox);
    await box.clear();
  }

  static Future<void> deleteVodContent(String playlistId) async {
    final box = Hive.box(_vodBox);
    await box.delete(playlistId);

    final moviesBox = Hive.box(_moviesBox);
    await moviesBox.delete(playlistId);

    final seriesBox = Hive.box(_seriesBox);
    await seriesBox.delete(playlistId);
  }


  static Future<void> saveLiveRecentlyViewed(String playlistId, List<Map<String, dynamic>> channels) async {
    final box = await Hive.openBox(_liveHistoryBox);
    await box.put('${_liveRecentlyViewedKey}_$playlistId', channels);
  }

  // static Future<List<Map<String, dynamic>>> getLiveRecentlyViewed() async {
  //   final box = await Hive.openBox(_liveHistoryBox);
  //   final data = box.get(_liveRecentlyViewedKey, defaultValue: []);
  //   return List<Map<String, dynamic>>.from((data ?? []).cast<Map>());
  // }
  static Future<List<Map<String, dynamic>>> getLiveRecentlyViewed(String playlistId) async {
    final box = await Hive.openBox(_liveHistoryBox);
    final rawList = box.get('${_liveRecentlyViewedKey}_$playlistId') ?? [];
    return (rawList as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> saveLiveFavorites(List<Map<String, dynamic>> favorites) async {
    final box = await Hive.openBox(_liveHistoryBox);
    await box.put(_liveFavoritesKey, favorites);
  }

  static Future<List<Map<String, dynamic>>> getLiveFavorites() async {
    final box = await Hive.openBox(_liveHistoryBox);
    final rawList = box.get(_liveFavoritesKey) ?? [];
    return (rawList as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ---------------- Movies ---------------- //
  static Future<void> cacheMovies(
      String playlistId,
      List<Map<String, dynamic>> movies,
      ) async {
    final box = Hive.box(_moviesBox);
    await box.put(playlistId, {
      'movies': movies,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>>? getCachedMovies(String playlistId) {
    final box = Hive.box(_moviesBox);
    final data = box.get(playlistId);
    if (data == null || data['movies'] == null) return null;

    return (data['movies'] as List)
        .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ---------------- Series ---------------- //
  static Future<void> cacheSeries(
      String playlistId,
      List<Map<String, dynamic>> series,
      ) async {
    final box = Hive.box(_seriesBox);
    await box.put(playlistId, {
      'series': series,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>>? getCachedSeries(String playlistId) {
    final box = Hive.box(_seriesBox);
    final data = box.get(playlistId);
    if (data == null || data['series'] == null) return null;

    return (data['series'] as List)
        .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // ---------------- Categories ---------------- //
  static Future<void> cacheCategories(
      String playlistId, {
        required List<Map<String, dynamic>> live,
        required List<Map<String, dynamic>> vod,
        required List<Map<String, dynamic>> series,
      }) async {
    final box = Hive.box(_categoriesBox);
    await box.put(playlistId, {
      'live': live,
      'vod': vod,
      'series': series,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, List<Map<String, dynamic>>>? getCachedCategories(
      String playlistId) {
    final box = Hive.box(_categoriesBox);
    final data = box.get(playlistId);
    if (data == null) return null;

    return {
      'live': (data['live'] as List)
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList(),
      'vod': (data['vod'] as List)
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList(),
      'series': (data['series'] as List)
          .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
          .toList(),
    };
  }

  static Future<void> deleteCategories(String playlistId) async {
    final box = Hive.box(_categoriesBox);
    await box.delete(playlistId);
  }

  // ---------------- Favorites ---------------- //
  static Future<void> saveFavoriteMovies(List<String> ids) async {
    final box = Hive.box(_favoritesBox);
    await box.put('favoriteMovies', ids);
  }

  static List<String> getFavoriteMovies() {
    final box = Hive.box(_favoritesBox);
    return List<String>.from(box.get('favoriteMovies', defaultValue: []));
  }

  static Future<void> saveFavoriteSeries(List<String> ids) async {
    final box = Hive.box(_favoritesBox);
    await box.put('favoriteSeries', ids);
  }

  static List<String> getFavoriteSeries() {
    final box = Hive.box(_favoritesBox);
    return List<String>.from(box.get('favoriteSeries', defaultValue: []));
  }

  /// Clear only movie favorites (preserve series favorites)
  static Future<void> clearFavoriteMovies() async {
    final box = Hive.box(_favoritesBox);
    // preserve existing series favorites
    final existingSeries = List<String>.from(box.get('favoriteSeries', defaultValue: []));
    await box.put('favoriteMovies', []);
    // ensure series favorites are still present
    await box.put('favoriteSeries', existingSeries);
  }

  // ---------------- Playlists ---------------- //
  static Future<void> cachePlaylists(
      List<Map<String, dynamic>> playlists) async {
    final box = Hive.box(_playlistsBox);
    await box.put('all', playlists);
  }

  static List<Map<String, dynamic>>? getCachedPlaylists() {
    final box = Hive.box(_playlistsBox);
    final rawList = box.get('all');
    if (rawList == null) return null;

    return (rawList as List)
        .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> deletePlaylist(String playlistId) async {
    final box = Hive.box(_playlistsBox);
    final current = box.get('all', defaultValue: []) as List;
    final updated = current.where((p) => p['id'] != playlistId).toList();
    await box.put('all', updated);
  }

  // ---------------- Channels ---------------- //
  static Future<void> cacheChannels(
      String playlistId,
      List<Map<String, dynamic>> channels,
      ) async {
    final box = Hive.box(_channelsBox);
    await box.put(playlistId, {
      'channels': channels,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static List<Map<String, dynamic>>? getCachedChannels(String playlistId) {
    final box = Hive.box(_channelsBox);
    final data = box.get(playlistId);
    if (data == null || data['channels'] == null) return null;

    return (data['channels'] as List)
        .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static Future<void> deleteChannels(String playlistId) async {
    final box = Hive.box(_channelsBox);
    await box.delete(playlistId);
  }

  // ---------------- Connected Playlist ---------------- //
  static Future<void> cacheConnectedPlaylist(String playlistId) async {
    final box = Hive.box(_connectedBox);
    await box.put('connected_id', playlistId);
  }

  static String? getConnectedPlaylistId() {
    final box = Hive.box(_connectedBox);
    return box.get('connected_id') as String?;
  }

  static Future<void> clearConnectedPlaylist() async {
    final box = Hive.box(_connectedBox);
    await box.delete('connected_id');
  }

  // ---------------- Metadata ---------------- //
  static Future<void> updateLastSyncTime() async {
    final box = Hive.box(_metadataBox);
    await box.put('lastSync', DateTime.now().toIso8601String());
  }

  static DateTime? getLastSyncTime() {
    final box = Hive.box(_metadataBox);
    final timeStr = box.get('lastSync') as String?;
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  // ---------------- Settings (Hidden Categories etc.) ---------------- //

  static List<dynamic>? getCachedItems(String playlistId, String type) {
    final box = Hive.box('playlists');
    final data = box.get(playlistId);
    if (data == null) return null;

    switch (type) {
      case 'live':
        return data['channels'];
      case 'vod':
        return data['movies'];
      case 'series':
        return data['series'];
      default:
        return null;
    }
  }


  /// 🟢 Live Categories - for HideLiveCategories dialog
  static List<String> getHiddenLiveCategories() {
    final box = Hive.box(_settingsBox);
    return List<String>.from(
      box.get('hiddenLiveCategories', defaultValue: []),
    );
  }

  static void saveHiddenLiveCategories(List<String> categories) {
    final box = Hive.box(_settingsBox);
    box.put('hiddenLiveCategories', categories);
  }

  /// 🟣 Series Categories - existing logic retained
  static List<String> getHiddenSeriesCategories() {
    final box = Hive.box(_settingsBox);
    return List<String>.from(
      box.get('hiddenSeriesCategories', defaultValue: []),
    );
  }

  static void saveHiddenSeriesCategories(List<String> categories) {
    final box = Hive.box(_settingsBox);
    box.put('hiddenSeriesCategories', categories);
  }

  /// 🟢 VOD (Movies) Categories - for HideVodeCategories dialog
  static List<String> getHiddenVodCategories() {
    final box = Hive.box(_settingsBox);
    return List<String>.from(
      box.get('hiddenVodCategories', defaultValue: []),
    );
  }

  static void saveHiddenVodCategories(List<String> categories) {
    final box = Hive.box(_settingsBox);
    box.put('hiddenVodCategories', categories);
  }

  // ---------------- Cache Management ---------------- //
  static Future<void> clearAllCache() async {
    await Hive.box(_playlistsBox).clear();
    await Hive.box(_channelsBox).clear();
    await Hive.box(_moviesBox).clear();
    await Hive.box(_seriesBox).clear();
    await Hive.box(_vodBox).clear();
    await Hive.box(_connectedBox).clear();
    await Hive.box(_metadataBox).clear();
    await Hive.box(_settingsBox).clear();
  }

  // ---------------- Resume Playback ---------------- //
  static Future<void> saveResumePoint({
    required String id,
    required int position,
    required int duration,
    required bool isSeries,
    String? episodeId,
  }) async {
    final box = Hive.box(_resumeBox);
    await box.put(id, {
      'id': id,
      'position': position,
      'duration': duration,
      'isSeries': isSeries,
      'episodeId': episodeId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  static Map<String, dynamic>? getResumePoint(String id) {
    final box = Hive.box(_resumeBox);
    final data = box.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static Future<void> deleteResumePoint(String id) async {
    final box = Hive.box(_resumeBox);
    await box.delete(id);
  }

  static List<Map<String, dynamic>> getAllResumePoints() {
    final box = Hive.box(_resumeBox);
    return box.values
        .map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  /// Delete resume entries that belong to movies (isSeries == false)
  static Future<void> clearMovieResumePoints() async {
    final box = Hive.box(_resumeBox);
    // iterate over keys to avoid concurrent modification issues
    final keys = box.keys.toList();
    for (final k in keys) {
      final data = box.get(k);
      if (data is Map) {
        final isSeries = data['isSeries'];
        // Accept both bool and string stored values
        if (isSeries == false || isSeries == 'false' || isSeries == 0) {
          await box.delete(k);
        }
      }
    }
  }

  /// Clear all movie-related persisted data:
  ///  - delete cached VOD/movies for the playlist (if playlistId provided)
  ///  - clear saved favorite movies (keep series favorites)
  ///  - clear resume points that belong to movies
  static Future<void> clearMovieHistory({String? playlistId}) async {
    // delete cached VOD for the given playlist (if provided)
    if (playlistId != null && playlistId.isNotEmpty) {
      try {
        await deleteVodContent(playlistId);
      } catch (_) {
        // proceed even if some deletes fail
      }
    }

    // clear saved favorite movies (preserve series favorites)
    await clearFavoriteMovies();

    // remove resume points that belong to movies
    await clearMovieResumePoints();
  }
}

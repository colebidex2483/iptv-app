import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ibo_clone/app/core/hive_service.dart';
import 'logger.dart';
import 'package:http/http.dart' as http;


enum ContentType { live, vod, series }
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyC0180LTF7UDY6NxdtI60wkhT7vaOdoBkY",
          authDomain: "streamingadminapp.firebaseapp.com",
          projectId: "streamingadminapp",
          storageBucket: "streamingadminapp.firebasestorage.app",
          messagingSenderId: "107075718469",
          appId: "1:107075718469:web:d42da8af62a0041704022c",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  Map<String, String> _xtreamHeaders = {};

  Future<void> loginXtream(String baseUrl, String username, String password) async {
    final loginUrl = Uri.parse(
      '$baseUrl/player_api.php?username=$username&password=$password',
    );

    final response = await http.get(loginUrl);

    if (response.statusCode == 200) {
      // Capture cookies
      final cookies = response.headers['set-cookie'];
      final headers = <String, String>{
        'User-Agent': 'Perfect Player',
      };

      if (cookies != null) {
        headers['Cookie'] = cookies;
      }

      // Some servers need Basic Auth instead
      final basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
      headers['Authorization'] = basicAuth;

      _xtreamHeaders = headers;
    } else {
      throw Exception("Xtream login failed: ${response.statusCode}");
    }
  }

  Map<String, String> getXtreamHeaders() => _xtreamHeaders;

  Future<DocumentSnapshot?> getActivationCode(String code) async {
    try {
      final snapshot = await _firestore.collection('activationCodes').doc(code).get();
      if (snapshot.exists) return snapshot;
      return null;
    } catch (e) {
      log.e('Error fetching activation code: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getActivationByDeviceId(String deviceId) async {
    try {
      final query = await _firestore
          .collection('activationCodes')
          .where('deviceId', isEqualTo: deviceId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        // print('📦 Document Data: ${doc.data()}');
        return doc.data();
      } else {
        print('⚠️ No document found for deviceId: $deviceId');
        return null;
      }
    } catch (e) {
      log.e('Error fetching by deviceId: $e');
      return null;
    }
  }

  Future<void> markCodeAsUsed(String code, String deviceId) async {
    try {
      await _firestore.collection('activationCodes').doc(code).update({
        'isUsed': true,
        'usedAt': Timestamp.now(),
        'documentId.deviceId': deviceId,
      });
    } catch (e) {
      log.e('Failed to update activation code: $e');
    }
  }

  Future<void> createPendingActivation(String deviceId) async {
    try {
      await _firestore.collection('activationCodes').add({
        'isActivated': false,
        'createdAt': Timestamp.now(),
        'deviceInfo': {
          'deviceId': deviceId,
          'platform': kIsWeb ? 'web' : 'mobile',
        },
      });
    } catch (e) {
      log.e('Error creating pending activation: $e');
    }
  }

  Future<void> updateTrialDaysLeft({required String deviceId,required int daysLeft, required bool isTrialActive,}) async {
    final docRef = _firestore.collection('devices').doc(deviceId);
    await docRef.set({
      'daysLeft': daysLeft,
      'isTrialActive': isTrialActive,
      'lastUpdated': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> updateTrialStatus({required String deviceId,required bool isTrialActive,required int daysLeft,}) async {
    try {
      await _firestore.collection('activationCodes').doc(deviceId).set({
        'daysLeft': daysLeft,
        'isTrialActive': isTrialActive,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating trial status: $e, $deviceId');
    }
  }

  Future<void> logDeviceInfo({required String deviceId,required String deviceKey,required bool isTrialActive,required int daysLeft,required DateTime trialStartDate,}) async {
    try {
      await _firestore
          .collection('activationCodes')
          .doc(deviceId)
          .set({
        'deviceId': deviceId,
        'deviceKey': deviceKey,
        'isTrialActive': isTrialActive,
        'daysLeft': daysLeft,
        'timestamp': Timestamp.now(),
        'trialStartDate': trialStartDate.toIso8601String(),
        'platform': kIsWeb ? 'web' : 'mobile',
        'isActivated': false,
        'plan': null,
      }, SetOptions(merge: true));

      log.i('Device info logged with deviceId as doc ID');
    } catch (e) {
      log.e(' Failed to log device info: $e');
    }
  }

  Future<User?> signInAnon() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      log.e('Anonymous sign-in failed: $e');
      return null;
    }
  }


  // Future<void> savePlaylist({required String deviceId, required String name, required String url, required List<Map<String, String>> channels,}) async {
  //   try {
  //     final playlistRef = _firestore.collection('devices').doc(deviceId).collection('playlists').doc();
  //     final playlistId = playlistRef.id;
  //
  //     final metadata = {
  //       'type': 'm3u',
  //       'name': name,
  //       'url': url,
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'channelCount': channels.length,
  //       'id': playlistId,
  //       'lastUpdated': DateTime.now().toIso8601String(),
  //     };
  //
  //     await playlistRef.set(metadata);
  //     final List<Map<String, dynamic>> channelsToCache = channels.map((channel) {
  //       return {
  //         'name': channel['name'] ?? '',
  //         'url': channel['url'] ?? '',
  //         'category': channel['category'] ?? 'Uncategorized',
  //       };
  //     }).toList();
  //
  //     await HiveService.cacheChannels(playlistId, channelsToCache);
  //     await _updatePlaylistCache(deviceId, playlistId);
  //
  //     log.i('✅ Scoped M3U Playlist saved with ${channels.length} channels');
  //   } catch (e) {
  //     log.e('❌ Failed to save scoped M3U Playlist: $e');
  //     rethrow;
  //   }
  // }

// ---------------- SAVE PLAYLISTS ---------------- //
  Future<void> savePlaylist({required String deviceId, required String name, required String url, required List<Map<String, String>> channels,}) async {
    try {
      final playlistRef = _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('playlists')
          .doc();
      final playlistId = playlistRef.id;

      // Extract category names dynamically from M3U channels
      final Set<String> categoriesSet = channels
          .map((c) => c['category'] ?? 'Uncategorized')
          .toSet();

      final List<Map<String, dynamic>> liveCats = categoriesSet.map((name) {
        return {
          'id': name.hashCode.toString(),
          'name': name,
        };
      }).toList();

      final metadata = {
        'type': 'm3u',
        'name': name,
        'url': url,
        'createdAt': DateTime.now().toIso8601String(),
        'channelCount': channels.length,
        'id': playlistId,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await playlistRef.set(metadata);

      // Cache channels
      final List<Map<String, dynamic>> channelsToCache = channels.map((channel) {
        return {
          'name': channel['name'] ?? '',
          'url': channel['url'] ?? '',
          'category': channel['category'] ?? 'Uncategorized',
        };
      }).toList();

      await HiveService.cacheChannels(playlistId, channelsToCache);

      // ✅ Cache categories so getCachedCategories() will work like Xtream
      await HiveService.cacheCategories(
        playlistId,
        live: liveCats,
        vod: [],
        series: [],
      );

      await _updatePlaylistCache(deviceId, playlistId);

      log.i('✅ M3U Playlist saved with ${channels.length} channels and ${liveCats.length} categories');
    } catch (e) {
      log.e('❌ Failed to save M3U Playlist: $e');
      rethrow;
    }
  }

  Future<void> saveXtreamPlaylist({required String deviceId, required String name, required String baseUrl, required String username, required String password,}) async {
    try {
      final playlistRef = _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('playlists')
          .doc();
      final playlistId = playlistRef.id;

      // 🔹 Fetch all content
      final live = await _fetchXtreamChannels(baseUrl, username, password);
      final vod = await _fetchXtreamVodContent(baseUrl, username, password);

      // 🔹 Fetch categories
      final liveCats = await fetchXtreamLiveCategories(baseUrl, username, password);
      final vodCats = await fetchXtreamVodCategories(baseUrl, username, password);
      final seriesCats = await fetchXtreamSeriesCategories(baseUrl, username, password);

      if (live.isEmpty && vod['movies']!.isEmpty && vod['series']!.isEmpty) {
        throw Exception('No Xtream content found. Playlist cannot be saved.');
      }

      final metadata = {
        'type': 'xtream',
        'name': name,
        'baseUrl': baseUrl,
        'username': username,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
        'liveCount': live.length,
        'movieCount': vod['movies']!.length,
        'seriesCount': vod['series']!.length,
        'id': playlistId,
        'lastUpdated': DateTime.now().toIso8601String(),
        'categories': {
          'live': liveCats,
          'vod': vodCats,
          'series': seriesCats,
        }
      };

      await playlistRef.set(metadata);

      // 🔹 Cache everything
      await HiveService.cacheChannels(playlistId, live);
      await HiveService.cacheMovies(playlistId, vod['movies']!);
      await HiveService.cacheSeries(playlistId, vod['series']!);
      await HiveService.cacheCategories(playlistId, live: liveCats, vod: vodCats, series: seriesCats,
      );

      await _updatePlaylistCache(deviceId, playlistId);

      log.i('✅ Xtream Playlist saved '
          '[${live.length} live, ${vod['movies']!.length} movies, ${vod['series']!.length} series | '
          '${liveCats.length} liveCats, ${vodCats.length} vodCats, ${seriesCats.length} seriesCats]');
    } catch (e) {
      log.e('❌ Failed to save Xtream Playlist: $e');
      rethrow;
    }
  }

  // ---------------- FETCH HELPERS ---------------- //

  Future<List<Map<String, dynamic>>> _fetchXtreamChannels(String baseUrl, String username, String password) async {
    try {
      final url = Uri.parse(
          '${_normalizeUrl(baseUrl)}/player_api.php?username=$username&password=$password&action=get_live_streams');

      final res = await http.get(url);
      if (res.statusCode != 200) throw 'Live fetch failed';

      final data = jsonDecode(res.body);
      if (data is! List) throw 'Invalid live format';

      return data.map<Map<String, dynamic>>((item) {
        return {
          'id': item['stream_id'],
          'name': item['name'] ?? 'Unknown',
          'category': item['category_id'] ?? '',
          'url':
          '${_normalizeUrl(baseUrl)}/live/$username/$password/${item['stream_id']}.ts',
          'type': 'live',
        };
      }).toList();
    } catch (e) {
      log.e('❌ Failed to fetch Xtream live: $e');
      return [];
    }
  }

  // Future<Map<String, List<Map<String, dynamic>>>> getVodContent(String playlistId, {required String deviceId,}) async {
  //   try {
  //     final playlistDoc = await _firestore
  //         .collection('devices')
  //         .doc(deviceId)
  //         .collection('playlists')
  //         .doc(playlistId)
  //         .get();
  //
  //     final playlistData = playlistDoc.data();
  //     if (playlistData == null) throw 'Playlist not found';
  //
  //     if (playlistData['type'] == 'xtream') {
  //       return await _fetchXtreamVodContent(
  //         playlistData['baseUrl'],
  //         playlistData['username'],
  //         playlistData['password'],
  //       );
  //     }
  //
  //     return {'movies': [], 'series': []};
  //   } catch (e) {
  //     log.e('Failed to get VOD content: $e');
  //     return {'movies': [], 'series': []};
  //   }
  // }
  Future<Map<String, List<Map<String, dynamic>>>> getVodContent(String playlistId, {required String deviceId,}) async {
    // 1. Try Hive cache first
    final cached = HiveService.getCachedVodContent(playlistId);
    if (cached != null) {
      return {
        "movies": await _attachCategoryNames(
          cached["movies"] ?? [],
          ContentType.vod,
          playlistId,
        ),
        "series": await _attachCategoryNames(
          cached["series"] ?? [],
          ContentType.series,
          playlistId,
        ),
      };
    }

    // 2. Otherwise get credentials from Firestore
    final playlistDoc = await _firestore
        .collection('devices')
        .doc(deviceId)
        .collection('playlists')
        .doc(playlistId)
        .get();
    final data = playlistDoc.data();
    if (data == null) return {"movies": [], "series": []};

    // 3. Fetch Xtream VOD content
    final vod = await _fetchXtreamVodContent(
      data['baseUrl'],
      data['username'],
      data['password'],
    );

    // 4. Attach category names
    final movies = await _attachCategoryNames(
      vod['movies'] ?? [],
      ContentType.vod,
      playlistId,
    );
    final series = await _attachCategoryNames(
      vod['series'] ?? [],
      ContentType.series,
      playlistId,
    );

    // 5. Cache to Hive
    await HiveService.cacheVodContent(playlistId, {
      "movies": movies,
      "series": series,
    });
    // 6. Return
    return {
      "movies": movies,
      "series": series,
    };
  }

  // Future<Map<String, List<Map<String, dynamic>>>> _fetchXtreamVodContent(String baseUrl, String username, String password) async {
  //   try {
  //     final formatted = _normalizeUrl(baseUrl);
  //
  //     // Movies
  //     final moviesUrl = Uri.parse(
  //         '$formatted/player_api.php?username=$username&password=$password&action=get_vod_streams');
  //     final moviesRes = await http.get(moviesUrl);
  //
  //     // Series
  //     final seriesUrl = Uri.parse(
  //         '$formatted/player_api.php?username=$username&password=$password&action=get_series');
  //     final seriesRes = await http.get(seriesUrl);
  //
  //     if (moviesRes.statusCode != 200 || seriesRes.statusCode != 200) {
  //       throw 'Failed to fetch VOD';
  //     }
  //
  //     final moviesData = jsonDecode(moviesRes.body);
  //     final seriesData = jsonDecode(seriesRes.body);
  //
  //     return {
  //       'movies': _parseXtreamMovies(moviesData, formatted, username, password),
  //       'series': _parseXtreamSeries(seriesData),
  //     };
  //   } catch (e) {
  //     log.e('❌ Failed to fetch VOD: $e');
  //     return {'movies': [], 'series': []};
  //   }
  // }

  Future<Map<String, List<Map<String, dynamic>>>> _fetchXtreamVodContent(String baseUrl, String username, String password,) async {
    final formatted = _normalizeUrl(baseUrl);

    try {
      // Construct both URLs
      final moviesUrl = Uri.parse(
        '$formatted/player_api.php?username=$username&password=$password&action=get_vod_streams',
      );
      final seriesUrl = Uri.parse(
        '$formatted/player_api.php?username=$username&password=$password&action=get_series',
      );

      // Fetch both in parallel for performance
      final responses = await Future.wait([
        http.get(moviesUrl),
        http.get(seriesUrl),
      ]);

      final moviesRes = responses[0];
      final seriesRes = responses[1];

      if (moviesRes.statusCode != 200) {
        throw Exception('VOD Movies request failed (${moviesRes.statusCode})');
      }
      if (seriesRes.statusCode != 200) {
        throw Exception('VOD Series request failed (${seriesRes.statusCode})');
      }

      // Decode safely
      final moviesData = _safeJsonDecode(moviesRes.body);
      final seriesData = _safeJsonDecode(seriesRes.body);

      // Validate decoded data
      if (moviesData is! List || seriesData is! List) {
        throw Exception('Invalid VOD response format');
      }

      // Parse with your helpers
      final movies = _parseXtreamMovies(
        moviesData,
        formatted,
        username,
        password,
      );
      final series = _parseXtreamSeries(seriesData);
      log.i('✅ VOD fetched successfully → Movies: ${movies.length}, Series: ${series.length}');
      return {'movies': movies, 'series': series};
    } catch (e, stack) {
      log.e('❌ Failed to fetch Xtream VOD content: $e', stackTrace: stack);
      return {'movies': [], 'series': []};
    }
  }

  /// Safe JSON decode helper
  dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> _parseXtreamMovies(dynamic data, String baseUrl, String username, String password) {
    if (data is! List) return [];
    return data.map<Map<String, dynamic>>((item) {
      return {
        'id': item['stream_id'],
        'name': item['name'] ?? 'Unknown Movie',
        'cover': item['stream_icon'] ?? '',
        'year': item['year'] ?? '',
        'category_id': item['category_id'] ?? '',
        'rating': item['rating'] ?? '',
        'url':
        '$baseUrl/movie/$username/$password/${item['stream_id']}.${item['container_extension'] ?? 'ts'}',
        'type': 'movie',
      };
    }).toList();
  }

  List<Map<String, dynamic>> _parseXtreamSeries(dynamic data) {
    if (data is! List) return [];
    return data.map<Map<String, dynamic>>((item) {
      return {
        'id': item['series_id'],
        'name': item['name'] ?? 'Unknown Series',
        'cover': item['cover'] ?? '',
        'year': item['year'] ?? '',
        'category_id': item['category_id'] ?? '',
        'rating': item['rating'] ?? '',
        'seasons': (item['seasons'] as List?)?.length ?? 0,
        'type': 'series',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchXtreamLiveCategories(String baseUrl, String username, String password) async {
    try {
      final url = Uri.parse(
        '${_normalizeUrl(baseUrl)}/player_api.php?username=$username&password=$password&action=get_live_categories',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) throw 'Failed to fetch live categories';

      final data = jsonDecode(res.body);
      if (data is! List) return [];

      return data.map<Map<String, dynamic>>((cat) {
        return {
          'id': cat['category_id'],
          'name': cat['category_name'] ?? 'Unknown',
          'parent_id': cat['parent_id'] ?? '0',
        };
      }).toList();
    } catch (e) {
      log.e('❌ Failed to fetch live categories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchXtreamVodCategories(String baseUrl, String username, String password) async {
    try {
      final url = Uri.parse(
        '${_normalizeUrl(baseUrl)}/player_api.php?username=$username&password=$password&action=get_vod_categories',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) throw 'Failed to fetch vod categories';

      final data = jsonDecode(res.body);
      if (data is! List) return [];

      return data.map<Map<String, dynamic>>((cat) {
        return {
          'id': cat['category_id'],
          'name': cat['category_name'] ?? 'Unknown',
          'parent_id': cat['parent_id'] ?? '0',
        };
      }).toList();
    } catch (e) {
      log.e('❌ Failed to fetch vod categories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchXtreamSeriesCategories(String baseUrl, String username, String password) async {
    try {
      final url = Uri.parse(
        '${_normalizeUrl(baseUrl)}/player_api.php?username=$username&password=$password&action=get_series_categories',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) throw 'Failed to fetch series categories';

      final data = jsonDecode(res.body);
      if (data is! List) return [];

      return data.map<Map<String, dynamic>>((cat) {
        return {
          'id': cat['category_id'],
          'name': cat['category_name'] ?? 'Unknown',
          'parent_id': cat['parent_id'] ?? '0',
        };
      }).toList();
    } catch (e) {
      log.e('❌ Failed to fetch series categories: $e');
      return [];
    }
  }

  /// Returns a map of categories: { 'live': [...], 'vod': [...], 'series': [...] }
  Future<Map<String, List<Map<String, dynamic>>>> getCategories(String playlistId, String deviceId,) async {
    try {
      // 1. Try Hive cache
      final cached = HiveService.getCachedCategories(playlistId);
      if (cached != null &&
          (cached['live']?.isNotEmpty == true ||
              cached['vod']?.isNotEmpty == true ||
              cached['series']?.isNotEmpty == true)) {
        return cached;
      }

      // 2. Fetch from Firestore
      final playlistDoc = await _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('playlists')
          .doc(playlistId)
          .get();

      final data = playlistDoc.data();
      if (data == null) return {};

      if ((data['type'] ?? '').toString() != 'xtream') return {};

      final baseUrl = (data['baseUrl'] ?? data['host'] ?? '').toString();
      final username = (data['username'] ?? '').toString();
      final password = (data['password'] ?? '').toString();

      // 3. Fetch categories from Xtream API
      final liveCats   = await fetchXtreamLiveCategories(baseUrl, username, password);
      final vodCats    = await fetchXtreamVodCategories(baseUrl, username, password);
      final seriesCats = await fetchXtreamSeriesCategories(baseUrl, username, password);

      // 4. Save in Hive
      await HiveService.cacheCategories(
        playlistId,
        live: liveCats,
        vod: vodCats,
        series: seriesCats,
      );

      // 5. Save in Firestore (optional, non-fatal)
      await playlistDoc.reference.set({
        'categories': {
          'live': liveCats,
          'vod': vodCats,
          'series': seriesCats,
        }
      }, SetOptions(merge: true));

      return { 'live': liveCats, 'vod': vodCats, 'series': seriesCats };
    } catch (e) {
      log.e('❌ getCategories failed: $e');
      return {};
    }
  }

  /// Attach human-readable category_name to items
  List<Map<String, dynamic>> _attachCategoryNames(List<Map<String, dynamic>> items, ContentType type, String playlistId,) {
    final cached = HiveService.getCachedCategories(playlistId);
    final categories = cached?[type.name] ?? [];

    return items.map((item) {
      // Use category_id or category depending on what exists
      final id = (item['category_id'] ?? item['category'])?.toString();

      final match = categories.firstWhere(
            (cat) => cat['id'].toString() == id,
        orElse: () => {'id': '-1', 'name': 'Uncategorized'},
      );

      return {
        ...item,
        'category_name': match['name'] ?? 'Uncategorized',
      };
    }).toList();
  }


  Future<List<Map<String, dynamic>>> getChannels(String playlistId, String deviceId) async {
    // 1. Try Hive cache first
    final cached = HiveService.getCachedChannels(playlistId);
    if (cached != null && cached.isNotEmpty) {
      return _attachCategoryNames(cached, ContentType.live, playlistId);
    }

    // 2. Otherwise fetch Xtream data
    final playlistDoc = await _firestore
        .collection('devices')
        .doc(deviceId)
        .collection('playlists')
        .doc(playlistId)
        .get();
    final data = playlistDoc.data();
    if (data == null) return [];

    final channels = await _fetchXtreamChannels(
        data['baseUrl'], data['username'], data['password']);

    return _attachCategoryNames(channels, ContentType.live, playlistId);
  }


  // Future<List<Map<String, dynamic>>> getMovies(String playlistId, String deviceId) async {
  //   final cached = HiveService.getCachedMovies(playlistId);
  //   if (cached != null && cached.isNotEmpty) return cached;
  //
  //   final playlistDoc = await _firestore
  //       .collection('devices')
  //       .doc(deviceId)
  //       .collection('playlists')
  //       .doc(playlistId)
  //       .get();
  //   final data = playlistDoc.data();
  //   if (data == null) return [];
  //
  //   final vod =
  //   await _fetchXtreamVodContent(data['baseUrl'], data['username'], data['password']);
  //   return vod['movies'] ?? [];
  // }
  //
  // Future<List<Map<String, dynamic>>> getSeries(String playlistId, String deviceId) async {
  //   final cached = HiveService.getCachedSeries(playlistId);
  //   if (cached != null && cached.isNotEmpty) return cached;
  //
  //   final playlistDoc = await _firestore
  //       .collection('devices')
  //       .doc(deviceId)
  //       .collection('playlists')
  //       .doc(playlistId)
  //       .get();
  //   final data = playlistDoc.data();
  //   if (data == null) return [];
  //
  //   final vod =
  //   await _fetchXtreamVodContent(data['baseUrl'], data['username'], data['password']);
  //   return vod['series'] ?? [];
  // }

  // ---------------- HELPERS ---------------- //

  String _normalizeUrl(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  Future<void> _updatePlaylistCache(String deviceId, String playlistId) async {
    final doc = await _firestore
        .collection('devices')
        .doc(deviceId)
        .collection('playlists')
        .doc(playlistId)
        .get();
    final data = doc.data();
    if (data == null) return;

    final current = HiveService.getCachedPlaylists() ?? [];
    final index = current.indexWhere((p) => p['id'] == playlistId);

    if (index >= 0) {
      current[index] = data..['id'] = playlistId;
    } else {
      current.add(data..['id'] = playlistId);
    }

    await HiveService.cachePlaylists(current);
  }

  Future<List<Map<String, dynamic>>> getPlaylists(String deviceId) async {
    try {
      final cachedPlaylists = HiveService.getCachedPlaylists();
      final lastSync = HiveService.getLastSyncTime();

      if (cachedPlaylists != null &&
          lastSync != null &&
          DateTime.now().difference(lastSync).inHours < 1) {
        return cachedPlaylists;
      }

      final snapshot = await _firestore.collection('devices').doc(deviceId).collection('playlists').get();
      final playlists = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      await HiveService.cachePlaylists(playlists);
      await HiveService.updateLastSyncTime();

      return playlists;
    } catch (e) {
      log.e('❌ Failed to fetch scoped playlists: $e');
      final cached = HiveService.getCachedPlaylists();
      return cached ?? [];
    }
  }

  Future<void> deletePlaylist(String deviceId, String playlistId) async {
    try {
      // Delete from Firebase first
      await _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('playlists')
          .doc(playlistId)
          .delete();

      // Then delete from Hive
      await HiveService.deletePlaylist(playlistId);
      await HiveService.deleteChannels(playlistId);

      log.i('✅ Playlist permanently deleted from Firebase and Hive');
    } catch (e) {
      log.e('❌ Failed to delete playlist: $e');
      rethrow;
    }
  }


  /// ✅ Fetch detailed Xtream movie info
  // Future<Map<String, dynamic>?> getSeriesDetails({required String host, required String username, required String password, required String seriesId, required String deviceId, required String playlistId,}) async {
  //   try {
  //     final url = Uri.parse(
  //       "$host/player_api.php?username=$username&password=$password&action=get_series_info&series_id=$seriesId",
  //     );
  //
  //     log.i("Fetching series details: $url");
  //
  //     final response = await http.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //
  //       // Save into Firestore for caching
  //       final seriesRef = _firestore
  //           .collection("devices")
  //           .doc(deviceId)
  //           .collection("playlists")
  //           .doc(playlistId)
  //           .collection("series_details")
  //           .doc(seriesId);
  //
  //       await seriesRef.set(data, SetOptions(merge: true));
  //
  //       log.i("Series details saved for ID $seriesId");
  //
  //       return Map<String, dynamic>.from(data);
  //     } else {
  //       log.e("Failed to fetch series details: ${response.statusCode}");
  //       return null;
  //     }
  //   } catch (e) {
  //     log.e("Error fetching series details: $e");
  //     return null;
  //   }
  // }
  Future<Map<String, dynamic>> fetchXtreamMovieInfo({required String baseUrl, required String username, required String password, required String vodId,}) async {
    try {

      final url = Uri.parse(
        "$baseUrl/player_api.php?username=$username&password=$password&action=get_vod_info&vod_id=$vodId",
      );
      // print(url);
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        final info = data['info'] ?? {};
        final movieData = data['movie_data'] ?? {};

        // Xtream stream URL format
        final streamId = movieData['stream_id'];
        final container = movieData['container_extension'] ?? 'mp4';
        final streamUrl = "$baseUrl/movie/$username/$password/$streamId.$container";

        // Handle backdrop_path flexibly
        String backdrop = '';
        if (info['backdrop_path'] is List && info['backdrop_path'].isNotEmpty) {
          backdrop = info['backdrop_path'][0];
        } else if (info['backdrop_path'] is String) {
          backdrop = info['backdrop_path'];
        }

        return {
          'id': vodId,
          'name': info['name'] ?? '',
          'description': info['plot'] ?? '',
          'cover': info['movie_image'] ?? '',
          'year': info['releasedate'] ?? '',
          'rating': info['rating']?.toString() ?? '',
          'duration': info['duration'] ?? '',
          'genre': info['genre'] ?? '',
          'actors': info['actors'] ?? '',
          'director': info['director'] ?? '',
          'backdrop': backdrop,
          'url': streamUrl,
        };
      } else {
        log.e('Failed to fetch movie info: ${res.body}');
        return {};
      }
    } catch (e, st) {
      log.e('Error fetching movie info $e\n$st');
      return {};
    }
  }


  Future<Map<String, dynamic>?> getSeriesDetails({required String host, required String username, required String password, required String seriesId, required String deviceId, required String playlistId,}) async {
    try {
      // Normalize the host URL
      var normalizedHost = host;
      if (normalizedHost.endsWith('/')) {
        normalizedHost = normalizedHost.substring(0, normalizedHost.length - 1);
      }

      final url = Uri.parse(
        "$normalizedHost/player_api.php?username=$username&password=$password&action=get_series_info&series_id=$seriesId",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Explicitly cast to Map<String, dynamic>
        final seriesData = Map<String, dynamic>.from(data);

        // Save into Firestore for caching
        final seriesRef = _firestore
            .collection("devices")
            .doc(deviceId)
            .collection("playlists")
            .doc(playlistId)
            .collection("series_details")
            .doc(seriesId);

        await seriesRef.set(seriesData, SetOptions(merge: true));

        log.i("Series details saved for ID $seriesId");
        return seriesData;
      } else {
        log.e("Failed to fetch series details: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log.e("Error fetching series details: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> fetchXtreamSeriesInfo({required String baseUrl, required String username, required String password, required String seriesId,}) async {
    try {
      final url = Uri.parse(
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_series_info&series_id=$seriesId',
      );

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);

        final info = data['info'] ?? {};
        final episodes = (data['episodes'] as Map?) ?? {};
        return {
          'id': seriesId,
          'name': info['name'] ?? '',
          'description': info['plot'] ?? '',
          'cover': info['cover'] ?? info['series_image'] ?? '',
          'year': info['releaseDate'] ?? '',
          'trailer': info['youtube_trailer'] ?? '',
          'rating': info['rating']?.toString() ?? '',
          'seasons': episodes.isNotEmpty ? episodes.keys.length : 0,
          'episodes': episodes, // still pass the full map
        };
      } else {
        log.e('❌ Failed to fetch series info: ${res.body}');
        return {};
      }
    } catch (e) {
      log.e('❌ Error fetching series info $e');
      return {};
    }
  }

  Future<void> updatePlaylist(String deviceId, String playlistId, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = DateTime.now().toIso8601String();
      await _firestore.collection('devices').doc(deviceId).collection('playlists').doc(playlistId).update(updates);
      await _updatePlaylistCache(deviceId, playlistId);
      log.i('✅ Scoped playlist updated');
    } catch (e) {
      log.e('❌ Failed to update scoped playlist: $e');
      rethrow;
    }
  }

  Future<void> ensureDeviceDocumentExists(String deviceId) async {
    // Add memoization to prevent duplicate checks
    if (_deviceDocumentExistsCache.contains(deviceId)) {
      return;
    }

    final docRef = _firestore.collection('devices').doc(deviceId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({});
      log.i('🆕 Created device document for $deviceId');
    } else {
      log.i('✅ Device document already exists for $deviceId');
    }

    _deviceDocumentExistsCache.add(deviceId);
  }

// Add this at class level
  final _deviceDocumentExistsCache = <String>{};
}
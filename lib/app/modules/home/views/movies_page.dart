import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/playlists/controllers/playlists_controller.dart';
import 'package:ibo_clone/app/modules/search/view/search_page.dart';
import 'package:ibo_clone/app/widgets/movie_details_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../../core/hive_service.dart';

class MoviesPage extends StatefulWidget {
  final String? searchQuery;
  const MoviesPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final PlaylistController playlistController = Get.find();

  String _selectedOrder = "order_by_added".tr; // keep internal key English
  String _selectedCategory = "all".tr;
  final List<String> _orderOptions = [
    "order_by_added".tr,
    "order_by_a_z".tr,
    "order_by_z_a".tr,
    "order_by_year".tr,
    "order_by_rating".tr,
  ];

  Color _getRatingColor(double rating) {
    if (rating >= 7.0) return Colors.green;
    if (rating >= 5.0) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (playlistController.connectedPlaylistId.value.isNotEmpty) {
        playlistController
            .loadVodContent(playlistController.connectedPlaylistId.value);
      }
    });
  }

  List<Map<String, dynamic>> getFilteredMovies() {
    final allMovies = playlistController.movies;
    List<Map<String, dynamic>> filtered;

    if (_selectedCategory == "all".tr) {
      filtered = List<Map<String, dynamic>>.from(allMovies);
    } else if (_selectedCategory == "resume_to_watch".tr) {
      filtered = List<Map<String, dynamic>>.from(playlistController.resumeMovies);
    } else if (_selectedCategory == "favorites".tr) {
      filtered = allMovies
          .where((movie) => playlistController.isFavorite(
        movie['id']?.toString(),
        isSeries: false,
      ))
          .toList();
    } else {
      filtered = allMovies
          .where((s) => s['category_name'] == _selectedCategory)
          .toList();
    }

    final query = (widget.searchQuery ?? '').toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((movie) =>
          (movie['name'] ?? '').toString().toLowerCase().contains(query))
          .toList();
    }

    switch (_selectedOrder) {
      case var val when val == "order_by_a_z".tr:
        filtered.sort((a, b) =>
            (a['name'] ?? '').toString().compareTo((b['name'] ?? '').toString()));
        break;
      case var val when val == "order_by_z_a".tr:
        filtered.sort((a, b) =>
            (b['name'] ?? '').toString().compareTo((a['name'] ?? '').toString()));
        break;
      case var val when val == "order_by_year".tr:
        filtered.sort((a, b) =>
            (int.tryParse(b['year']?.toString() ?? '0') ?? 0)
                .compareTo(int.tryParse(a['year']?.toString() ?? '0') ?? 0));
        break;
      case var val when val == "order_by_rating".tr:
        filtered.sort((a, b) =>
            (double.tryParse(b['rating']?.toString() ?? '0') ?? 0)
                .compareTo(double.tryParse(a['rating']?.toString() ?? '0') ?? 0));
        break;
      default:
        break;
    }

    return filtered;
  }

  Widget _buildCategoryBox({
    required String label,
    int count = 0,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.yellow : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.yellow : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.yellow.withOpacity(0.2)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.yellow : Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.7,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[600]!,
                    child: Container(color: Colors.grey[850]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16, color: Colors.grey[700]),
                    const SizedBox(height: 4),
                    Container(width: 40, height: 12, color: Colors.grey[700]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimColor,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text("back".tr, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Get.to(() => SearchPage()),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text("search".tr, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Categories
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Obx(() {
                      final allMovies = playlistController.movies;
                      final resumeCount = playlistController.resumeMovies.length;
                      final hiddenVod = HiveService.getHiddenVodCategories()
                          .map((e) => e.toString().toLowerCase().trim())
                          .toList();

                      final categories = allMovies
                          .map((m) => m['category_name'] ?? "Uncategorized".tr)
                          .where((name) => name.toString().trim().isNotEmpty)
                        // ✅ Filter out hidden categories (case-insensitive)
                          .where((name) =>
                      !hiddenVod.contains(name.toString().toLowerCase().trim()))
                          .toSet()
                          .toList();

                        // ✅ Sort alphabetically, keeping “Uncategorized” last
                      categories.sort((a, b) {
                        if (a == "Uncategorized".tr) return 1;
                        if (b == "Uncategorized".tr) return -1;
                        return a.toString().compareTo(b.toString());
                      });

                      return ListView(
                        children: [
                          _buildCategoryBox(
                            label: "resume_to_watch".tr,
                            count: resumeCount,
                            isSelected: _selectedCategory == "resume_to_watch".tr,
                            onTap: () {
                              setState(() => _selectedCategory = "resume_to_watch".tr);
                            },
                          ),
                          _buildCategoryBox(
                            label: "all_movies".tr,
                            count: allMovies.length,
                            isSelected: _selectedCategory == "all".tr,
                            onTap: () {
                              setState(() => _selectedCategory = "all".tr);
                            },
                          ),
                          _buildCategoryBox(
                            label: "favorites".tr,
                            count: playlistController.favoriteMovieIds.length,
                            isSelected: _selectedCategory == "favorites".tr,
                            onTap: () {
                              setState(() => _selectedCategory = "favorites".tr);
                            },
                          ),
                          ...categories.map((cat) => _buildCategoryBox(
                            label: cat,
                            count: allMovies.where((m) => m['category_name'] == cat).length,
                            isSelected: _selectedCategory == cat,
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                            },
                          )),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(color: Colors.white, width: 1, thickness: 1),

          // Main grid
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedOrder,
                        dropdownColor: kSecColor,
                        icon: const Icon(Icons.keyboard_arrow_down_outlined, color: Colors.white),
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        underline: Container(height: 2, color: Colors.white),
                        onChanged: (String? newValue) {
                          setState(() => _selectedOrder = newValue!);
                        },
                        items: _orderOptions.map((opt) => DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt), // ✅ show translated label
                        ))
                            .toList(),
                      ),
                      Obx(() => Text(
                        '$_selectedCategory (${getFilteredMovies().length})',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    if (playlistController.isVodLoading.value) {
                      return _buildLoadingGrid();
                    }

                    final movies = getFilteredMovies();
                    if (movies.isEmpty) {
                      return Center(
                        child: Text("no_movies_found".tr,
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final playlist = playlistController.currentPlaylist;
                    final username = playlist?['username'] ?? '';
                    final password = playlist?['password'] ?? '';
                    final baseUrl = playlist?['baseUrl'] ?? '';

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        final id = movie['id']?.toString();

                        return InkWell(
                          onTap: () async {

                            final fullInfo = await playlistController.fetchMovieDetails(
                              movie: movie,
                              baseUrl: baseUrl,
                              username: username,
                              password: password,
                            );
                            if (fullInfo.isNotEmpty) {
                              Get.to(() => MovieDetailsPage(
                                movie: fullInfo,
                                movies: movies,
                                currentIndex: index,
                              ));
                            } else {
                              Get.snackbar("error".tr, "failed_to_load_movie_details".tr);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        movie['cover'] != null &&
                                            movie['cover'].toString().isNotEmpty
                                            ? CachedNetworkImage(
                                          imageUrl: movie['cover'],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (_, __) => Shimmer.fromColors(
                                            baseColor: Colors.grey[800]!,
                                            highlightColor: Colors.grey[600]!,
                                            child: Container(color: Colors.grey[850]),
                                          ),
                                          errorWidget: (_, __, ___) =>
                                              _buildPlaceholderIcon(),
                                        )
                                            : _buildPlaceholderIcon(),
                                        if (movie['rating'] != null &&
                                            movie['rating'].toString().isNotEmpty)
                                          Positioned(
                                            bottom: 6,
                                            left: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _getRatingColor(
                                                  double.tryParse(movie['rating'].toString()) ?? 0.0,
                                                ).withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                movie['rating'].toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (id != null) {
                                                final isFav = playlistController.isFavorite(
                                                  id,
                                                  isSeries: false,
                                                );
                                                playlistController.updateFavorite(
                                                  id,
                                                  !isFav,
                                                  isSeries: false,
                                                );
                                              }
                                            },
                                            child: Obx(() {
                                              final isFav = playlistController.isFavorite(
                                                id,
                                                isSeries: false,
                                              );
                                              return Icon(
                                                isFav ? Icons.star : Icons.star_border,
                                                color: Colors.amber,
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (movie['year'] != null)
                                        Text(
                                          movie['year'].toString(),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12.sp,
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
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[800],
      child: const Center(child: Icon(Icons.movie, color: Colors.white, size: 40)),
    );
  }
}

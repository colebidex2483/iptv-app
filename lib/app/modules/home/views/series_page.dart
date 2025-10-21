import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ibo_clone/app/const/appColors.dart';
import 'package:ibo_clone/app/modules/search/view/search_page.dart';
import 'package:ibo_clone/app/widgets/series_details_page.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/hive_service.dart';
import '../../playlists/controllers/playlists_controller.dart';

class SeriesPage extends StatefulWidget {
  final String? searchQuery;
  const SeriesPage({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  final PlaylistController controller = Get.find<PlaylistController>();

  String _selectedOrder = "order_by_added".tr;
  String _selectedCategory = "all".tr;

  final List<String> _orderOptions = [
    "order_by_added".tr,
    "order_by_a_z".tr,
    "order_by_z_a".tr,
    "order_by_year".tr,
    "order_by_rating".tr,
  ];

  @override
  void initState() {
    super.initState();
    if (controller.connectedPlaylistId.value.isNotEmpty) {
      controller.loadVodContent(controller.connectedPlaylistId.value);
    }
  }

  // 🔹 Filter series by selected category & search
  List<Map<String, dynamic>> getFilteredSeries() {
    final allSeries = controller.series;
    List<Map<String, dynamic>> filtered;

    if (_selectedCategory == "all".tr) {
      filtered = List<Map<String, dynamic>>.from(allSeries);
    } else if (_selectedCategory == "resume_to_watch".tr) {
      filtered = allSeries
          .where((s) => s['progress'] != null && s['progress'] > 0)
          .toList();
    } else if (_selectedCategory == "favorites".tr) {
      filtered = allSeries
          .where((s) =>
          controller.isFavorite(s['id']?.toString(), isSeries: true))
          .toList();
    } else {
      // ✅ new: match by category_name (attached automatically)
      filtered = allSeries
          .where((s) =>
      (s['category_name'] ?? '').toString() == _selectedCategory)
          .toList();
    }

    // 🔎 Apply search filter
    final query = (widget.searchQuery ?? '').toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((s) =>
          (s['name'] ?? '').toString().toLowerCase().contains(query))
          .toList();
    }

    // 🔁 Sorting
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

  // 🔹 Category Sidebar UI box
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

  // 🔹 Sidebar Categories (reactive)
  Widget _buildSidebarCategories() {
    return Obx(() {
      final allSeries = controller.series;
      final hiddenVod = HiveService.getHiddenSeriesCategories()
          .map((e) => e.toString().toLowerCase().trim())
          .toList();

      final uniqueCategories = allSeries
          .map((s) => (s['category_name'] ?? '').toString())
          .where((name) => name.isNotEmpty)
          .where((name) => !hiddenVod.contains(name.toString().toLowerCase().trim()))
          .toSet()
          .toList()
        ..sort((a, b) => a.compareTo(b));


      return ListView(
        children: [
          _buildCategoryBox(
            label: "resume_to_watch".tr,
            count: allSeries
                .where((s) => s['progress'] != null && s['progress'] > 0)
                .length,
            isSelected: _selectedCategory == "resume_to_watch".tr,
            onTap: () => setState(() => _selectedCategory = "resume_to_watch".tr),
          ),
          _buildCategoryBox(
            label: "all".tr,
            count: allSeries.length,
            isSelected: _selectedCategory == "all".tr,
            onTap: () => setState(() => _selectedCategory = "all".tr),
          ),
          _buildCategoryBox(
            label: "favorites".tr,
            count: controller.favoriteSeriesIds.length,
            isSelected: _selectedCategory == "favorites".tr,
            onTap: () => setState(() => _selectedCategory = "favorites".tr),
          ),
          ...uniqueCategories.map((catName) => _buildCategoryBox(
            label: catName,
            count: allSeries
                .where((s) => s['category_name'] == catName)
                .length,
            isSelected: _selectedCategory == catName,
            onTap: () => setState(() => _selectedCategory = catName),
          )),
        ],
      );
    });
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
                width: double.infinity,
                height: 16,
                color: Colors.grey[700],
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
          // 🔹 Sidebar
          Container(
            width: 240,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      const Icon(Icons.tv, size: 50, color: Colors.white),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Get.back(),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_back_ios,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text("back".tr,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.sp)),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Get.to(() => const SearchPage()),
                            child: Row(
                              children: [
                                const Icon(Icons.search,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text("search".tr,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 🔹 Category List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: _buildSidebarCategories(),
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(color: Colors.white, width: 1, thickness: 1),

          // 🔹 Main Series Grid
          Expanded(
            child: Column(
              children: [
                // Filter Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: _selectedOrder,
                        dropdownColor: kSecColor,
                        icon: const Icon(Icons.keyboard_arrow_down_outlined,
                            color: Colors.white),
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        underline: Container(height: 2, color: Colors.white),
                        onChanged: (String? newValue) {
                          setState(() => _selectedOrder = newValue!);
                        },
                        items: _orderOptions
                            .map((opt) => DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt),
                        ))
                            .toList(),
                      ),
                      Obx(() => Text(
                        '$_selectedCategory (${getFilteredSeries().length})',
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

                // 🔹 Grid
                Expanded(
                  child: Obx(() {
                    if (controller.isVodLoading.value) {
                      return _buildLoadingGrid();
                    }
                    final seriesList = getFilteredSeries();
                    if (seriesList.isEmpty) {
                      return Center(
                        child: Text("no_series_found".tr,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }

                    final playlist = controller.currentPlaylist;
                    final username = playlist?['username'] ?? '';
                    final password = playlist?['password'] ?? '';
                    final baseUrl = playlist?['baseUrl'] ?? '';

                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: seriesList.length,
                      itemBuilder: (context, index) {
                        final series = seriesList[index];
                        final name = series['name'] ?? "no_title".tr;
                        final cover = series['cover'] ?? '';

                        return InkWell(
                          onTap: () async {
                            final fullInfo = await controller.fetchSeriesDetails(
                              baseUrl: baseUrl,
                              username: username,
                              password: password,
                              seriesId: series['id']?.toString() ?? '',
                            );
                            Get.to(() => SeriesDetailsPage(
                              series: fullInfo,
                              seriesList: seriesList,
                              currentIndex: index,
                            ));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: cover.isNotEmpty
                                        ? CachedNetworkImage(
                                      imageUrl: cover,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (c, u) =>
                                          Shimmer.fromColors(
                                            baseColor: Colors.grey[800]!,
                                            highlightColor: Colors.grey[600]!,
                                            child: Container(
                                                color: Colors.grey[850]),
                                          ),
                                      errorWidget: (c, u, e) => Container(
                                        color: Colors.grey[800],
                                        child: const Icon(Icons.tv,
                                            color: Colors.white,
                                            size: 40),
                                      ),
                                    )
                                        : Container(
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.tv,
                                          color: Colors.white, size: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
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
}

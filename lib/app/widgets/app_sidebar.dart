import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({super.key});

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // Sidebar
          SizedBox(
            width: 18.w,
            child: Container(
              color: const Color(0xFF1E1E1E), // dark background
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 3.h),
                  _sidebarItem(
                    title: "Resume to Watch",
                    icon: Icons.play_arrow,
                    isActive: false,
                    onTap: () {
                      // Handle resume navigation
                    },
                  ),
                  _sidebarItem(
                    title: "All Movies",
                    icon: Icons.movie,
                    isActive: false,
                    onTap: () {
                      Get.toNamed("/movies");
                    },
                  ),
                  _sidebarItem(
                    title: "All Series",
                    icon: Icons.tv,
                    isActive: true, // current page
                    onTap: () {
                      // Already here
                    },
                  ),
                  _sidebarItem(
                    title: "Favourites",
                    icon: Icons.favorite,
                    isActive: false,
                    onTap: () {
                      Get.toNamed("/favourites");
                    },
                  ),
                  _sidebarItem(
                    title: "Downloads",
                    icon: Icons.download,
                    isActive: false,
                    onTap: () {
                      Get.toNamed("/downloads");
                    },
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  "Series Page Content",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.w),
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isActive ? Colors.white : Colors.grey[400],
            ),
            SizedBox(width: 1.5.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

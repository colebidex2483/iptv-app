import 'dart:io';
import 'package:flutter/material.dart';

class CommonImageView extends StatelessWidget {
  final String? url; // For network image URL
  final String? imagePath; // For local asset image
  final File? file; // For image from local file system
  final double? height;
  final double? width;
  final double? radius;
  final BoxFit fit;
  final String placeholder;

  CommonImageView({
    this.url,
    this.imagePath,
    this.file,
    this.height,
    this.width,
    this.radius = 8.0,
    this.fit = BoxFit.cover,
    this.placeholder = 'assets/images/no_image_found.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius!),
        child: _buildImageView(context),
      ),
    );
  }

  Widget _buildImageView(BuildContext context) {
    if (file != null && file!.path.isNotEmpty) {
      // Display image from file
      return Image.file(
        file!,
        height: height,
        width: width,
        fit: fit,
      );
    } else if (url != null && url!.isNotEmpty) {
      // Display network image
      return Image.network(
        url!,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      // Display asset image
      return Image.asset(
        imagePath!,
        height: height,
        width: width,
        fit: fit,
      );
    }
    // Fallback to placeholder
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      placeholder,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
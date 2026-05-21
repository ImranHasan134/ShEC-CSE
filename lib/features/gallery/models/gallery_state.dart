import 'package:flutter/material.dart';

class GalleryItem {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final List<String> imagePaths;
  final bool isApproved;
  final bool isVisible;
  final String createdByName;

  GalleryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    this.imagePaths = const [],
    this.isApproved = false,
    this.isVisible = true,
    this.createdByName = '',
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    final pathsRaw = json['image_paths'] as List?;
    final List<String> parsedPaths = pathsRaw != null
        ? List<String>.from(pathsRaw.map((e) => e.toString()))
        : [];
    
    final imagePathVal = json['image_path'] as String? ?? '';
    if (parsedPaths.isEmpty && imagePathVal.isNotEmpty) {
      parsedPaths.add(imagePathVal);
    }

    return GalleryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? json['subtitle'] as String? ?? '',
      imagePath: imagePathVal.isNotEmpty ? imagePathVal : (parsedPaths.isNotEmpty ? parsedPaths.first : ''),
      imagePaths: parsedPaths,
      isApproved: json['is_approved'] as bool? ?? false,
      isVisible: json['is_visible'] as bool? ?? true,
      createdByName: json['created_by_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'subtitle': description,
      'image_path': imagePath.isNotEmpty ? imagePath : (imagePaths.isNotEmpty ? imagePaths.first : ''),
      'image_paths': imagePaths,
      'is_approved': isApproved,
      'is_visible': isVisible,
      'created_by_name': createdByName,
    };
  }
}

// Global Notifier for Gallery Items
final ValueNotifier<List<GalleryItem>> galleryState = ValueNotifier([]);

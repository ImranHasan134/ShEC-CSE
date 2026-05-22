import 'dart:io';
import '../../models/gallery_state.dart';

abstract class GalleryRepository {
  Future<List<GalleryItem>> fetchGalleryItems({bool forceRefresh = false});
  Future<void> addGalleryItem(GalleryItem item);
  Future<void> updateGalleryItem(GalleryItem item);
  Future<void> approveGalleryItem(String id);
  Future<void> toggleGalleryVisibility(String id, bool isVisible);
  Future<void> deleteGalleryItem(GalleryItem item);
  Future<String?> uploadImage(File file);
}

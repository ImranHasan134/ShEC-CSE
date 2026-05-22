import 'dart:io';
import '../../domain/repositories/gallery_repository.dart';
import '../../models/gallery_state.dart';
import '../../../../backend/services/gallery_service.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  @override
  Future<List<GalleryItem>> fetchGalleryItems({bool forceRefresh = false}) async {
    return GalleryService.fetchGalleryItems(forceRefresh: forceRefresh);
  }

  @override
  Future<void> addGalleryItem(GalleryItem item) async {
    await GalleryService.addGalleryItemToDB(item);
  }

  @override
  Future<void> updateGalleryItem(GalleryItem item) async {
    await GalleryService.updateGalleryItemInDB(item);
  }

  @override
  Future<void> approveGalleryItem(String id) async {
    await GalleryService.approveGalleryItem(id);
  }

  @override
  Future<void> toggleGalleryVisibility(String id, bool isVisible) async {
    await GalleryService.toggleGalleryVisibility(id, isVisible);
  }

  @override
  Future<void> deleteGalleryItem(GalleryItem item) async {
    await GalleryService.deleteGalleryItemFromDB(item);
  }

  @override
  Future<String?> uploadImage(File file) async {
    return GalleryService.uploadImage(file);
  }
}

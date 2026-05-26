import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/gallery/models/gallery_state.dart';
import '../../features/profile/models/profile_state.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/connectivity_service.dart';

class GalleryService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<GalleryItem> _galleryItems = [];

  static final StreamController<List<GalleryItem>> _galleryStreamController = StreamController.broadcast();
  static Stream<List<GalleryItem>> get galleryStream => _galleryStreamController.stream;

  static List<GalleryItem> get galleryItems => _galleryItems;

  static Future<List<GalleryItem>> fetchGalleryItems({bool forceRefresh = false}) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      final cachedGalleryStr = await DatabaseHelper.instance.getCache('gallery');
      if (cachedGalleryStr != null) {
        try {
          final List decoded = json.decode(cachedGalleryStr);
          _galleryItems = decoded.map((r) => GalleryItem.fromJson(r)).toList();
          _galleryStreamController.add(_galleryItems);
          debugPrint('Successfully loaded gallery from local SQLite database.');
          return _galleryItems;
        } catch (e) {
          debugPrint('Error deserializing cached gallery: $e');
        }
      }
      return _galleryItems;
    }

    if (!forceRefresh && !CacheService.isStale(CacheKeys.gallery)) return _galleryItems;
    
    final isAdmin = currentProfile.value.role != UserRole.student;
    
    var query = _client.from('gallery').select();
    if (!isAdmin) {
      query = query.eq('is_approved', true).eq('is_visible', true);
    }
    
    final response = await query.order('created_at', ascending: false);
    _galleryItems = (response as List).map((r) => GalleryItem.fromJson(r)).toList();
    CacheService.markFresh(CacheKeys.gallery);
    _galleryStreamController.add(_galleryItems);

    // Save to SQLite
    await DatabaseHelper.instance.saveCache('gallery', json.encode(response));

    return _galleryItems;
  }

  static Future<void> addGalleryItemToDB(GalleryItem item) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to upload gallery media.');
      throw Exception('Network connection required');
    }
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';
    
    final data = item.toJson();
    data['is_approved'] = isSuperUser;
    data['is_visible'] = true;
    data['created_by_name'] = profile.name;
    
    final response = await _client
        .from('gallery')
        .insert(data)
        .select()
        .single();

    final newItem = GalleryItem.fromJson(response);
    _galleryItems = List.from(_galleryItems)..insert(0, newItem);
    _galleryStreamController.add(_galleryItems);
    CacheService.invalidate(CacheKeys.gallery);
  }

  static Future<void> updateGalleryItemInDB(GalleryItem item) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to update gallery details.');
      throw Exception('Network connection required');
    }
    final data = item.toJson();
    data.remove('is_approved'); // Don't overwrite existing status on normal edit
    
    await _client
        .from('gallery')
        .update(data)
        .eq('id', item.id);
        
    CacheService.invalidate(CacheKeys.gallery);
    await fetchGalleryItems(forceRefresh: true);
  }

  static Future<void> approveGalleryItem(String id) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to approve gallery items.');
      throw Exception('Network connection required');
    }
    await _client.from('gallery').update({'is_approved': true}).eq('id', id);
    CacheService.invalidate(CacheKeys.gallery);
    await fetchGalleryItems(forceRefresh: true);
  }

  static Future<void> toggleGalleryVisibility(String id, bool isVisible) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to toggle gallery visibility.');
      throw Exception('Network connection required');
    }
    await _client.from('gallery').update({'is_visible': isVisible}).eq('id', id);
    CacheService.invalidate(CacheKeys.gallery);
    await fetchGalleryItems(forceRefresh: true);
  }

  static Future<void> deleteGalleryItemFromDB(GalleryItem item) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to delete gallery media.');
      throw Exception('Network connection required');
    }
    try {
      // 1. Delete all images from storage
      for (final path in item.imagePaths) {
        if (path.isNotEmpty) {
          try {
            await StorageService.deleteFile(path);
          } catch (e) {
            debugPrint('Failed to delete file from storage: $path. Error: $e');
          }
        }
      }

      // 2. Delete from DB
      await _client.from('gallery').delete().eq('id', item.id);

      _galleryItems = List.from(_galleryItems)..removeWhere((i) => i.id == item.id);
      _galleryStreamController.add(_galleryItems);
      CacheService.invalidate(CacheKeys.gallery);
    } catch (e) {
      debugPrint('Error deleting gallery item: $e');
      rethrow;
    }
  }

  static Future<String?> uploadImage(File file) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to upload pictures.');
      throw Exception('Network connection required');
    }
    return StorageService.uploadFile(file, 'gallery_images');
  }
}

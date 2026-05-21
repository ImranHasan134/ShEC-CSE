import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/about/models/contributor_item.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';

class ContributorService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> fetchContributors({bool forceRefresh = false}) async {
    if (!forceRefresh && !CacheService.isStale(CacheKeys.contributors)) return;

    try {
      final response = await _client
          .from('contributors')
          .select()
          .order('created_at', ascending: true);
      
      contributorsState.value = (response as List)
          .map((e) => ContributorItem.fromJson(e))
          .toList();
      CacheService.markFresh(CacheKeys.contributors);
    } catch (e) {
      debugPrint('Error fetching contributors: $e');
    }
  }

  static Future<void> addContributor(ContributorItem item) async {
    try {
      final data = item.toJson();
      await _client.from('contributors').insert(data);
      CacheService.invalidate(CacheKeys.contributors);
      await fetchContributors(forceRefresh: true);
    } catch (e) {
      debugPrint('Error adding contributor: $e');
      rethrow;
    }
  }

  static Future<void> updateContributor(ContributorItem item) async {
    try {
      final data = item.toJson();
      await _client.from('contributors').update(data).eq('id', item.id);
      CacheService.invalidate(CacheKeys.contributors);
      await fetchContributors(forceRefresh: true);
    } catch (e) {
      debugPrint('Error updating contributor: $e');
      rethrow;
    }
  }

  static Future<void> deleteContributor(ContributorItem item) async {
    try {
      // 1. Delete image from storage if it exists and is a storage url
      if (item.imagePath.isNotEmpty) {
        await StorageService.deleteFile(item.imagePath);
      }

      // 2. Delete from DB
      await _client.from('contributors').delete().eq('id', item.id);
      CacheService.invalidate(CacheKeys.contributors);
      await fetchContributors(forceRefresh: true);
    } catch (e) {
      debugPrint('Error deleting contributor: $e');
      rethrow;
    }
  }

  static Future<String?> uploadImage(File file) async {
    return StorageService.uploadFile(file, 'alumni_images');
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/contributor_item.dart';
import '../../domain/repositories/contributor_repository.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/storage_service.dart';

class ContributorRepositoryImpl implements ContributorRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<List<ContributorItem>> getContributors({bool forceRefresh = false}) async {
    if (!forceRefresh && !CacheService.isStale(CacheKeys.contributors)) {
      // If cached and fresh, we read from DB but the cache checking logic is preserved.
      // Since there is no local DB cache in original service for this, we query when stale.
      // In the original, contributorsState was populated.
    }

    try {
      final response = await _client
          .from('contributors')
          .select()
          .order('created_at', ascending: true);
      
      final list = (response as List)
          .map((e) => ContributorItem.fromJson(e))
          .toList();
      
      CacheService.markFresh(CacheKeys.contributors);
      return list;
    } catch (e) {
      debugPrint('Error fetching contributors: $e');
      rethrow;
    }
  }

  @override
  Future<void> addContributor(ContributorItem item) async {
    try {
      final data = item.toJson();
      await _client.from('contributors').insert(data);
      CacheService.invalidate(CacheKeys.contributors);
    } catch (e) {
      debugPrint('Error adding contributor: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateContributor(ContributorItem item) async {
    try {
      final data = item.toJson();
      await _client.from('contributors').update(data).eq('id', item.id);
      CacheService.invalidate(CacheKeys.contributors);
    } catch (e) {
      debugPrint('Error updating contributor: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteContributor(ContributorItem item) async {
    try {
      if (item.imagePath.isNotEmpty) {
        await StorageService.deleteFile(item.imagePath);
      }
      await _client.from('contributors').delete().eq('id', item.id);
      CacheService.invalidate(CacheKeys.contributors);
    } catch (e) {
      debugPrint('Error deleting contributor: $e');
      rethrow;
    }
  }

  @override
  Future<String?> uploadImage(File file) async {
    return StorageService.uploadFile(file, 'alumni_images');
  }
}

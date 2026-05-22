import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/alumni/models/alumni_state.dart';
import '../../features/profile/models/profile_state.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';

class AlumniService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<AlumniItem> _alumniItems = [];

  static final StreamController<List<AlumniItem>> _alumniStreamController = StreamController.broadcast();
  static Stream<List<AlumniItem>> get alumniStream => _alumniStreamController.stream;

  static List<AlumniItem> get alumniItems => _alumniItems;

  static Future<List<AlumniItem>> fetchAlumni({bool forceRefresh = false}) async {
    if (!forceRefresh && !CacheService.isStale(CacheKeys.alumni)) return _alumniItems;

    try {
      final isAdmin = currentProfile.value.role != UserRole.student;
      var query = _client.from('alumni').select();
      if (!isAdmin) {
        query = query.eq('is_approved', true).eq('is_visible', true);
      }
      final response = await query.order('created_at', ascending: false);
      _alumniItems = (response as List).map((e) => AlumniItem.fromJson(e)).toList();
      CacheService.markFresh(CacheKeys.alumni);
      _alumniStreamController.add(_alumniItems);
    } catch (e) {
      debugPrint('Error fetching alumni: $e');
    }
    return _alumniItems;
  }

  static Future<void> addAlumni(AlumniItem item) async {
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';

    final data = item.toJson();
    data['is_approved'] = isSuperUser;
    data['created_by_name'] = profile.name;

    final response = await _client.from('alumni').insert(data).select().single();
    final newItem = AlumniItem.fromJson(response);
    _alumniItems = List.from(_alumniItems)..insert(0, newItem);
    _alumniStreamController.add(_alumniItems);
    CacheService.invalidate(CacheKeys.alumni);
  }

  static Future<void> updateAlumni(AlumniItem item) async {
    final data = item.toJson();
    data.remove('is_approved');
    await _client.from('alumni').update(data).eq('id', item.id);
    CacheService.invalidate(CacheKeys.alumni);
    await fetchAlumni(forceRefresh: true);
  }

  static Future<void> approveAlumni(String id) async {
    await _client.from('alumni').update({'is_approved': true}).eq('id', id);
    CacheService.invalidate(CacheKeys.alumni);
    await fetchAlumni(forceRefresh: true);
  }

  static Future<void> toggleAlumniVisibility(String id, bool isVisible) async {
    await _client.from('alumni').update({'is_visible': isVisible}).eq('id', id);
    CacheService.invalidate(CacheKeys.alumni);
    await fetchAlumni(forceRefresh: true);
  }

  static Future<void> deleteAlumni(AlumniItem alumni) async {
    try {
      // 1. Delete image from storage
      if (alumni.imagePath.isNotEmpty) {
        await StorageService.deleteFile(alumni.imagePath);
      }

      // 2. Delete from DB
      await _client.from('alumni').delete().eq('id', alumni.id);

      _alumniItems = _alumniItems.where((a) => a.id != alumni.id).toList();
      _alumniStreamController.add(_alumniItems);
      CacheService.invalidate(CacheKeys.alumni);
    } catch (e) {
      debugPrint('Error deleting alumni: $e');
      rethrow;
    }
  }

  /// Promote a club member to alumni (superuser only)
  static Future<void> promoteToAlumni(String memberId, AlumniItem alumniData) async {
    try {
      // 1. Insert into alumni table
      await addAlumni(alumniData);
      
      try {
        // 2. Mark profile as alumni
        await _client.from('profiles').update({'is_alumni': true}).eq('id', memberId);
      } catch (e) {
        // Rollback: if profile update fails, delete the inserted alumni record to prevent corrupt state
        debugPrint('Failed to update profile to alumni. Rolling back alumni insertion...');
        await _client.from('alumni').delete().eq('email', alumniData.email);
        rethrow;
      }
    } catch (e) {
      debugPrint('Error promoting member to alumni: $e');
      rethrow;
    }
  }

  static Future<String?> uploadImage(File file) async {
    return StorageService.uploadFile(file, 'alumni_images');
  }
}

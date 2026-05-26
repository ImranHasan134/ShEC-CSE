import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/department/models/teacher_state.dart';
import '../../features/profile/models/profile_state.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/connectivity_service.dart';

class TeacherService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<TeacherContact> _teachers = [];

  static final StreamController<List<TeacherContact>> _teachersStreamController = StreamController.broadcast();
  static Stream<List<TeacherContact>> get teachersStream => _teachersStreamController.stream;

  static List<TeacherContact> get teachers => _teachers;

  static Future<List<TeacherContact>> fetchTeachers({bool forceRefresh = false}) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      final cachedTeachersStr = await DatabaseHelper.instance.getCache('teachers');
      if (cachedTeachersStr != null) {
        try {
          final List decoded = json.decode(cachedTeachersStr);
          _teachers = decoded.map((e) => TeacherContact.fromJson(e)).toList();
          _teachersStreamController.add(_teachers);
          debugPrint('Successfully loaded teachers from local SQLite database.');
          return _teachers;
        } catch (e) {
          debugPrint('Error deserializing cached teachers: $e');
        }
      }
      return _teachers;
    }

    if (!forceRefresh && !CacheService.isStale(CacheKeys.teachers) && _teachers.isNotEmpty) return _teachers;

    final isAdmin = currentProfile.value.role != UserRole.student;
    var query = _client.from('teachers').select();
    if (!isAdmin) {
      query = query.eq('is_approved', true).eq('is_visible', true);
    }
    final response = await query.order('created_at', ascending: false);
    _teachers = (response as List).map((e) => TeacherContact.fromJson(e)).toList();
    _teachersStreamController.add(_teachers);
    CacheService.markFresh(CacheKeys.teachers);

    // Save to SQLite
    await DatabaseHelper.instance.saveCache('teachers', json.encode(response));

    return _teachers;
  }

  static Future<void> addTeacher(TeacherContact teacher) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to add teachers.');
      throw Exception('Network connection required');
    }
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';

    final data = teacher.toJson();
    data['is_approved'] = isSuperUser;
    data['is_visible'] = teacher.isVisible;
    data['created_by_name'] = profile.name;

    await _client.from('teachers').insert(data);
    CacheService.invalidate(CacheKeys.teachers);
    await fetchTeachers(forceRefresh: true);
  }

  static Future<void> toggleTeacherVisibility(String id, bool isVisible) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to toggle teacher visibility.');
      throw Exception('Network connection required');
    }
    await _client.from('teachers').update({'is_visible': isVisible}).eq('id', id);
    CacheService.invalidate(CacheKeys.teachers);
    await fetchTeachers(forceRefresh: true);
  }

  static Future<void> updateTeacher(TeacherContact teacher) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to update teacher info.');
      throw Exception('Network connection required');
    }
    final data = teacher.toJson();
    data.remove('is_approved');
    await _client.from('teachers').update(data).eq('id', teacher.id);
    CacheService.invalidate(CacheKeys.teachers);
    await fetchTeachers(forceRefresh: true);
  }

  static Future<void> approveTeacher(String id) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to approve teachers.');
      throw Exception('Network connection required');
    }
    await _client.from('teachers').update({'is_approved': true}).eq('id', id);
    CacheService.invalidate(CacheKeys.teachers);
    await fetchTeachers(forceRefresh: true);
  }

  static Future<void> deleteTeacher(TeacherContact teacher) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to delete teachers.');
      throw Exception('Network connection required');
    }
    if (teacher.imagePath.isNotEmpty) {
      try {
        await StorageService.deleteFile(teacher.imagePath);
      } catch (e) {
        // ignore
      }
    }

    await _client.from('teachers').delete().eq('id', teacher.id);
    _teachers = _teachers.where((t) => t.id != teacher.id).toList();
    _teachersStreamController.add(_teachers);
    CacheService.invalidate(CacheKeys.teachers);
  }

  static Future<String?> uploadImage(File file) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to upload teacher photos.');
      throw Exception('Network connection required');
    }
    return StorageService.uploadFile(file, 'teacher_images');
  }
}

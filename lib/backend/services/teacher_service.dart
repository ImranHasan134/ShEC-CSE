import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/department/models/teacher_state.dart';
import '../../features/profile/models/profile_state.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';

class TeacherService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<TeacherContact> _teachers = [];

  static final StreamController<List<TeacherContact>> _teachersStreamController = StreamController.broadcast();
  static Stream<List<TeacherContact>> get teachersStream => _teachersStreamController.stream;

  static List<TeacherContact> get teachers => _teachers;

  static Future<List<TeacherContact>> fetchTeachers({bool forceRefresh = false}) async {
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
    return _teachers;
  }

  static Future<void> addTeacher(TeacherContact teacher) async {
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
    await _client.from('teachers').update({'is_visible': isVisible}).eq('id', id);
    CacheService.invalidate(CacheKeys.teachers);
    await fetchTeachers(forceRefresh: true);
  }

  static Future<void> updateTeacher(TeacherContact teacher) async {
    final data = teacher.toJson();
    data.remove('is_approved');
    await _client.from('teachers').update(data).eq('id', teacher.id);
    CacheService.invalidate(CacheKeys.teachers);
    await fetchTeachers(forceRefresh: true);
  }

  static Future<void> approveTeacher(String id) async {
    await _client.from('teachers').update({'is_approved': true}).eq('id', id);
    CacheService.invalidate(CacheKeys.teachers);
    await fetchTeachers(forceRefresh: true);
  }

  static Future<void> deleteTeacher(TeacherContact teacher) async {
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
    return StorageService.uploadFile(file, 'teacher_images');
  }
}

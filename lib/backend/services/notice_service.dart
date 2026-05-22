import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/notices/models/notice_state.dart';
import '../../features/profile/models/profile_state.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/storage_service.dart';
import 'package:ShEC_CSE/backend/services/notification_service.dart';

class NoticeService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<NoticeItem> _clubNotices = [];
  static List<NoticeItem> _deptNotices = [];

  static final StreamController<({List<NoticeItem> club, List<NoticeItem> dept})> _noticesStreamController = StreamController.broadcast();
  static Stream<({List<NoticeItem> club, List<NoticeItem> dept})> get noticesStream => _noticesStreamController.stream;

  static List<NoticeItem> get clubNotices => _clubNotices;
  static List<NoticeItem> get deptNotices => _deptNotices;

  static Future<({List<NoticeItem> club, List<NoticeItem> dept})> fetchNotices({bool forceRefresh = false}) async {
    if (!forceRefresh && !CacheService.isStale(CacheKeys.notices)) {
      return (club: _clubNotices, dept: _deptNotices);
    }

    final profile = currentProfile.value;
    final isAdmin = profile.role != UserRole.student;

    var query = _client.from('notices').select();
    
    if (!isAdmin) {
      query = query.eq('is_approved', true).eq('is_visible', true);
    }
    
    final response = await query.order('created_at', ascending: false);

    final List<NoticeItem> clubList = [];
    final List<NoticeItem> deptList = [];

    for (var row in response) {
      final item = NoticeItem.fromJson(row);
      if (row['category'] == 'club') {
        clubList.add(item);
      } else {
        deptList.add(item);
      }
    }

    _clubNotices = clubList;
    _deptNotices = deptList;
    CacheService.markFresh(CacheKeys.notices);
    final result = (club: _clubNotices, dept: _deptNotices);
    _noticesStreamController.add(result);
    return result;
  }

  static Future<String?> uploadImage(File file) async {
    return StorageService.uploadFile(file, 'notice_images');
  }

  static Future<void> addNoticeToDB(NoticeItem notice, String category) async {
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';
    
    final Map<String, dynamic> data = {
      'category': category,
      'title': notice.title,
      'description': notice.description,
      'image_path': notice.imagePath ?? '',
      'tags': notice.tags,
      'is_pinned': notice.isPinned,
      'is_approved': isSuperUser, 
      'is_visible': true,
      'created_by_name': profile.name,
    };
    
    final now = DateTime.now();
    data['date'] = '${now.day}/${now.month}/${now.year}';

    try {
      final response = await _client
          .from('notices')
          .insert(data)
          .select()
          .single();

      final newItem = NoticeItem.fromJson(response);
      if (category == 'club') {
        _clubNotices = List.from(_clubNotices)..insert(0, newItem);
      } else {
        _deptNotices = List.from(_deptNotices)..insert(0, newItem);
      }
      CacheService.invalidate(CacheKeys.notices);
      _noticesStreamController.add((club: _clubNotices, dept: _deptNotices));
    } catch (e) {
      debugPrint('Error inserting notice: $e');
      rethrow;
    }
  }

  static Future<void> updateNoticeInDB(NoticeItem notice, String category) async {
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';
    
    final data = notice.toJson(category);
    
    if (!isSuperUser) {
      data['is_approved'] = false;
    }
    
    try {
      await _client
          .from('notices')
          .update(data)
          .eq('id', notice.id);
      
      CacheService.invalidate(CacheKeys.notices);
      fetchNotices(forceRefresh: true);
    } catch (e) {
      debugPrint('Error updating notice: $e');
      rethrow;
    }
  }

  static Future<void> toggleNoticePin(String id, bool isPinned) async {
    await _client.from('notices').update({'is_pinned': isPinned}).eq('id', id);
    CacheService.invalidate(CacheKeys.notices);
    fetchNotices(forceRefresh: true);
  }

  static Future<void> deleteNoticeFromDB(NoticeItem notice, String category) async {
    try {
      // 1. Delete Image from Storage if exists
      if (notice.imagePath != null && notice.imagePath!.isNotEmpty) {
        await StorageService.deleteFile(notice.imagePath!);
      }
      
      // 2. Delete from DB
      await _client.from('notices').delete().eq('id', notice.id);
      
      if (category == 'club') {
        _clubNotices = List.from(_clubNotices)..removeWhere((n) => n.id == notice.id);
      } else {
        _deptNotices = List.from(_deptNotices)..removeWhere((n) => n.id == notice.id);
      }
      CacheService.invalidate(CacheKeys.notices);
      _noticesStreamController.add((club: _clubNotices, dept: _deptNotices));
    } catch (e) {
      debugPrint('Error deleting notice and image: $e');
      rethrow;
    }
  }

  static Future<void> approveNotice(String id) async {
    await _client.from('notices').update({'is_approved': true}).eq('id', id);
    CacheService.invalidate(CacheKeys.notices);
    fetchNotices(forceRefresh: true);
  }

  static Future<void> toggleNoticeVisibility(String id, bool isVisible) async {
    await _client.from('notices').update({'is_visible': isVisible}).eq('id', id);
    CacheService.invalidate(CacheKeys.notices);
    fetchNotices(forceRefresh: true);
  }

  static RealtimeChannel? _noticeChannel;

  static void subscribeToNotices() {
    if (_noticeChannel != null) {
      debugPrint('Already subscribed to notices channel, skipping duplicate subscription.');
      return;
    }

    _noticeChannel = _client
      .channel('public:notices')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'notices',
        callback: (payload) {
          if (payload.eventType == PostgresChangeEvent.insert) {
            final data = payload.newRecord;
            // Notify if it's not our own notice
            if (data['created_by_name'] != currentProfile.value.name) {
               NotificationService.incrementUnread('notices');
               NotificationService.showNotification(
                id: 1,
                title: 'New Notice: ${data['title']}',
                body: data['description'] ?? 'A new notice has been posted.',
              );
            }
          }
          fetchNotices(forceRefresh: true);
        },
      );
    
    _noticeChannel!.subscribe();
  }

  static Future<void> unsubscribeFromNotices() async {
    if (_noticeChannel != null) {
      debugPrint('Unsubscribing from notices channel...');
      try {
        await _client.removeChannel(_noticeChannel!);
      } catch (e) {
        debugPrint('Error removing notices channel: $e');
      }
      _noticeChannel = null;
    }
  }
}

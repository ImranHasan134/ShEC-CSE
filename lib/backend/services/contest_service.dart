import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/contests/models/contest_state.dart';
import '../../features/profile/models/profile_state.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/connectivity_service.dart';
import 'notification_service.dart';

class ContestService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<ContestItem> _contestItems = [];

  static final StreamController<List<ContestItem>> _contestStreamController = StreamController.broadcast();
  static Stream<List<ContestItem>> get contestStream => _contestStreamController.stream;

  static List<ContestItem> get contestItems => _contestItems;

  static Future<List<ContestItem>> fetchContestsAndCourses({bool forceRefresh = false}) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      final cachedContestsStr = await DatabaseHelper.instance.getCache('contests');
      if (cachedContestsStr != null) {
        try {
          final List decoded = json.decode(cachedContestsStr);
          _contestItems = decoded.map((row) => ContestItem.fromJson(row)).toList();
          _contestStreamController.add(_contestItems);
          debugPrint('Successfully loaded contests from local SQLite database.');
          return _contestItems;
        } catch (e) {
          debugPrint('Error deserializing cached contests: $e');
        }
      }
      return _contestItems;
    }

    if (!forceRefresh && !CacheService.isStale(CacheKeys.contests)) return _contestItems;

    final isAdmin = currentProfile.value.role != UserRole.student;

    var query = _client.from('contests').select();
    if (!isAdmin) {
      query = query.eq('is_approved', true).eq('is_visible', true);
    }
    
    final response = await query.order('created_at', ascending: false);
    _contestItems = (response as List).map((row) => ContestItem.fromJson(row)).toList();

    _contestStreamController.add(_contestItems);
    CacheService.markFresh(CacheKeys.contests);

    // Save to SQLite
    await DatabaseHelper.instance.saveCache('contests', json.encode(response));

    return _contestItems;
  }

  static Future<void> addContestToDB(ContestItem item) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to create coding contests.');
      throw Exception('Network connection required');
    }
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';
    
    final data = item.toJson();
    data['is_approved'] = isSuperUser;
    data['is_visible'] = true;
    data['created_by_name'] = profile.name;
    
    final response = await _client
        .from('contests')
        .insert(data)
        .select()
        .single();

    final newItem = ContestItem.fromJson(response);
    _contestItems = List.from(_contestItems)..insert(0, newItem);
    _contestStreamController.add(_contestItems);
    CacheService.invalidate(CacheKeys.contests);
  }

  static Future<void> toggleContestVisibility(String id, bool isVisible) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to toggle contest visibility.');
      throw Exception('Network connection required');
    }
    await _client.from('contests').update({'is_visible': isVisible}).eq('id', id);
    CacheService.invalidate(CacheKeys.contests);
    await fetchContestsAndCourses(forceRefresh: true);
  }

  static Future<void> updateContestInDB(ContestItem item) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to update contests.');
      throw Exception('Network connection required');
    }
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';
    
    final data = item.toJson();
    
    if (!isSuperUser) {
      data['is_approved'] = false;
    }
    
    await _client
        .from('contests')
        .update(data)
        .eq('id', item.id);
        
    CacheService.invalidate(CacheKeys.contests);
    await fetchContestsAndCourses(forceRefresh: true);
  }

  static Future<void> approveContest(String id) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to approve contests.');
      throw Exception('Network connection required');
    }
    await _client.from('contests').update({'is_approved': true}).eq('id', id);
    CacheService.invalidate(CacheKeys.contests);
    await fetchContestsAndCourses(forceRefresh: true);
  }

  static Future<void> deleteContestFromDB(ContestItem item) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to delete contests.');
      throw Exception('Network connection required');
    }
    await _client
        .from('contests')
        .delete()
        .eq('id', item.id);

    _contestItems = List.from(_contestItems)..removeWhere((i) => i.id == item.id);
    _contestStreamController.add(_contestItems);
    CacheService.invalidate(CacheKeys.contests);
  }

  static RealtimeChannel? _contestChannel;

  // Real-time subscription
  static void subscribeToContests() {
    if (_contestChannel != null) {
      return;
    }

    _contestChannel = _client
      .channel('public:contests')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'contests',
        callback: (payload) {
          if (payload.eventType == PostgresChangeEvent.insert) {
            final data = payload.newRecord;
            if (data['created_by_name'] != currentProfile.value.name) {
              NotificationService.incrementUnread('contests');
              NotificationService.showNotification(
                id: 3,
                title: 'New Contest: ${data['title']}',
                body: 'Level: ${data['level']}. Register now!',
              );
            }
          }
          fetchContestsAndCourses(forceRefresh: true);
        },
      );
    
    _contestChannel!.subscribe();
  }

  static Future<void> unsubscribeFromContests() async {
    if (_contestChannel != null) {
      try {
        await _client.removeChannel(_contestChannel!);
      } catch (e) {
        // Silently ignore
      }
      _contestChannel = null;
    }
  }
}

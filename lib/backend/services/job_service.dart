import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/jobs/models/job_state.dart';
import '../../features/profile/models/profile_state.dart';
import '../../core/services/cache_service.dart';
import 'notification_service.dart';

class JobService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<JobItem> _jobItems = [];

  static final StreamController<List<JobItem>> _jobsStreamController = StreamController.broadcast();
  static Stream<List<JobItem>> get jobsStream => _jobsStreamController.stream;

  static List<JobItem> get jobItems => _jobItems;

  static Future<List<JobItem>> fetchJobs({bool forceRefresh = false}) async {
    if (!forceRefresh && !CacheService.isStale(CacheKeys.jobsRecommended)) return _jobItems;
    
    final isAdmin = currentProfile.value.role != UserRole.student;
    
    var query = _client.from('jobs').select();
    if (!isAdmin) {
      query = query.eq('is_approved', true).eq('is_visible', true);
    }
    
    final response = await query.order('created_at', ascending: false);
    _jobItems = (response as List).map((row) => JobItem.fromJson(row)).toList();

    _jobsStreamController.add(_jobItems);
    CacheService.markFresh(CacheKeys.jobsRecommended);
    return _jobItems;
  }

  static Future<void> addJobToDB(JobItem job) async {
    final profile = currentProfile.value;
    final isSuperUser = profile.designation == 'President' || profile.designation == 'Vice President';
    
    final data = job.toJson();
    data['is_approved'] = isSuperUser;
    data['is_visible'] = true;
    data['created_by_name'] = profile.name;
    
    final response = await _client
        .from('jobs')
        .insert(data)
        .select()
        .single();

    final newJob = JobItem.fromJson(response);
    _jobItems = List.from(_jobItems)..insert(0, newJob);
    _jobsStreamController.add(_jobItems);
    CacheService.invalidate(CacheKeys.jobsRecommended);
  }

  static Future<void> updateJobInDB(JobItem job) async {
    final data = job.toJson();
    data.remove('is_approved'); // Don't overwrite existing status on normal edit
    
    await _client
        .from('jobs')
        .update(data)
        .eq('id', job.id);
        
    CacheService.invalidate(CacheKeys.jobsRecommended);
    await fetchJobs(forceRefresh: true);
  }

  static Future<void> approveJob(String id) async {
    await _client.from('jobs').update({'is_approved': true}).eq('id', id);
    CacheService.invalidate(CacheKeys.jobsRecommended);
    await fetchJobs(forceRefresh: true);
  }

  static Future<void> toggleJobVisibility(String id, bool isVisible) async {
    await _client.from('jobs').update({'is_visible': isVisible}).eq('id', id);
    CacheService.invalidate(CacheKeys.jobsRecommended);
    await fetchJobs(forceRefresh: true);
  }

  static Future<void> deleteJobFromDB(String id) async {
    await _client
        .from('jobs')
        .delete()
        .eq('id', id);

    _jobItems = List.from(_jobItems)..removeWhere((job) => job.id == id);
    _jobsStreamController.add(_jobItems);
    CacheService.invalidate(CacheKeys.jobsRecommended);
  }

  static RealtimeChannel? _jobChannel;

  // Real-time subscription
  static void subscribeToJobs() {
    if (_jobChannel != null) {
      return;
    }

    _jobChannel = _client
      .channel('public:jobs')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'jobs',
        callback: (payload) {
          if (payload.eventType == PostgresChangeEvent.insert) {
            final data = payload.newRecord;
            if (data['created_by_name'] != currentProfile.value.name) {
              NotificationService.incrementUnread('jobs');
              NotificationService.showNotification(
                id: 2,
                title: 'New Job Opening: ${data['title'] ?? 'Role'}',
                body: '${data['company'] ?? 'Company'} is hiring! Check it out in the Job Board.',
              );
            }
          }
          fetchJobs(forceRefresh: true);
        },
      );
    
    _jobChannel!.subscribe();
  }

  static Future<void> unsubscribeFromJobs() async {
    if (_jobChannel != null) {
      try {
        await _client.removeChannel(_jobChannel!);
      } catch (e) {
        // Silently ignore
      }
      _jobChannel = null;
    }
  }
}

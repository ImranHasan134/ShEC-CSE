import '../../models/job_state.dart';

abstract class JobRepository {
  Future<List<JobItem>> fetchJobs({bool forceRefresh = false});
  Future<void> addJob(JobItem job);
  Future<void> updateJob(JobItem job);
  Future<void> approveJob(String id);
  Future<void> toggleJobVisibility(String id, bool isVisible);
  Future<void> deleteJob(String id);
}

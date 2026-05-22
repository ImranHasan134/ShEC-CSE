import '../../domain/repositories/job_repository.dart';
import '../../models/job_state.dart';
import '../../../../backend/services/job_service.dart';

class JobRepositoryImpl implements JobRepository {
  @override
  Future<List<JobItem>> fetchJobs({bool forceRefresh = false}) async {
    return JobService.fetchJobs(forceRefresh: forceRefresh);
  }

  @override
  Future<void> addJob(JobItem job) async {
    await JobService.addJobToDB(job);
  }

  @override
  Future<void> updateJob(JobItem job) async {
    await JobService.updateJobInDB(job);
  }

  @override
  Future<void> approveJob(String id) async {
    await JobService.approveJob(id);
  }

  @override
  Future<void> toggleJobVisibility(String id, bool isVisible) async {
    await JobService.toggleJobVisibility(id, isVisible);
  }

  @override
  Future<void> deleteJob(String id) async {
    await JobService.deleteJobFromDB(id);
  }
}

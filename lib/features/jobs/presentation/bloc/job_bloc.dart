import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'job_event.dart';
import 'job_state.dart';
import '../../domain/repositories/job_repository.dart';
import '../../../../backend/services/job_service.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final JobRepository _jobRepository;
  StreamSubscription? _jobSubscription;

  JobBloc({required JobRepository jobRepository})
      : _jobRepository = jobRepository,
        super(JobInitial()) {
    on<FetchJobsRequested>(_onFetchJobsRequested);
    on<AddJobRequested>(_onAddJobRequested);
    on<UpdateJobRequested>(_onUpdateJobRequested);
    on<ApproveJobRequested>(_onApproveJobRequested);
    on<ToggleJobVisibilityRequested>(_onToggleJobVisibilityRequested);
    on<DeleteJobRequested>(_onDeleteJobRequested);
    on<JobsUpdatedPrivate>(_onJobsUpdatedPrivate);

    _jobSubscription = JobService.jobsStream.listen((items) {
      add(JobsUpdatedPrivate(items: items));
    });
  }

  Future<void> _onFetchJobsRequested(
    FetchJobsRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    try {
      final items = await _jobRepository.fetchJobs(forceRefresh: event.forceRefresh);
      emit(JobLoaded(items: items));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onAddJobRequested(
    AddJobRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    try {
      await _jobRepository.addJob(event.job);
      emit(JobOperationSuccess());
      add(const FetchJobsRequested(forceRefresh: true));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onUpdateJobRequested(
    UpdateJobRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    try {
      await _jobRepository.updateJob(event.job);
      emit(JobOperationSuccess());
      add(const FetchJobsRequested(forceRefresh: true));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onApproveJobRequested(
    ApproveJobRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    try {
      await _jobRepository.approveJob(event.itemId);
      emit(JobOperationSuccess());
      add(const FetchJobsRequested(forceRefresh: true));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onToggleJobVisibilityRequested(
    ToggleJobVisibilityRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    try {
      await _jobRepository.toggleJobVisibility(event.itemId, event.isVisible);
      emit(JobOperationSuccess());
      add(const FetchJobsRequested(forceRefresh: true));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  Future<void> _onDeleteJobRequested(
    DeleteJobRequested event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    try {
      await _jobRepository.deleteJob(event.itemId);
      emit(JobOperationSuccess());
      add(const FetchJobsRequested(forceRefresh: true));
    } catch (e) {
      emit(JobError(message: e.toString()));
    }
  }

  void _onJobsUpdatedPrivate(
    JobsUpdatedPrivate event,
    Emitter<JobState> emit,
  ) {
    emit(JobLoaded(items: event.items));
  }

  @override
  Future<void> close() {
    _jobSubscription?.cancel();
    return super.close();
  }
}

import 'package:equatable/equatable.dart';
import '../../models/job_state.dart';

abstract class JobEvent extends Equatable {
  const JobEvent();

  @override
  List<Object?> get props => [];
}

class FetchJobsRequested extends JobEvent {
  final bool forceRefresh;

  const FetchJobsRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddJobRequested extends JobEvent {
  final JobItem job;

  const AddJobRequested({required this.job});

  @override
  List<Object?> get props => [job];
}

class UpdateJobRequested extends JobEvent {
  final JobItem job;

  const UpdateJobRequested({required this.job});

  @override
  List<Object?> get props => [job];
}

class ApproveJobRequested extends JobEvent {
  final String itemId;

  const ApproveJobRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ToggleJobVisibilityRequested extends JobEvent {
  final String itemId;
  final bool isVisible;

  const ToggleJobVisibilityRequested({required this.itemId, required this.isVisible});

  @override
  List<Object?> get props => [itemId, isVisible];
}

class DeleteJobRequested extends JobEvent {
  final String itemId;

  const DeleteJobRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class JobsUpdatedPrivate extends JobEvent {
  final List<JobItem> items;

  const JobsUpdatedPrivate({required this.items});

  @override
  List<Object?> get props => [items];
}

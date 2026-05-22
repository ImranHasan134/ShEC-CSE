import 'package:equatable/equatable.dart';
import '../../models/job_state.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {
  final List<JobItem> items;

  const JobLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class JobOperationSuccess extends JobState {}

class JobError extends JobState {
  final String message;

  const JobError({required this.message});

  @override
  List<Object?> get props => [message];
}

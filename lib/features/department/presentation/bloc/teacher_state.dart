import 'package:equatable/equatable.dart';
import '../../models/teacher_state.dart';

abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {}

class TeacherLoaded extends TeacherState {
  final List<TeacherContact> teachers;

  const TeacherLoaded({required this.teachers});

  @override
  List<Object?> get props => [teachers];
}

class TeacherOperationSuccess extends TeacherState {}

class TeacherError extends TeacherState {
  final String message;

  const TeacherError({required this.message});

  @override
  List<Object?> get props => [message];
}

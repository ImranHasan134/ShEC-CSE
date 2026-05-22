import 'package:equatable/equatable.dart';
import '../../models/teacher_state.dart';

abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class FetchTeachersRequested extends TeacherEvent {
  final bool forceRefresh;

  const FetchTeachersRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddTeacherRequested extends TeacherEvent {
  final TeacherContact teacher;

  const AddTeacherRequested({required this.teacher});

  @override
  List<Object?> get props => [teacher];
}

class UpdateTeacherRequested extends TeacherEvent {
  final TeacherContact teacher;

  const UpdateTeacherRequested({required this.teacher});

  @override
  List<Object?> get props => [teacher];
}

class ToggleTeacherVisibilityRequested extends TeacherEvent {
  final String id;
  final bool isVisible;

  const ToggleTeacherVisibilityRequested({required this.id, required this.isVisible});

  @override
  List<Object?> get props => [id, isVisible];
}

class ApproveTeacherRequested extends TeacherEvent {
  final String id;

  const ApproveTeacherRequested({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteTeacherRequested extends TeacherEvent {
  final TeacherContact teacher;

  const DeleteTeacherRequested({required this.teacher});

  @override
  List<Object?> get props => [teacher];
}

class TeachersUpdatedPrivate extends TeacherEvent {
  final List<TeacherContact> teachers;

  const TeachersUpdatedPrivate({required this.teachers});

  @override
  List<Object?> get props => [teachers];
}

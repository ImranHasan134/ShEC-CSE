import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../../../backend/services/teacher_service.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository _teacherRepository;
  StreamSubscription? _teacherSubscription;

  TeacherBloc({required TeacherRepository teacherRepository})
      : _teacherRepository = teacherRepository,
        super(TeacherInitial()) {
    on<FetchTeachersRequested>(_onFetchTeachersRequested);
    on<AddTeacherRequested>(_onAddTeacherRequested);
    on<UpdateTeacherRequested>(_onUpdateTeacherRequested);
    on<ToggleTeacherVisibilityRequested>(_onToggleTeacherVisibilityRequested);
    on<ApproveTeacherRequested>(_onApproveTeacherRequested);
    on<DeleteTeacherRequested>(_onDeleteTeacherRequested);
    on<TeachersUpdatedPrivate>(_onTeachersUpdatedPrivate);

    _teacherSubscription = TeacherService.teachersStream.listen((teachers) {
      add(TeachersUpdatedPrivate(teachers: teachers));
    });
  }

  Future<void> _onFetchTeachersRequested(
    FetchTeachersRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      final teachers = await _teacherRepository.fetchTeachers(forceRefresh: event.forceRefresh);
      emit(TeacherLoaded(teachers: teachers));
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }

  Future<void> _onAddTeacherRequested(
    AddTeacherRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      await _teacherRepository.addTeacher(event.teacher);
      emit(TeacherOperationSuccess());
      add(const FetchTeachersRequested(forceRefresh: true));
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTeacherRequested(
    UpdateTeacherRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      await _teacherRepository.updateTeacher(event.teacher);
      emit(TeacherOperationSuccess());
      add(const FetchTeachersRequested(forceRefresh: true));
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }

  Future<void> _onToggleTeacherVisibilityRequested(
    ToggleTeacherVisibilityRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      await _teacherRepository.toggleTeacherVisibility(event.id, event.isVisible);
      emit(TeacherOperationSuccess());
      add(const FetchTeachersRequested(forceRefresh: true));
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }

  Future<void> _onApproveTeacherRequested(
    ApproveTeacherRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      await _teacherRepository.approveTeacher(event.id);
      emit(TeacherOperationSuccess());
      add(const FetchTeachersRequested(forceRefresh: true));
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTeacherRequested(
    DeleteTeacherRequested event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    try {
      await _teacherRepository.deleteTeacher(event.teacher);
      emit(TeacherOperationSuccess());
      add(const FetchTeachersRequested(forceRefresh: true));
    } catch (e) {
      emit(TeacherError(message: e.toString()));
    }
  }

  void _onTeachersUpdatedPrivate(
    TeachersUpdatedPrivate event,
    Emitter<TeacherState> emit,
  ) {
    emit(TeacherLoaded(teachers: event.teachers));
  }

  @override
  Future<void> close() {
    _teacherSubscription?.cancel();
    return super.close();
  }
}

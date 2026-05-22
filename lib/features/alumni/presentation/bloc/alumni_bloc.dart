import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'alumni_event.dart';
import 'alumni_state.dart';
import '../../domain/repositories/alumni_repository.dart';
import '../../../../backend/services/alumni_service.dart';

class AlumniBloc extends Bloc<AlumniEvent, AlumniState> {
  final AlumniRepository _alumniRepository;
  StreamSubscription? _alumniSubscription;

  AlumniBloc({required AlumniRepository alumniRepository})
      : _alumniRepository = alumniRepository,
        super(AlumniInitial()) {
    on<FetchAlumniRequested>(_onFetchAlumniRequested);
    on<AddAlumniRequested>(_onAddAlumniRequested);
    on<UpdateAlumniRequested>(_onUpdateAlumniRequested);
    on<ApproveAlumniRequested>(_onApproveAlumniRequested);
    on<ToggleAlumniVisibilityRequested>(_onToggleAlumniVisibilityRequested);
    on<DeleteAlumniRequested>(_onDeleteAlumniRequested);
    on<PromoteToAlumniRequested>(_onPromoteToAlumniRequested);
    on<AlumniUpdatedPrivate>(_onAlumniUpdatedPrivate);

    _alumniSubscription = AlumniService.alumniStream.listen((items) {
      add(AlumniUpdatedPrivate(items: items));
    });
  }

  Future<void> _onFetchAlumniRequested(
    FetchAlumniRequested event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      final items = await _alumniRepository.fetchAlumni(forceRefresh: event.forceRefresh);
      emit(AlumniLoaded(items: items));
    } catch (e) {
      emit(AlumniError(message: e.toString()));
    }
  }

  Future<void> _onAddAlumniRequested(
    AddAlumniRequested event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      await _alumniRepository.addAlumni(event.item);
      emit(AlumniOperationSuccess());
      add(const FetchAlumniRequested(forceRefresh: true));
    } catch (e) {
      emit(AlumniError(message: e.toString()));
    }
  }

  Future<void> _onUpdateAlumniRequested(
    UpdateAlumniRequested event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      await _alumniRepository.updateAlumni(event.item);
      emit(AlumniOperationSuccess());
      add(const FetchAlumniRequested(forceRefresh: true));
    } catch (e) {
      emit(AlumniError(message: e.toString()));
    }
  }

  Future<void> _onApproveAlumniRequested(
    ApproveAlumniRequested event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      await _alumniRepository.approveAlumni(event.itemId);
      emit(AlumniOperationSuccess());
      add(const FetchAlumniRequested(forceRefresh: true));
    } catch (e) {
      emit(AlumniError(message: e.toString()));
    }
  }

  Future<void> _onToggleAlumniVisibilityRequested(
    ToggleAlumniVisibilityRequested event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      await _alumniRepository.toggleAlumniVisibility(event.itemId, event.isVisible);
      emit(AlumniOperationSuccess());
      add(const FetchAlumniRequested(forceRefresh: true));
    } catch (e) {
      emit(AlumniError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAlumniRequested(
    DeleteAlumniRequested event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      await _alumniRepository.deleteAlumni(event.item);
      emit(AlumniOperationSuccess());
      add(const FetchAlumniRequested(forceRefresh: true));
    } catch (e) {
      emit(AlumniError(message: e.toString()));
    }
  }

  Future<void> _onPromoteToAlumniRequested(
    PromoteToAlumniRequested event,
    Emitter<AlumniState> emit,
  ) async {
    emit(AlumniLoading());
    try {
      await _alumniRepository.promoteToAlumni(event.memberId, event.alumniData);
      emit(AlumniOperationSuccess());
      add(const FetchAlumniRequested(forceRefresh: true));
    } catch (e) {
      emit(AlumniError(message: e.toString()));
    }
  }

  void _onAlumniUpdatedPrivate(
    AlumniUpdatedPrivate event,
    Emitter<AlumniState> emit,
  ) {
    emit(AlumniLoaded(items: event.items));
  }

  @override
  Future<void> close() {
    _alumniSubscription?.cancel();
    return super.close();
  }
}

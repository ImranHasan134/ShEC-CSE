import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'contest_event.dart';
import 'contest_state.dart';
import '../../domain/repositories/contest_repository.dart';
import '../../../../backend/services/contest_service.dart';

class ContestBloc extends Bloc<ContestEvent, ContestState> {
  final ContestRepository _contestRepository;
  StreamSubscription? _contestSubscription;

  ContestBloc({required ContestRepository contestRepository})
      : _contestRepository = contestRepository,
        super(ContestInitial()) {
    on<FetchContestsRequested>(_onFetchContestsRequested);
    on<AddContestRequested>(_onAddContestRequested);
    on<UpdateContestRequested>(_onUpdateContestRequested);
    on<ApproveContestRequested>(_onApproveContestRequested);
    on<ToggleContestVisibilityRequested>(_onToggleContestVisibilityRequested);
    on<DeleteContestRequested>(_onDeleteContestRequested);
    on<ContestsUpdatedPrivate>(_onContestsUpdatedPrivate);

    _contestSubscription = ContestService.contestStream.listen((items) {
      add(ContestsUpdatedPrivate(items: items));
    });
  }

  Future<void> _onFetchContestsRequested(
    FetchContestsRequested event,
    Emitter<ContestState> emit,
  ) async {
    emit(ContestLoading());
    try {
      final items = await _contestRepository.fetchContestsAndCourses(forceRefresh: event.forceRefresh);
      emit(ContestLoaded(items: items));
    } catch (e) {
      emit(ContestError(message: e.toString()));
    }
  }

  Future<void> _onAddContestRequested(
    AddContestRequested event,
    Emitter<ContestState> emit,
  ) async {
    emit(ContestLoading());
    try {
      await _contestRepository.addContest(event.item);
      emit(ContestOperationSuccess());
      add(const FetchContestsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContestError(message: e.toString()));
    }
  }

  Future<void> _onUpdateContestRequested(
    UpdateContestRequested event,
    Emitter<ContestState> emit,
  ) async {
    emit(ContestLoading());
    try {
      await _contestRepository.updateContest(event.item);
      emit(ContestOperationSuccess());
      add(const FetchContestsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContestError(message: e.toString()));
    }
  }

  Future<void> _onApproveContestRequested(
    ApproveContestRequested event,
    Emitter<ContestState> emit,
  ) async {
    emit(ContestLoading());
    try {
      await _contestRepository.approveContest(event.itemId);
      emit(ContestOperationSuccess());
      add(const FetchContestsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContestError(message: e.toString()));
    }
  }

  Future<void> _onToggleContestVisibilityRequested(
    ToggleContestVisibilityRequested event,
    Emitter<ContestState> emit,
  ) async {
    emit(ContestLoading());
    try {
      await _contestRepository.toggleContestVisibility(event.itemId, event.isVisible);
      emit(ContestOperationSuccess());
      add(const FetchContestsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContestError(message: e.toString()));
    }
  }

  Future<void> _onDeleteContestRequested(
    DeleteContestRequested event,
    Emitter<ContestState> emit,
  ) async {
    emit(ContestLoading());
    try {
      await _contestRepository.deleteContest(event.item);
      emit(ContestOperationSuccess());
      add(const FetchContestsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContestError(message: e.toString()));
    }
  }

  void _onContestsUpdatedPrivate(
    ContestsUpdatedPrivate event,
    Emitter<ContestState> emit,
  ) {
    emit(ContestLoaded(items: event.items));
  }

  @override
  Future<void> close() {
    _contestSubscription?.cancel();
    return super.close();
  }
}

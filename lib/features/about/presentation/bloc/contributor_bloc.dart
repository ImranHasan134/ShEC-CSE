import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/contributor_repository.dart';
import 'contributor_event.dart';
import 'contributor_state.dart';

class ContributorBloc extends Bloc<ContributorEvent, ContributorState> {
  final ContributorRepository _repository;

  ContributorBloc(this._repository) : super(ContributorInitial()) {
    on<FetchContributorsRequested>(_onFetchContributorsRequested);
    on<AddContributorRequested>(_onAddContributorRequested);
    on<UpdateContributorRequested>(_onUpdateContributorRequested);
    on<DeleteContributorRequested>(_onDeleteContributorRequested);
  }

  Future<void> _onFetchContributorsRequested(
    FetchContributorsRequested event,
    Emitter<ContributorState> emit,
  ) async {
    emit(ContributorLoading());
    try {
      final list = await _repository.getContributors(forceRefresh: event.forceRefresh);
      emit(ContributorsLoaded(contributors: list));
    } catch (e) {
      emit(ContributorError(message: e.toString()));
    }
  }

  Future<void> _onAddContributorRequested(
    AddContributorRequested event,
    Emitter<ContributorState> emit,
  ) async {
    emit(ContributorLoading());
    try {
      await _repository.addContributor(event.item);
      emit(const ContributorOperationSuccess(message: 'Contributor added successfully!'));
      add(const FetchContributorsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContributorError(message: e.toString()));
    }
  }

  Future<void> _onUpdateContributorRequested(
    UpdateContributorRequested event,
    Emitter<ContributorState> emit,
  ) async {
    emit(ContributorLoading());
    try {
      await _repository.updateContributor(event.item);
      emit(const ContributorOperationSuccess(message: 'Contributor updated successfully!'));
      add(const FetchContributorsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContributorError(message: e.toString()));
    }
  }

  Future<void> _onDeleteContributorRequested(
    DeleteContributorRequested event,
    Emitter<ContributorState> emit,
  ) async {
    emit(ContributorLoading());
    try {
      await _repository.deleteContributor(event.item);
      emit(const ContributorOperationSuccess(message: 'Contributor deleted successfully!'));
      add(const FetchContributorsRequested(forceRefresh: true));
    } catch (e) {
      emit(ContributorError(message: e.toString()));
    }
  }
}

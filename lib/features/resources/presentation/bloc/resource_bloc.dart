import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'resource_event.dart';
import 'resource_state.dart';
import '../../domain/repositories/resource_repository.dart';
import '../../../../backend/services/resource_service.dart';

class ResourceBloc extends Bloc<ResourceEvent, ResourceState> {
  final ResourceRepository _resourceRepository;
  StreamSubscription? _resourceSubscription;

  ResourceBloc({required ResourceRepository resourceRepository})
      : _resourceRepository = resourceRepository,
        super(ResourceInitial()) {
    on<FetchResourcesRequested>(_onFetchResourcesRequested);
    on<AddResourceRequested>(_onAddResourceRequested);
    on<UpdateResourceRequested>(_onUpdateResourceRequested);
    on<DeleteResourceRequested>(_onDeleteResourceRequested);
    on<ResourcesUpdatedPrivate>(_onResourcesUpdatedPrivate);

    _resourceSubscription = ResourceService.resourcesStream.listen((items) {
      add(ResourcesUpdatedPrivate(items: items));
    });
  }

  Future<void> _onFetchResourcesRequested(
    FetchResourcesRequested event,
    Emitter<ResourceState> emit,
  ) async {
    emit(ResourceLoading());
    try {
      final items = await _resourceRepository.fetchResources(forceRefresh: event.forceRefresh);
      emit(ResourceLoaded(items: items));
    } catch (e) {
      emit(ResourceError(message: e.toString()));
    }
  }

  Future<void> _onAddResourceRequested(
    AddResourceRequested event,
    Emitter<ResourceState> emit,
  ) async {
    emit(ResourceLoading());
    try {
      await _resourceRepository.addResource(event.item);
      emit(ResourceOperationSuccess());
      add(const FetchResourcesRequested(forceRefresh: true));
    } catch (e) {
      emit(ResourceError(message: e.toString()));
    }
  }

  Future<void> _onUpdateResourceRequested(
    UpdateResourceRequested event,
    Emitter<ResourceState> emit,
  ) async {
    emit(ResourceLoading());
    try {
      await _resourceRepository.updateResource(event.item);
      emit(ResourceOperationSuccess());
      add(const FetchResourcesRequested(forceRefresh: true));
    } catch (e) {
      emit(ResourceError(message: e.toString()));
    }
  }

  Future<void> _onDeleteResourceRequested(
    DeleteResourceRequested event,
    Emitter<ResourceState> emit,
  ) async {
    emit(ResourceLoading());
    try {
      await _resourceRepository.deleteResource(event.item);
      emit(ResourceOperationSuccess());
      add(const FetchResourcesRequested(forceRefresh: true));
    } catch (e) {
      emit(ResourceError(message: e.toString()));
    }
  }

  void _onResourcesUpdatedPrivate(
    ResourcesUpdatedPrivate event,
    Emitter<ResourceState> emit,
  ) {
    emit(ResourceLoaded(items: event.items));
  }

  @override
  Future<void> close() {
    _resourceSubscription?.cancel();
    return super.close();
  }
}

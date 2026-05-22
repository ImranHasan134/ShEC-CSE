import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../models/gallery_state.dart';
import '../../../../backend/services/gallery_service.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryRepository _galleryRepository;
  StreamSubscription? _gallerySubscription;

  GalleryBloc({required GalleryRepository galleryRepository})
      : _galleryRepository = galleryRepository,
        super(GalleryInitial()) {
    on<FetchGalleryItemsRequested>(_onFetchGalleryItemsRequested);
    on<AddGalleryItemRequested>(_onAddGalleryItemRequested);
    on<UpdateGalleryItemRequested>(_onUpdateGalleryItemRequested);
    on<ApproveGalleryItemRequested>(_onApproveGalleryItemRequested);
    on<ToggleGalleryVisibilityRequested>(_onToggleGalleryVisibilityRequested);
    on<DeleteGalleryItemRequested>(_onDeleteGalleryItemRequested);
    on<GalleryItemsUpdatedPrivate>(_onGalleryItemsUpdatedPrivate);

    _gallerySubscription = GalleryService.galleryStream.listen((items) {
      add(GalleryItemsUpdatedPrivate(items: items));
    });
  }

  Future<void> _onFetchGalleryItemsRequested(
    FetchGalleryItemsRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      final items = await _galleryRepository.fetchGalleryItems(forceRefresh: event.forceRefresh);
      emit(GalleryLoaded(items: items));
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onAddGalleryItemRequested(
    AddGalleryItemRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      await _galleryRepository.addGalleryItem(event.item);
      emit(GalleryOperationSuccess());
      add(const FetchGalleryItemsRequested(forceRefresh: true));
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateGalleryItemRequested(
    UpdateGalleryItemRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      await _galleryRepository.updateGalleryItem(event.item);
      emit(GalleryOperationSuccess());
      add(const FetchGalleryItemsRequested(forceRefresh: true));
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onApproveGalleryItemRequested(
    ApproveGalleryItemRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      await _galleryRepository.approveGalleryItem(event.itemId);
      emit(GalleryOperationSuccess());
      add(const FetchGalleryItemsRequested(forceRefresh: true));
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onToggleGalleryVisibilityRequested(
    ToggleGalleryVisibilityRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      await _galleryRepository.toggleGalleryVisibility(event.itemId, event.isVisible);
      emit(GalleryOperationSuccess());
      add(const FetchGalleryItemsRequested(forceRefresh: true));
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  Future<void> _onDeleteGalleryItemRequested(
    DeleteGalleryItemRequested event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());
    try {
      await _galleryRepository.deleteGalleryItem(event.item);
      emit(GalleryOperationSuccess());
      add(const FetchGalleryItemsRequested(forceRefresh: true));
    } catch (e) {
      emit(GalleryError(message: e.toString()));
    }
  }

  void _onGalleryItemsUpdatedPrivate(
    GalleryItemsUpdatedPrivate event,
    Emitter<GalleryState> emit,
  ) {
    emit(GalleryLoaded(items: event.items));
  }

  @override
  Future<void> close() {
    _gallerySubscription?.cancel();
    return super.close();
  }
}

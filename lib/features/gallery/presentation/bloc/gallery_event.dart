import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../models/gallery_state.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object?> get props => [];
}

class FetchGalleryItemsRequested extends GalleryEvent {
  final bool forceRefresh;

  const FetchGalleryItemsRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddGalleryItemRequested extends GalleryEvent {
  final GalleryItem item;

  const AddGalleryItemRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdateGalleryItemRequested extends GalleryEvent {
  final GalleryItem item;

  const UpdateGalleryItemRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class ApproveGalleryItemRequested extends GalleryEvent {
  final String itemId;

  const ApproveGalleryItemRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ToggleGalleryVisibilityRequested extends GalleryEvent {
  final String itemId;
  final bool isVisible;

  const ToggleGalleryVisibilityRequested({required this.itemId, required this.isVisible});

  @override
  List<Object?> get props => [itemId, isVisible];
}

class DeleteGalleryItemRequested extends GalleryEvent {
  final GalleryItem item;

  const DeleteGalleryItemRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class GalleryItemsUpdatedPrivate extends GalleryEvent {
  final List<GalleryItem> items;

  const GalleryItemsUpdatedPrivate({required this.items});

  @override
  List<Object?> get props => [items];
}

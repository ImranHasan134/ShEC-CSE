import 'package:equatable/equatable.dart';
import '../../models/gallery_state.dart';

abstract class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object?> get props => [];
}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<GalleryItem> items;

  const GalleryLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class GalleryOperationSuccess extends GalleryState {}

class GalleryError extends GalleryState {
  final String message;

  const GalleryError({required this.message});

  @override
  List<Object?> get props => [message];
}

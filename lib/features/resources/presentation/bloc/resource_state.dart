import 'package:equatable/equatable.dart';
import '../../models/resource_state.dart';

abstract class ResourceState extends Equatable {
  const ResourceState();

  @override
  List<Object?> get props => [];
}

class ResourceInitial extends ResourceState {}

class ResourceLoading extends ResourceState {}

class ResourceLoaded extends ResourceState {
  final List<ResourceItem> items;

  const ResourceLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class ResourceOperationSuccess extends ResourceState {}

class ResourceError extends ResourceState {
  final String message;

  const ResourceError({required this.message});

  @override
  List<Object?> get props => [message];
}

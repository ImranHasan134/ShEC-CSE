import 'package:equatable/equatable.dart';
import '../../models/resource_state.dart';

abstract class ResourceEvent extends Equatable {
  const ResourceEvent();

  @override
  List<Object?> get props => [];
}

class FetchResourcesRequested extends ResourceEvent {
  final bool forceRefresh;

  const FetchResourcesRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddResourceRequested extends ResourceEvent {
  final ResourceItem item;

  const AddResourceRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdateResourceRequested extends ResourceEvent {
  final ResourceItem item;

  const UpdateResourceRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class DeleteResourceRequested extends ResourceEvent {
  final ResourceItem item;

  const DeleteResourceRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class ResourcesUpdatedPrivate extends ResourceEvent {
  final List<ResourceItem> items;

  const ResourcesUpdatedPrivate({required this.items});

  @override
  List<Object?> get props => [items];
}

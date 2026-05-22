import 'package:equatable/equatable.dart';
import '../../models/alumni_state.dart';

abstract class AlumniEvent extends Equatable {
  const AlumniEvent();

  @override
  List<Object?> get props => [];
}

class FetchAlumniRequested extends AlumniEvent {
  final bool forceRefresh;

  const FetchAlumniRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddAlumniRequested extends AlumniEvent {
  final AlumniItem item;

  const AddAlumniRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdateAlumniRequested extends AlumniEvent {
  final AlumniItem item;

  const UpdateAlumniRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class ApproveAlumniRequested extends AlumniEvent {
  final String itemId;

  const ApproveAlumniRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ToggleAlumniVisibilityRequested extends AlumniEvent {
  final String itemId;
  final bool isVisible;

  const ToggleAlumniVisibilityRequested({required this.itemId, required this.isVisible});

  @override
  List<Object?> get props => [itemId, isVisible];
}

class DeleteAlumniRequested extends AlumniEvent {
  final AlumniItem item;

  const DeleteAlumniRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class PromoteToAlumniRequested extends AlumniEvent {
  final String memberId;
  final AlumniItem alumniData;

  const PromoteToAlumniRequested({required this.memberId, required this.alumniData});

  @override
  List<Object?> get props => [memberId, alumniData];
}

class AlumniUpdatedPrivate extends AlumniEvent {
  final List<AlumniItem> items;

  const AlumniUpdatedPrivate({required this.items});

  @override
  List<Object?> get props => [items];
}

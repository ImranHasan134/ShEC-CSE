import 'package:equatable/equatable.dart';
import '../../models/contest_state.dart';

abstract class ContestEvent extends Equatable {
  const ContestEvent();

  @override
  List<Object?> get props => [];
}

class FetchContestsRequested extends ContestEvent {
  final bool forceRefresh;

  const FetchContestsRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddContestRequested extends ContestEvent {
  final ContestItem item;

  const AddContestRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdateContestRequested extends ContestEvent {
  final ContestItem item;

  const UpdateContestRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class ApproveContestRequested extends ContestEvent {
  final String itemId;

  const ApproveContestRequested({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class ToggleContestVisibilityRequested extends ContestEvent {
  final String itemId;
  final bool isVisible;

  const ToggleContestVisibilityRequested({required this.itemId, required this.isVisible});

  @override
  List<Object?> get props => [itemId, isVisible];
}

class DeleteContestRequested extends ContestEvent {
  final ContestItem item;

  const DeleteContestRequested({required this.item});

  @override
  List<Object?> get props => [item];
}

class ContestsUpdatedPrivate extends ContestEvent {
  final List<ContestItem> items;

  const ContestsUpdatedPrivate({required this.items});

  @override
  List<Object?> get props => [items];
}

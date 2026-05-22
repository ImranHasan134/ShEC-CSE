import 'package:equatable/equatable.dart';
import '../../domain/entities/contributor_item.dart';

abstract class ContributorEvent extends Equatable {
  const ContributorEvent();

  @override
  List<Object?> get props => [];
}

class FetchContributorsRequested extends ContributorEvent {
  final bool forceRefresh;
  const FetchContributorsRequested({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddContributorRequested extends ContributorEvent {
  final ContributorItem item;
  const AddContributorRequested(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateContributorRequested extends ContributorEvent {
  final ContributorItem item;
  const UpdateContributorRequested(this.item);

  @override
  List<Object?> get props => [item];
}

class DeleteContributorRequested extends ContributorEvent {
  final ContributorItem item;
  const DeleteContributorRequested(this.item);

  @override
  List<Object?> get props => [item];
}

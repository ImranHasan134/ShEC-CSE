import 'package:equatable/equatable.dart';
import '../../domain/entities/contributor_item.dart';

abstract class ContributorState extends Equatable {
  const ContributorState();

  @override
  List<Object?> get props => [];
}

class ContributorInitial extends ContributorState {}

class ContributorLoading extends ContributorState {}

class ContributorsLoaded extends ContributorState {
  final List<ContributorItem> contributors;
  const ContributorsLoaded({required this.contributors});

  @override
  List<Object?> get props => [contributors];
}

class ContributorError extends ContributorState {
  final String message;
  const ContributorError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ContributorOperationSuccess extends ContributorState {
  final String message;
  const ContributorOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

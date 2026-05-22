import 'package:equatable/equatable.dart';
import '../../models/contest_state.dart';

abstract class ContestState extends Equatable {
  const ContestState();

  @override
  List<Object?> get props => [];
}

class ContestInitial extends ContestState {}

class ContestLoading extends ContestState {}

class ContestLoaded extends ContestState {
  final List<ContestItem> items;

  const ContestLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class ContestOperationSuccess extends ContestState {}

class ContestError extends ContestState {
  final String message;

  const ContestError({required this.message});

  @override
  List<Object?> get props => [message];
}

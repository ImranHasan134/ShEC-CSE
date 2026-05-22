import 'package:equatable/equatable.dart';
import '../../models/alumni_state.dart';

abstract class AlumniState extends Equatable {
  const AlumniState();

  @override
  List<Object?> get props => [];
}

class AlumniInitial extends AlumniState {}

class AlumniLoading extends AlumniState {}

class AlumniLoaded extends AlumniState {
  final List<AlumniItem> items;

  const AlumniLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class AlumniOperationSuccess extends AlumniState {}

class AlumniError extends AlumniState {
  final String message;

  const AlumniError({required this.message});

  @override
  List<Object?> get props => [message];
}

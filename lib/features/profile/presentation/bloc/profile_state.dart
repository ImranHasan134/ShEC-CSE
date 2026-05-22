import 'package:equatable/equatable.dart';
import '../../models/profile_state.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileData profile;
  final List<ProfileData> members;

  const ProfileLoaded({required this.profile, this.members = const []});

  @override
  List<Object?> get props => [profile, members];
}

class ProfileOperationSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

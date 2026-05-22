import 'package:equatable/equatable.dart';
import '../../models/profile_state.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfileRequested extends ProfileEvent {
  const FetchProfileRequested();
}

class UpdateMyProfileRequested extends ProfileEvent {
  final ProfileData profile;

  const UpdateMyProfileRequested({required this.profile});

  @override
  List<Object?> get props => [profile];
}

class FetchMembersRequested extends ProfileEvent {
  const FetchMembersRequested();
}

class UpdateMemberRoleRequested extends ProfileEvent {
  final String userId;
  final UserRole role;
  final String? designation;

  const UpdateMemberRoleRequested({
    required this.userId,
    required this.role,
    this.designation,
  });

  @override
  List<Object?> get props => [userId, role, designation];
}

class ApproveMemberRequested extends ProfileEvent {
  final String userId;

  const ApproveMemberRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class DeleteMemberRequested extends ProfileEvent {
  final String userId;

  const DeleteMemberRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class MoveMemberToAlumniRequested extends ProfileEvent {
  final ProfileData member;

  const MoveMemberToAlumniRequested({required this.member});

  @override
  List<Object?> get props => [member];
}

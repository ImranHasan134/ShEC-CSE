import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../models/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<FetchProfileRequested>(_onFetchProfileRequested);
    on<UpdateMyProfileRequested>(_onUpdateMyProfileRequested);
    on<FetchMembersRequested>(_onFetchMembersRequested);
    on<UpdateMemberRoleRequested>(_onUpdateMemberRoleRequested);
    on<ApproveMemberRequested>(_onApproveMemberRequested);
    on<DeleteMemberRequested>(_onDeleteMemberRequested);
    on<MoveMemberToAlumniRequested>(_onMoveMemberToAlumniRequested);
  }

  Future<void> _onFetchProfileRequested(
    FetchProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.fetchCurrentUserProfile();
      final profile = currentProfile.value;
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMyProfileRequested(
    UpdateMyProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.updateProfile(event.profile);
      final profile = currentProfile.value;
      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onFetchMembersRequested(
    FetchMembersRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final members = await _profileRepository.fetchAllMembers();
      final profile = currentProfile.value;
      emit(ProfileLoaded(profile: profile, members: members));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onUpdateMemberRoleRequested(
    UpdateMemberRoleRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.updateUserRole(
        event.userId,
        event.role,
        designation: event.designation,
      );
      emit(ProfileOperationSuccess());
      add(const FetchMembersRequested());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onApproveMemberRequested(
    ApproveMemberRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.approveUser(event.userId);
      emit(ProfileOperationSuccess());
      add(const FetchMembersRequested());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onDeleteMemberRequested(
    DeleteMemberRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.deleteUser(event.userId);
      emit(ProfileOperationSuccess());
      add(const FetchMembersRequested());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<void> _onMoveMemberToAlumniRequested(
    MoveMemberToAlumniRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      await _profileRepository.moveToAlumni(event.member);
      emit(ProfileOperationSuccess());
      add(const FetchMembersRequested());
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}

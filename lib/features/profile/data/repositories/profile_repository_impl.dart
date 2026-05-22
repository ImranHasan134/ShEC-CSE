import '../../domain/repositories/profile_repository.dart';
import '../../models/profile_state.dart';
import '../../../../backend/services/auth_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<void> fetchCurrentUserProfile() {
    return AuthService.fetchCurrentUserProfile();
  }

  @override
  Future<void> updateProfile(ProfileData profile) {
    return AuthService.updateProfile(profile);
  }

  @override
  Future<List<ProfileData>> fetchAllMembers() {
    return AuthService.fetchAllMembers();
  }

  @override
  Future<void> updateUserRole(String userId, UserRole newRole, {String? designation}) {
    return AuthService.updateUserRole(userId, newRole, designation: designation);
  }

  @override
  Future<void> approveUser(String userId) {
    return AuthService.approveUser(userId);
  }

  @override
  Future<void> deleteUser(String userId) {
    return AuthService.deleteUser(userId);
  }

  @override
  Future<void> moveToAlumni(ProfileData member) {
    return AuthService.moveToAlumni(member);
  }
}

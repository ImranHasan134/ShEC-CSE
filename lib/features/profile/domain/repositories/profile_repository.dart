import '../../models/profile_state.dart';

abstract class ProfileRepository {
  Future<void> fetchCurrentUserProfile();
  Future<void> updateProfile(ProfileData profile);
  Future<List<ProfileData>> fetchAllMembers();
  Future<void> updateUserRole(String userId, UserRole newRole, {String? designation});
  Future<void> approveUser(String userId);
  Future<void> deleteUser(String userId);
  Future<void> moveToAlumni(ProfileData member);
}

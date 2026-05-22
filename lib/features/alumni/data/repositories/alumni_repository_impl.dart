import 'dart:io';
import '../../domain/repositories/alumni_repository.dart';
import '../../models/alumni_state.dart';
import '../../../../backend/services/alumni_service.dart';

class AlumniRepositoryImpl implements AlumniRepository {
  @override
  Future<List<AlumniItem>> fetchAlumni({bool forceRefresh = false}) async {
    return AlumniService.fetchAlumni(forceRefresh: forceRefresh);
  }

  @override
  Future<void> addAlumni(AlumniItem item) async {
    await AlumniService.addAlumni(item);
  }

  @override
  Future<void> updateAlumni(AlumniItem item) async {
    await AlumniService.updateAlumni(item);
  }

  @override
  Future<void> approveAlumni(String id) async {
    await AlumniService.approveAlumni(id);
  }

  @override
  Future<void> toggleAlumniVisibility(String id, bool isVisible) async {
    await AlumniService.toggleAlumniVisibility(id, isVisible);
  }

  @override
  Future<void> deleteAlumni(AlumniItem item) async {
    await AlumniService.deleteAlumni(item);
  }

  @override
  Future<void> promoteToAlumni(String memberId, AlumniItem alumniData) async {
    await AlumniService.promoteToAlumni(memberId, alumniData);
  }

  @override
  Future<String?> uploadImage(File file) async {
    return AlumniService.uploadImage(file);
  }
}

import 'dart:io';
import '../../models/alumni_state.dart';

abstract class AlumniRepository {
  Future<List<AlumniItem>> fetchAlumni({bool forceRefresh = false});
  Future<void> addAlumni(AlumniItem item);
  Future<void> updateAlumni(AlumniItem item);
  Future<void> approveAlumni(String id);
  Future<void> toggleAlumniVisibility(String id, bool isVisible);
  Future<void> deleteAlumni(AlumniItem item);
  Future<void> promoteToAlumni(String memberId, AlumniItem alumniData);
  Future<String?> uploadImage(File file);
}

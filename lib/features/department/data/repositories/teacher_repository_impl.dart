import '../../domain/repositories/teacher_repository.dart';
import '../../models/teacher_state.dart';
import '../../../../backend/services/teacher_service.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  @override
  Future<List<TeacherContact>> fetchTeachers({bool forceRefresh = false}) {
    return TeacherService.fetchTeachers(forceRefresh: forceRefresh);
  }

  @override
  Future<void> addTeacher(TeacherContact teacher) {
    return TeacherService.addTeacher(teacher);
  }

  @override
  Future<void> updateTeacher(TeacherContact teacher) {
    return TeacherService.updateTeacher(teacher);
  }

  @override
  Future<void> approveTeacher(String id) {
    return TeacherService.approveTeacher(id);
  }

  @override
  Future<void> toggleTeacherVisibility(String id, bool isVisible) {
    return TeacherService.toggleTeacherVisibility(id, isVisible);
  }

  @override
  Future<void> deleteTeacher(TeacherContact teacher) {
    return TeacherService.deleteTeacher(teacher);
  }
}

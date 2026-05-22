import '../../models/teacher_state.dart';

abstract class TeacherRepository {
  Future<List<TeacherContact>> fetchTeachers({bool forceRefresh = false});
  Future<void> addTeacher(TeacherContact teacher);
  Future<void> updateTeacher(TeacherContact teacher);
  Future<void> approveTeacher(String id);
  Future<void> toggleTeacherVisibility(String id, bool isVisible);
  Future<void> deleteTeacher(TeacherContact teacher);
}

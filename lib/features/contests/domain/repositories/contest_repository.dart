import '../../models/contest_state.dart';

abstract class ContestRepository {
  Future<List<ContestItem>> fetchContestsAndCourses({bool forceRefresh = false});
  Future<void> addContest(ContestItem item);
  Future<void> updateContest(ContestItem item);
  Future<void> approveContest(String id);
  Future<void> toggleContestVisibility(String id, bool isVisible);
  Future<void> deleteContest(ContestItem item);
}

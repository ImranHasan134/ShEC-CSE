import '../../domain/repositories/contest_repository.dart';
import '../../models/contest_state.dart';
import '../../../../backend/services/contest_service.dart';

class ContestRepositoryImpl implements ContestRepository {
  @override
  Future<List<ContestItem>> fetchContestsAndCourses({bool forceRefresh = false}) async {
    return ContestService.fetchContestsAndCourses(forceRefresh: forceRefresh);
  }

  @override
  Future<void> addContest(ContestItem item) async {
    await ContestService.addContestToDB(item);
  }

  @override
  Future<void> updateContest(ContestItem item) async {
    await ContestService.updateContestInDB(item);
  }

  @override
  Future<void> approveContest(String id) async {
    await ContestService.approveContest(id);
  }

  @override
  Future<void> toggleContestVisibility(String id, bool isVisible) async {
    await ContestService.toggleContestVisibility(id, isVisible);
  }

  @override
  Future<void> deleteContest(ContestItem item) async {
    await ContestService.deleteContestFromDB(item);
  }
}

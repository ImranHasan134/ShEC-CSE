import 'dart:io';
import '../entities/contributor_item.dart';

abstract class ContributorRepository {
  Future<List<ContributorItem>> getContributors({bool forceRefresh = false});
  Future<void> addContributor(ContributorItem item);
  Future<void> updateContributor(ContributorItem item);
  Future<void> deleteContributor(ContributorItem item);
  Future<String?> uploadImage(File file);
}

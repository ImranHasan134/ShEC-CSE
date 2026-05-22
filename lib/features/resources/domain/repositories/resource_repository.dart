import '../../models/resource_state.dart';

abstract class ResourceRepository {
  Future<List<ResourceItem>> fetchResources({bool forceRefresh = false});
  Future<void> addResource(ResourceItem item);
  Future<void> updateResource(ResourceItem item);
  Future<void> deleteResource(ResourceItem item);
}

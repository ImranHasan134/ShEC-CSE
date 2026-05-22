import '../../domain/repositories/resource_repository.dart';
import '../../models/resource_state.dart';
import '../../../../backend/services/resource_service.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  @override
  Future<List<ResourceItem>> fetchResources({bool forceRefresh = false}) {
    return ResourceService.fetchResources(forceRefresh: forceRefresh);
  }

  @override
  Future<void> addResource(ResourceItem item) {
    return ResourceService.addResourceToDB(item);
  }

  @override
  Future<void> updateResource(ResourceItem item) {
    return ResourceService.updateResourceInDB(item);
  }

  @override
  Future<void> deleteResource(ResourceItem item) {
    return ResourceService.deleteResourceFromDB(item);
  }
}

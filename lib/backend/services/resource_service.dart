import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/resources/models/resource_state.dart';
import '../../core/services/cache_service.dart';

class ResourceService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<ResourceItem> _resources = [];

  static final StreamController<List<ResourceItem>> _resourcesStreamController = StreamController.broadcast();
  static Stream<List<ResourceItem>> get resourcesStream => _resourcesStreamController.stream;

  static List<ResourceItem> get resources => _resources;

  static Future<List<ResourceItem>> fetchResources({bool forceRefresh = false}) async {
    if (!forceRefresh && !CacheService.isStale(CacheKeys.resources) && _resources.isNotEmpty) return _resources;

    final response = await _client
        .from('resources')
        .select()
        .order('created_at', ascending: false);

    _resources = (response as List).map((row) => ResourceItem.fromJson(row)).toList();

    _resourcesStreamController.add(_resources);
    CacheService.markFresh(CacheKeys.resources);
    return _resources;
  }

  static Future<void> addResourceToDB(ResourceItem item) async {
    final data = item.toJson();
    final response = await _client
        .from('resources')
        .insert(data)
        .select()
        .single();

    final newItem = ResourceItem.fromJson(response);
    _resources = List.from(_resources)..insert(0, newItem);
    _resourcesStreamController.add(_resources);
    CacheService.invalidate(CacheKeys.resources);
  }

  static Future<void> updateResourceInDB(ResourceItem item) async {
    final data = item.toJson();
    await _client
        .from('resources')
        .update(data)
        .eq('id', item.id);
    
    _resources = _resources.map((i) => i.id == item.id ? item : i).toList();
    _resourcesStreamController.add(_resources);
    CacheService.invalidate(CacheKeys.resources);
  }

  static Future<void> deleteResourceFromDB(ResourceItem item) async {
    await _client
        .from('resources')
        .delete()
        .eq('id', item.id);

    _resources = List.from(_resources)..removeWhere((i) => i.id == item.id);
    _resourcesStreamController.add(_resources);
    CacheService.invalidate(CacheKeys.resources);
  }
}

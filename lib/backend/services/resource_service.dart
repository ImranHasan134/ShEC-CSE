import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/resources/models/resource_state.dart';
import '../../core/services/cache_service.dart';
import '../../core/services/database_helper.dart';
import '../../core/services/connectivity_service.dart';

class ResourceService {
  static final SupabaseClient _client = Supabase.instance.client;
  static List<ResourceItem> _resources = [];

  static final StreamController<List<ResourceItem>> _resourcesStreamController = StreamController.broadcast();
  static Stream<List<ResourceItem>> get resourcesStream => _resourcesStreamController.stream;

  static List<ResourceItem> get resources => _resources;

  static Future<List<ResourceItem>> fetchResources({bool forceRefresh = false}) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      final cachedResourcesStr = await DatabaseHelper.instance.getCache('resources');
      if (cachedResourcesStr != null) {
        try {
          final List decoded = json.decode(cachedResourcesStr);
          _resources = decoded.map((row) => ResourceItem.fromJson(row)).toList();
          _resourcesStreamController.add(_resources);
          debugPrint('Successfully loaded resources from local SQLite database.');
          return _resources;
        } catch (e) {
          debugPrint('Error deserializing cached resources: $e');
        }
      }
      return _resources;
    }

    if (!forceRefresh && !CacheService.isStale(CacheKeys.resources) && _resources.isNotEmpty) return _resources;

    final response = await _client
        .from('resources')
        .select()
        .order('created_at', ascending: false);

    _resources = (response as List).map((row) => ResourceItem.fromJson(row)).toList();

    _resourcesStreamController.add(_resources);
    CacheService.markFresh(CacheKeys.resources);

    // Save to SQLite
    await DatabaseHelper.instance.saveCache('resources', json.encode(response));

    return _resources;
  }

  static Future<void> addResourceToDB(ResourceItem item) async {
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to upload resources.');
      throw Exception('Network connection required');
    }
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
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to update resources.');
      throw Exception('Network connection required');
    }
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
    final isOnline = await ConnectivityService.hasInternet();
    if (!isOnline) {
      ConnectivityService.showNoInternetToast(message: 'Internet connection required to delete resources.');
      throw Exception('Network connection required');
    }
    await _client
        .from('resources')
        .delete()
        .eq('id', item.id);

    _resources = List.from(_resources)..removeWhere((i) => i.id == item.id);
    _resourcesStreamController.add(_resources);
    CacheService.invalidate(CacheKeys.resources);
  }
}

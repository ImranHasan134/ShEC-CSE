import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, 'shec_cache.db');

    return await openDatabase(
      pathString,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_cache (
        key TEXT PRIMARY KEY,
        data TEXT,
        updated_at INTEGER
      )
    ''');
  }

  /// Inserts or replaces a cached JSON string for a given key.
  Future<void> saveCache(String key, String jsonData) async {
    try {
      final db = await database;
      await db.insert(
        'offline_cache',
        {
          'key': key,
          'data': jsonData,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('SQLite saveCache error ($key): $e');
    }
  }

  /// Retrieves the cached JSON string for a given key. Returns null if not cached.
  Future<String?> getCache(String key) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'offline_cache',
        columns: ['data'],
        where: 'key = ?',
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        return maps.first['data'] as String?;
      }
    } catch (e) {
      debugPrint('SQLite getCache error ($key): $e');
    }
    return null;
  }

  /// Deletes a specific key cache from the database.
  Future<void> clearCache(String key) async {
    try {
      final db = await database;
      await db.delete(
        'offline_cache',
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      debugPrint('SQLite clearCache error ($key): $e');
    }
  }

  /// Deletes all cached records from the database.
  Future<void> clearAll() async {
    try {
      final db = await database;
      await db.delete('offline_cache');
    } catch (e) {
      debugPrint('SQLite clearAll error: $e');
    }
  }
}

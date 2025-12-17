import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paypulse/core/errors/exceptions.dart';

abstract class StorageService {
  Future<void> init();
  
  // String operations
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  
  // Int operations
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  
  // Double operations
  Future<void> saveDouble(String key, double value);
  Future<double?> getDouble(String key);
  
  // Bool operations
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  
  // Object operations (JSON)
  Future<void> saveObject(String key, Map<String, dynamic> value);
  Future<Map<String, dynamic>?> getObject(String key);
  
  // List operations
  Future<void> saveList(String key, List<dynamic> value);
  Future<List<dynamic>?> getList(String key);
  
  // Delete operations
  Future<void> delete(String key);
  Future<void> clearAll();
  
  // Utility
  Future<bool> containsKey(String key);
}

class StorageServiceImpl implements StorageService {
  static const String _prefsPrefix = 'paypulse_';
  static const String _hiveBoxName = 'app_storage';
  
  late SharedPreferences _prefs;
  late Box<dynamic> _hiveBox;

  @override
  Future<void> init() async {
    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register adapters
      _registerAdapters();
      
      // Open Hive box
      _hiveBox = await Hive.openBox<dynamic>(_hiveBoxName);
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize storage: $e',
        data: {'error': e.toString()},
      );
    }
  }

  void _registerAdapters() {
    // Register custom Hive adapters here
    // Example: Hive.registerAdapter(UserModelAdapter());
  }

  String _getPrefsKey(String key) => '$_prefsPrefix$key';

  @override
  Future<void> saveString(String key, String value) async {
    try {
      await _prefs.setString(_getPrefsKey(key), value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save string: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(_getPrefsKey(key));
    } catch (e) {
      throw CacheException(
        message: 'Failed to get string: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> saveInt(String key, int value) async {
    try {
      await _prefs.setInt(_getPrefsKey(key), value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save int: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(_getPrefsKey(key));
    } catch (e) {
      throw CacheException(
        message: 'Failed to get int: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    try {
      await _prefs.setDouble(_getPrefsKey(key), value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save double: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(_getPrefsKey(key));
    } catch (e) {
      throw CacheException(
        message: 'Failed to get double: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    try {
      await _prefs.setBool(_getPrefsKey(key), value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save bool: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(_getPrefsKey(key));
    } catch (e) {
      throw CacheException(
        message: 'Failed to get bool: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> saveObject(String key, Map<String, dynamic> value) async {
    try {
      // Convert to JSON string for Hive storage
      final jsonString = json.encode(value);
      await _hiveBox.put(key, jsonString);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save object: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final jsonString = _hiveBox.get(key);
      if (jsonString == null) return null;
      
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get object: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> saveList(String key, List<dynamic> value) async {
    try {
      // Convert to JSON string for Hive storage
      final jsonString = json.encode(value);
      await _hiveBox.put(key, jsonString);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save list: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<List<dynamic>?> getList(String key) async {
    try {
      final jsonString = _hiveBox.get(key);
      if (jsonString == null) return null;
      
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get list: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      // Delete from both storage systems
      await _prefs.remove(_getPrefsKey(key));
      await _hiveBox.delete(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete key: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      // Get all keys with prefix
      final allKeys = _prefs.getKeys().where((key) => key.startsWith(_prefsPrefix));
      
      // Remove all prefixed keys
      for (final key in allKeys) {
        await _prefs.remove(key);
      }
      
      // Clear Hive box
      await _hiveBox.clear();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all data: $e',
        data: {'error': e.toString()},
      );
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _prefs.containsKey(_getPrefsKey(key)) || _hiveBox.containsKey(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to check key existence: $e',
        data: {'key': key, 'error': e.toString()},
      );
    }
  }
  
  // Utility methods for specific data types
  
  Future<void> saveDateTime(String key, DateTime value) async {
    await saveString(key, value.toIso8601String());
  }
  
  Future<DateTime?> getDateTime(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return DateTime.parse(value);
  }
  
  Future<void> saveEnum<T extends Enum>(String key, T value) async {
    await saveString(key, value.name);
  }
  
  Future<T?> getEnum<T extends Enum>(String key, List<T> values) async {
    final value = await getString(key);
    if (value == null) return null;
    
    try {
      return values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}
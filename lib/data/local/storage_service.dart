import 'package:hive/hive.dart';

/// A service that provides a high-level abstraction for interacting with Hive.
class StorageService {
  final HiveInterface _hive;

  StorageService({HiveInterface? hive}) : _hive = hive ?? Hive;

  /// Opens a Hive box.
  Future<Box<T>> openBox<T>(String name) async {
    return await _hive.openBox<T>(name);
  }

  /// Closes a Hive box.
  Future<void> closeBox(String name) async {
    final box = await openBox(name);
    await box.close();
  }

  /// Gets a value from a Hive box.
  Future<T?> get<T>(String boxName, String key) async {
    final box = await openBox<T>(boxName);
    return box.get(key);
  }

  /// Puts a value into a Hive box.
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await openBox<T>(boxName);
    await box.put(key, value);
  }

  /// Deletes a value from a Hive box.
  Future<void> delete<T>(String boxName, String key) async {
    final box = await openBox<T>(boxName);
    await box.delete(key);
  }

  /// Clears a Hive box.
  Future<void> clear<T>(String boxName) async {
    final box = await openBox<T>(boxName);
    await box.clear();
  }
}

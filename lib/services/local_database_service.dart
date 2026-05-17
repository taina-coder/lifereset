import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabaseService {
  static const String _databaseFileName = 'life_reset_database.json';
  static const String _migrationFlag = 'database_migrated_from_preferences';

  static Future<File> get _databaseFile async {
    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return File('${directory.path}/$_databaseFileName');
  }

  static Future<Map<String, dynamic>> _readAll() async {
    try {
      final file = await _databaseFile;
      if (!await file.exists()) return {};

      final content = await file.readAsString();
      if (content.trim().isEmpty) return {};

      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) return decoded;
      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    final file = await _databaseFile;
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final data = await _readAll();
    final prefsKeys = prefs.getKeys();

    if (prefsKeys.isNotEmpty) {
      for (final key in prefsKeys) {
        if (key == _migrationFlag) continue;
        data[key] = prefs.get(key);
      }

      data[_migrationFlag] = true;
      await _writeAll(data);
      await prefs.clear();
    } else if (!data.containsKey(_migrationFlag)) {
      data[_migrationFlag] = true;
      await _writeAll(data);
    }

    await clearCache();
  }

  static Future<T?> getValue<T>(String key) async {
    final data = await _readAll();
    final value = data[key];
    if (value is T) return value;
    return null;
  }

  static Future<void> setValue(String key, Object? value) async {
    final data = await _readAll();
    data[key] = value;
    await _writeAll(data);
  }

  static Future<void> remove(String key) async {
    final data = await _readAll();
    data.remove(key);
    await _writeAll(data);
  }

  static Future<List<String>> getStringList(String key) async {
    final value = await getValue<List<dynamic>>(key);
    if (value == null) return [];
    return value.map((item) => item.toString()).toList();
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await setValue(key, value);
  }

  static Future<Set<String>> getKeys() async {
    final data = await _readAll();
    return data.keys.toSet();
  }

  static Future<void> clearDatabase() async {
    final file = await _databaseFile;
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    try {
      final cacheDirectory = await getTemporaryDirectory();
      if (!await cacheDirectory.exists()) return;

      await for (final entity in cacheDirectory.list()) {
        await entity.delete(recursive: true);
      }
    } catch (_) {
      // A limpeza de cache nao deve impedir o app de abrir.
    }
  }

  static Future<File> copyFileToDatabaseDirectory(
    String sourcePath,
    String fileName,
  ) async {
    final source = File(sourcePath);
    final databaseFile = await _databaseFile;
    final directory = databaseFile.parent;
    final target = File('${directory.path}/$fileName');
    if (source.path == target.path) return source;
    return source.copy(target.path);
  }
}

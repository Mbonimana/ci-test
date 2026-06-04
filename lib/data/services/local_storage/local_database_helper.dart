import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabaseHelper {
  static const String _syncTimestampKey = 'last_sync_timestamp';
  static const String _fileName = 'murugo_locations.json';

  static Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static Future<String?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_syncTimestampKey);
  }

  static Future<void> saveLastSyncTimestamp(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncTimestampKey, timestamp);
  }

  static Future<Map<String, dynamic>> readLocations() async {
    try {
      final file = await _file;
      if (!await file.exists()) return {};
      final contents = await file.readAsString();
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  static Future<void> writeLocations(Map<String, dynamic> data) async {
    try {
      final file = await _file;
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:street_team/core/utils/talker_helper.dart';

class AuthStorageService {
  AuthStorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save
  static Future<void> write({
    required String key,
    required String value,
  }) async {
    talker.debug('SECURE STORAGE WRITE => $key');
    await _storage.write(key: key, value: value);
  }

  // READ
  static Future<String?> read(String key) async {
    final value = await _storage.read(key: key);
    return value;
  }

  // clear
  static Future<void> clear() async {
    talker.warning('clearing auth storage');
    await _storage.deleteAll();
  }
}

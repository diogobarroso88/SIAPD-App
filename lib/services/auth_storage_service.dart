import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  static const String _activeUserUuidKey = 'active_user_uuid';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setActiveUserUuid(String uuid) async {
    await _storage.write(
      key: _activeUserUuidKey,
      value: uuid,
    );
  }

  Future<String?> getActiveUserUuid() async {
    return _storage.read(
      key: _activeUserUuidKey,
    );
  }

  Future<void> saveToken(String userUuid, String token) async {
    await _storage.write(
      key: 'token_$userUuid',
      value: token,
    );
  }

  Future<String?> getToken(String userUuid) async {
    return _storage.read(
      key: 'token_$userUuid',
    );
  }

  Future<void> removeToken(String userUuid) async {
    await _storage.delete(
      key: 'token_$userUuid',
    );
  }

  Future<void> clearActiveUser() async {
    await _storage.delete(
      key: _activeUserUuidKey,
    );
  }
}
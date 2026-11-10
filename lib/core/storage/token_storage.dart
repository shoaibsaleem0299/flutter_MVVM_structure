import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class TokenStorage {
  TokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  String? get cachedAccessToken => _cachedAccessToken;
  String? get cachedRefreshToken => _cachedRefreshToken;

  Future<String?> readAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: AppConstants.accessTokenKey);
    return _cachedAccessToken;
  }

  Future<String?> readRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    _cachedRefreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
    return _cachedRefreshToken;
  }

  Future<void> saveAccessToken(String token) async {
    _cachedAccessToken = token;
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    _cachedRefreshToken = token;
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _cachedAccessToken = accessToken;
    await _storage.write(key: AppConstants.accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      _cachedRefreshToken = refreshToken;
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
    }
  }

  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await _storage.deleteAll();
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  ),
);

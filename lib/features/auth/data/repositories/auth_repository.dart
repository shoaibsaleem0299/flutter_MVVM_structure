import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/typedefs.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

/// Talks to the API through [ApiService]. No UI or state logic here.
class AuthRepository {
  AuthRepository(this._api, this._tokens);
  final ApiService _api;
  final TokenStorage _tokens;

  Future<UserModel> login(LoginRequest request) async {
    final response = await _api.post<AuthResponse>(
      ApiEndpoints.login,
      body: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data as Json),
    );
    final auth = response.data!;
    await _tokens.saveAccessToken(auth.token);
    return auth.user;
  }

  /// Returns the saved session's user, or null if signed out / expired.
  Future<UserModel?> restoreSession() async {
    if (await _tokens.readAccessToken() == null) return null;
    try {
      final response = await _api.get<UserModel>(
        ApiEndpoints.me,
        fromJson: (data) => UserModel.fromJson(data as Json),
      );
      return response.data;
    } catch (_) {
      await _tokens.clear();
      return null;
    }
  }

  Future<void> logout() => _tokens.clear();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiServiceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

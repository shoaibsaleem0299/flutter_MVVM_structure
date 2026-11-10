import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

/// Talks to the API through [ApiService]. Implements [IAuthRepository].
class AuthRepository implements IAuthRepository {
  AuthRepository(this._api, this._tokens);
  final ApiService _api;
  final TokenStorage _tokens;

  @override
  Future<UserModel> login(
    LoginRequest request, {
    CancelToken? cancelToken,
  }) async {
    final response = await _api.post<AuthResponse>(
      ApiEndpoints.login,
      body: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data as Json),
      cancelToken: cancelToken,
    );
    final auth = response.data;
    if (auth == null) {
      throw const ServerFailure('Invalid authentication response from server');
    }
    await _tokens.saveAccessToken(auth.token);
    return auth.user;
  }

  /// Returns the saved session's user, or null if signed out / expired.
  /// Does NOT wipe tokens on transient network failure.
  @override
  Future<UserModel?> restoreSession({CancelToken? cancelToken}) async {
    final token = await _tokens.readAccessToken();
    if (token == null) return null;
    try {
      final response = await _api.get<UserModel>(
        ApiEndpoints.me,
        fromJson: (data) => UserModel.fromJson(data as Json),
        cancelToken: cancelToken,
      );
      return response.data;
    } on UnauthorizedFailure {
      await _tokens.clear();
      return null;
    } on NetworkFailure {
      // Preserve session tokens on network error; notify coordinator
      rethrow;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() => _tokens.clear();
}

final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiServiceProvider),
    ref.watch(tokenStorageProvider),
  ),
);

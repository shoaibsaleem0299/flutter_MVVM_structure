import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokens,
    this.onSessionExpired,
  }) : _tokens = tokens;

  final TokenStorage _tokens;
  final void Function()? onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _tokens.cachedAccessToken ?? await _tokens.readAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final isAuthEndpoint =
        err.requestOptions.path.contains(ApiEndpoints.login);

    if (statusCode == 401 && !isAuthEndpoint) {
      await _tokens.clear();
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}

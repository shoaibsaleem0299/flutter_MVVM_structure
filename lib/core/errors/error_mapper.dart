import 'package:dio/dio.dart';

import 'failures.dart';

Failure mapError(Object error) {
  if (error is Failure) return error;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      default:
        final code = error.response?.statusCode;
        if (code == 401) return const UnauthorizedFailure();
        return ServerFailure(
          error.response?.statusMessage ?? 'Server error',
          code,
        );
    }
  }
  return UnknownFailure(error.toString());
}

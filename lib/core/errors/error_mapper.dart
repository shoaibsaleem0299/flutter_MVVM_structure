import 'package:dio/dio.dart';

import '../utils/typedefs.dart';
import 'failures.dart';

Failure mapError(Object error) {
  if (error is Failure) return error;
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return const CanceledFailure();
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Certificate verification failed');
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      default:
        final code = error.response?.statusCode;
        String? message;
        final resData = error.response?.data;
        if (resData is Json) {
          message = resData['message'] as String?;
        }
        message ??= error.response?.statusMessage ?? 'Server error';

        if (code == 401) return UnauthorizedFailure(message);
        return ServerFailure(message, code);
    }
  }
  return const UnknownFailure('Something went wrong. Please try again.');
}

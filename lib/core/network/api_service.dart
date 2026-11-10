import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/error_mapper.dart';
import '../errors/failures.dart';
import '../utils/typedefs.dart';
import 'api_response.dart';
import 'dio_client.dart';

/// The ONLY class in the app that talks to the network.
///
/// Repositories call `get / post / put / patch / delete` and receive a typed
/// [ApiResponse<T>]. Any failure is thrown as a [Failure] (see core/errors).
class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Json? query,
    T Function(dynamic data)? fromJson,
    CancelToken? cancelToken,
  }) =>
      request<T>(
        'GET',
        path,
        query: query,
        fromJson: fromJson,
        cancelToken: cancelToken,
      );

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
    CancelToken? cancelToken,
  }) =>
      request<T>(
        'POST',
        path,
        body: body,
        query: query,
        fromJson: fromJson,
        cancelToken: cancelToken,
      );

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
    CancelToken? cancelToken,
  }) =>
      request<T>(
        'PUT',
        path,
        body: body,
        query: query,
        fromJson: fromJson,
        cancelToken: cancelToken,
      );

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
    CancelToken? cancelToken,
  }) =>
      request<T>(
        'PATCH',
        path,
        body: body,
        query: query,
        fromJson: fromJson,
        cancelToken: cancelToken,
      );

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
    CancelToken? cancelToken,
  }) =>
      request<T>(
        'DELETE',
        path,
        body: body,
        query: query,
        fromJson: fromJson,
        cancelToken: cancelToken,
      );

  Future<ApiResponse<T>> request<T>(
    String method,
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
    CancelToken? cancelToken,
  }) async {
    final raw = await _send(
      method,
      path,
      body: body,
      query: query,
      cancelToken: cancelToken,
    );
    if (raw is Json) {
      return ApiResponse<T>.fromJson(raw, fromJson);
    }
    return ApiResponse<T>(
      code: 200,
      status: true,
      message: null,
      data: fromJson != null && raw != null ? fromJson(raw) : raw as T?,
    );
  }

  Future<ApiResponse<T>> upload<T>(
    String path,
    FormData formData, {
    Json? query,
    T Function(dynamic data)? fromJson,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        path,
        data: formData,
        queryParameters: query,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      final raw = res.data;
      if (raw is Json) {
        return ApiResponse<T>.fromJson(raw, fromJson);
      }
      return ApiResponse<T>(
        code: res.statusCode ?? 200,
        status: true,
        message: null,
        data: fromJson != null && raw != null ? fromJson(raw) : raw as T?,
      );
    } catch (e) {
      throw mapError(e);
    }
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Json? query,
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(method: method),
      );

      final data = res.data;
      if (data is Json) {
        final status = data['status'];
        final code = data['code'] as int?;
        final isFailure = (status == false) ||
            (status is String &&
                (status.toLowerCase() == 'error' ||
                    status.toLowerCase() == 'failed')) ||
            (code != null && code >= 400);

        if (isFailure) {
          final message = data['message'] as String? ?? 'Request failed';
          throw ServerFailure(message, code ?? res.statusCode);
        }
      }

      return data;
    } catch (e) {
      throw mapError(e);
    }
  }
}

final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(ref.watch(dioProvider)));

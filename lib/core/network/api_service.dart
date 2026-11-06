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
  }) =>
      request<T>('GET', path, query: query, fromJson: fromJson);

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
  }) =>
      request<T>('POST', path, body: body, query: query, fromJson: fromJson);

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
  }) =>
      request<T>('PUT', path, body: body, query: query, fromJson: fromJson);

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
  }) =>
      request<T>('PATCH', path, body: body, query: query, fromJson: fromJson);

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
  }) =>
      request<T>('DELETE', path, body: body, query: query, fromJson: fromJson);

  Future<ApiResponse<T>> request<T>(
    String method,
    String path, {
    Object? body,
    Json? query,
    T Function(dynamic data)? fromJson,
  }) async {
    final raw = await _send(method, path, body: body, query: query);
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

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Json? query,
  }) async {
    try {
      final res = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
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

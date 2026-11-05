import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../errors/error_mapper.dart';
import '../utils/typedefs.dart';
import 'dio_client.dart';

/// The ONLY class in the app that talks to the network.
///
/// Repositories call `get / post / put / patch / delete` and receive decoded
/// JSON. Any failure is thrown as a [Failure] (see core/errors).
class ApiService {
  ApiService(this._dio);
  final Dio _dio;

  Future<Json> get(String path, {Json? query}) =>
      _json('GET', path, query: query);

  Future<Json> post(String path, {Object? body, Json? query}) =>
      _json('POST', path, body: body, query: query);

  Future<Json> put(String path, {Object? body, Json? query}) =>
      _json('PUT', path, body: body, query: query);

  Future<Json> patch(String path, {Object? body, Json? query}) =>
      _json('PATCH', path, body: body, query: query);

  Future<Json> delete(String path, {Object? body, Json? query}) =>
      _json('DELETE', path, body: body, query: query);

  /// For endpoints that return a JSON array.
  Future<List<dynamic>> getList(String path, {Json? query}) async {
    final data = await _send('GET', path, query: query);
    return data is List ? data : <dynamic>[];
  }

  Future<Json> _json(
    String method,
    String path, {
    Object? body,
    Json? query,
  }) async {
    final data = await _send(method, path, body: body, query: query);
    if (data is Json) return data;
    if (data == null) return <String, dynamic>{};
    return {'data': data};
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
      return res.data;
    } catch (e) {
      throw mapError(e);
    }
  }
}

final apiServiceProvider =
    Provider<ApiService>((ref) => ApiService(ref.watch(dioProvider)));

import '../utils/typedefs.dart';

/// Generic envelope matching backend responses:
/// `{ "code": 200, "status": true, "message": "...", "data": ... }`
class ApiResponse<T> {
  const ApiResponse({
    this.code,
    this.status,
    this.message,
    this.data,
  });

  final int? code;
  final dynamic status;
  final String? message;
  final T? data;

  bool get isSuccess {
    if (status is bool) return status == true;
    if (status is String) {
      final s = status.toLowerCase();
      return s == 'success' || s == 'true' || s == 'ok';
    }
    if (code != null) return code! >= 200 && code! < 300;
    return true;
  }

  factory ApiResponse.fromJson(
    Json json, [
    T Function(dynamic data)? fromJsonT,
  ]) {
    final rawData = json['data'];
    return ApiResponse<T>(
      code: json['code'] as int?,
      status: json['status'],
      message: json['message'] as String?,
      data: (fromJsonT != null && rawData != null)
          ? fromJsonT(rawData)
          : (rawData as T?),
    );
  }
}


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/controllers/auth_coordinator.dart';
import '../config/env.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

BaseOptions _createBaseOptions() => BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      sendTimeout: AppConstants.requestTimeout,
      headers: {'Accept': 'application/json'},
    );

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(_createBaseOptions());
  final tokens = ref.watch(tokenStorageProvider);

  dio.interceptors.add(
    AuthInterceptor(
      tokens: tokens,
      onSessionExpired: () {
        ref.read(authCoordinatorProvider.notifier).forceLogout();
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  return dio;
});

import 'package:dio/dio.dart';

import '../../data/models/login_request.dart';
import '../../data/models/user_model.dart';

abstract interface class IAuthRepository {
  Future<UserModel> login(LoginRequest request, {CancelToken? cancelToken});
  Future<UserModel?> restoreSession({CancelToken? cancelToken});
  Future<void> logout();
}

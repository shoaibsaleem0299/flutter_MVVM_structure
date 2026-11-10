import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/repositories/i_home_repository.dart';
import '../models/dashboard_profile_model.dart';

/// Concrete repository implementation for Dashboard data.
/// Talks exclusively to ApiService; zero coupling to the Auth feature.
class HomeRepository implements IHomeRepository {
  HomeRepository(this._api);
  final ApiService _api;

  @override
  Future<DashboardProfileModel> getDashboardProfile({
    CancelToken? cancelToken,
  }) async {
    final response = await _api.get<DashboardProfileModel>(
      ApiEndpoints.me,
      fromJson: (data) => DashboardProfileModel.fromJson(data as Json),
      cancelToken: cancelToken,
    );

    final profile = response.data;
    if (profile == null) {
      throw const ServerFailure('Failed to load dashboard profile details');
    }
    return profile;
  }
}

final homeRepositoryProvider = Provider<IHomeRepository>(
  (ref) => HomeRepository(ref.watch(apiServiceProvider)),
);

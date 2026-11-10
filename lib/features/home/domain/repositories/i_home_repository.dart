import 'package:dio/dio.dart';

import '../../data/models/dashboard_profile_model.dart';

abstract interface class IHomeRepository {
  Future<DashboardProfileModel> getDashboardProfile({CancelToken? cancelToken});
}

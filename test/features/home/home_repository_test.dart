import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/network/api_endpoints.dart';
import 'package:hotworx_uhf/core/network/api_response.dart';
import 'package:hotworx_uhf/core/network/api_service.dart';
import 'package:hotworx_uhf/features/home/data/models/dashboard_profile_model.dart';
import 'package:hotworx_uhf/features/home/data/repositories/home_repository.dart';
import 'package:hotworx_uhf/features/home/domain/repositories/i_home_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService api;
  late IHomeRepository repository;

  setUp(() {
    api = MockApiService();
    repository = HomeRepository(api);
  });

  group('HomeRepository', () {
    test('getDashboardProfile returns parsed DashboardProfileModel', () async {
      when(
        () => api.get<DashboardProfileModel>(
          ApiEndpoints.me,
          fromJson: any(named: 'fromJson'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const ApiResponse<DashboardProfileModel>(
          code: 200,
          status: true,
          message: 'Profile retrieved successfully',
          data: DashboardProfileModel(
            id: '3',
            name: 'Shoaib Saleem',
            email: 'shoaib@gmail.com',
            role: 'Customer',
            status: 'approved',
            profile: DashboardProfileDetails(
              cnic: '44444-4444444-4',
              bankName: 'Meezan',
              tradingAccountNo: 'UHF',
            ),
          ),
        ),
      );

      final result = await repository.getDashboardProfile();

      expect(result.id, '3');
      expect(result.name, 'Shoaib Saleem');
      expect(result.email, 'shoaib@gmail.com');
      expect(result.role, 'Customer');
      expect(result.profile?.bankName, 'Meezan');
      expect(result.profile?.tradingAccountNo, 'UHF');
      expect(result.initials, 'SS');
      expect(result.isApproved, isTrue);
    });
  });
}

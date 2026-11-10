import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/errors/failures.dart';
import 'package:hotworx_uhf/features/home/data/models/dashboard_profile_model.dart';
import 'package:hotworx_uhf/features/home/data/repositories/home_repository.dart';
import 'package:hotworx_uhf/features/home/domain/repositories/i_home_repository.dart';
import 'package:hotworx_uhf/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements IHomeRepository {}

void main() {
  late MockHomeRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockHomeRepository();
    container = ProviderContainer(
      overrides: [
        homeRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('HomeViewModel', () {
    const mockProfile = DashboardProfileModel(
      id: '3',
      name: 'Shoaib Saleem',
      email: 'shoaib@gmail.com',
      role: 'Customer',
      status: 'approved',
    );

    test('loadDashboard updates state with profile on success', () async {
      when(() => repo.getDashboardProfile(cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => mockProfile);

      final vm = container.read(homeViewModelProvider.notifier);
      await vm.loadDashboard();

      final state = container.read(homeViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.profile?.id, '3');
      expect(state.profile?.name, 'Shoaib Saleem');
      expect(state.errorMessage, isNull);
    });

    test('loadDashboard updates state with error message on Failure', () async {
      when(() => repo.getDashboardProfile(cancelToken: any(named: 'cancelToken')))
          .thenThrow(const ServerFailure('Server unavailable', 500));

      final vm = container.read(homeViewModelProvider.notifier);
      await vm.loadDashboard();

      final state = container.read(homeViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.profile, isNull);
      expect(state.errorMessage, 'Server unavailable');
    });

    test('clearError resets error message', () async {
      when(() => repo.getDashboardProfile(cancelToken: any(named: 'cancelToken')))
          .thenThrow(const NetworkFailure('No connection'));

      final vm = container.read(homeViewModelProvider.notifier);
      await vm.loadDashboard();

      expect(container.read(homeViewModelProvider).errorMessage, 'No connection');

      vm.clearError();
      expect(container.read(homeViewModelProvider).errorMessage, isNull);
    });
  });
}

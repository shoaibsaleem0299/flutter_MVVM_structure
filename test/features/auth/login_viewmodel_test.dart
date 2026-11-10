import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/errors/failures.dart';
import 'package:hotworx_uhf/features/auth/data/models/login_request.dart';
import 'package:hotworx_uhf/features/auth/data/models/user_model.dart';
import 'package:hotworx_uhf/features/auth/data/repositories/auth_repository.dart';
import 'package:hotworx_uhf/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:hotworx_uhf/features/auth/presentation/controllers/auth_coordinator.dart';
import 'package:hotworx_uhf/features/auth/presentation/viewmodels/login_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = MockAuthRepository();
    registerFallbackValue(
      const LoginRequest(email: 'test@example.com', password: 'password'),
    );
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('LoginViewModel', () {
    test('initial state is not loading and has no error', () {
      final state = container.read(loginViewModelProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('login success updates state and notifies auth coordinator', () async {
      const user = UserModel(id: '1', email: 'user@test.com', name: 'User');
      when(() => repo.login(any())).thenAnswer((_) async => user);

      final vm = container.read(loginViewModelProvider.notifier);
      final success = await vm.login(
        email: 'user@test.com',
        password: 'password123',
      );

      expect(success, isTrue);
      expect(container.read(loginViewModelProvider).isLoading, isFalse);
      expect(container.read(loginViewModelProvider).errorMessage, isNull);

      final session = container.read(authCoordinatorProvider);
      expect(session.status, AuthStatus.authenticated);
      expect(session.user?.email, 'user@test.com');
    });

    test('login failure updates state with error message', () async {
      when(() => repo.login(any())).thenThrow(
        const ServerFailure('Invalid credentials', 401),
      );

      final vm = container.read(loginViewModelProvider.notifier);
      final success = await vm.login(
        email: 'bad@test.com',
        password: 'wrong',
      );

      expect(success, isFalse);
      expect(container.read(loginViewModelProvider).isLoading, isFalse);
      expect(
        container.read(loginViewModelProvider).errorMessage,
        'Invalid credentials',
      );
    });

    test('clearError resets errorMessage to null', () async {
      when(() => repo.login(any())).thenThrow(
        const ServerFailure('Error', 400),
      );

      final vm = container.read(loginViewModelProvider.notifier);
      await vm.login(email: 'a@b.com', password: '123');
      expect(container.read(loginViewModelProvider).errorMessage, 'Error');

      vm.clearError();
      expect(container.read(loginViewModelProvider).errorMessage, isNull);
    });
  });
}

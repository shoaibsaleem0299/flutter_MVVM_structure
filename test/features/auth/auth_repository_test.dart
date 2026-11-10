import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/errors/failures.dart';
import 'package:hotworx_uhf/core/network/api_endpoints.dart';
import 'package:hotworx_uhf/core/network/api_response.dart';
import 'package:hotworx_uhf/core/network/api_service.dart';
import 'package:hotworx_uhf/core/storage/token_storage.dart';
import 'package:hotworx_uhf/features/auth/data/models/auth_response.dart';
import 'package:hotworx_uhf/features/auth/data/models/login_request.dart';
import 'package:hotworx_uhf/features/auth/data/models/user_model.dart';
import 'package:hotworx_uhf/features/auth/data/repositories/auth_repository.dart';
import 'package:hotworx_uhf/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockApiService api;
  late MockTokenStorage tokens;
  late IAuthRepository repository;

  setUp(() {
    api = MockApiService();
    tokens = MockTokenStorage();
    repository = AuthRepository(api, tokens);
  });

  group('AuthRepository', () {
    test('login saves token and returns user', () async {
      when(
        () => api.post<AuthResponse>(
          ApiEndpoints.login,
          body: any(named: 'body'),
          fromJson: any(named: 'fromJson'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => const ApiResponse<AuthResponse>(
          code: 200,
          status: true,
          message: 'Success',
          data: AuthResponse(
            token: 'abc',
            user: UserModel(id: '1', email: 'a@b.com'),
          ),
        ),
      );
      when(() => tokens.saveAccessToken('abc')).thenAnswer((_) async {});

      final user = await repository
          .login(const LoginRequest(email: 'a@b.com', password: '123456'));

      expect(user.email, 'a@b.com');
      verify(() => tokens.saveAccessToken('abc')).called(1);
    });

    test('restoreSession clears tokens on UnauthorizedFailure', () async {
      when(() => tokens.readAccessToken()).thenAnswer((_) async => 'expired_token');
      when(
        () => api.get<UserModel>(
          ApiEndpoints.me,
          fromJson: any(named: 'fromJson'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(const UnauthorizedFailure('Session expired'));
      when(() => tokens.clear()).thenAnswer((_) async {});

      final user = await repository.restoreSession();

      expect(user, isNull);
      verify(() => tokens.clear()).called(1);
    });

    test('restoreSession does NOT clear tokens on NetworkFailure', () async {
      when(() => tokens.readAccessToken()).thenAnswer((_) async => 'valid_token');
      when(
        () => api.get<UserModel>(
          ApiEndpoints.me,
          fromJson: any(named: 'fromJson'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenThrow(const NetworkFailure('No internet connection'));

      expect(() => repository.restoreSession(), throwsA(isA<NetworkFailure>()));
      verifyNever(() => tokens.clear());
    });

    test('logout clears tokens', () async {
      when(() => tokens.clear()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => tokens.clear()).called(1);
    });
  });
}

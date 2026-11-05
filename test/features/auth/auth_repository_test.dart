import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotworx_uhf/core/network/api_endpoints.dart';
import 'package:hotworx_uhf/core/network/api_service.dart';
import 'package:hotworx_uhf/core/storage/token_storage.dart';
import 'package:hotworx_uhf/features/auth/data/models/login_request.dart';
import 'package:hotworx_uhf/features/auth/data/repositories/auth_repository.dart';

class MockApiService extends Mock implements ApiService {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  test('login saves token and returns user', () async {
    final api = MockApiService();
    final tokens = MockTokenStorage();
    when(() => api.post(ApiEndpoints.login, body: any(named: 'body')))
        .thenAnswer(
      (_) async => {
        'token': 'abc',
        'user': {'id': 1, 'email': 'a@b.com'},
      },
    );
    when(() => tokens.saveAccessToken('abc')).thenAnswer((_) async {});

    final user = await AuthRepository(api, tokens)
        .login(const LoginRequest(email: 'a@b.com', password: '123456'));

    expect(user.email, 'a@b.com');
    verify(() => tokens.saveAccessToken('abc')).called(1);
  });
}

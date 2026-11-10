import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/network/auth_interceptor.dart';
import 'package:hotworx_uhf/core/storage/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockTokenStorage extends Mock implements TokenStorage {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late MockTokenStorage tokens;
  late AuthInterceptor interceptor;
  late bool sessionExpiredCalled;

  setUp(() {
    tokens = MockTokenStorage();
    sessionExpiredCalled = false;
    interceptor = AuthInterceptor(
      tokens: tokens,
      onSessionExpired: () {
        sessionExpiredCalled = true;
      },
    );
  });

  group('AuthInterceptor', () {
    test('onRequest attaches bearer token when token is available', () async {
      when(() => tokens.cachedAccessToken).thenReturn('test_bearer_token');
      final options = RequestOptions(path: '/profile');
      final handler = MockRequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer test_bearer_token');
      verify(() => handler.next(options)).called(1);
    });

    test('onError on 401 clears tokens and triggers onSessionExpired',
        () async {
      final requestOptions = RequestOptions(path: '/api/me');
      final error = DioException(
        requestOptions: requestOptions,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );
      final handler = MockErrorInterceptorHandler();

      when(() => tokens.clear()).thenAnswer((_) async {});

      await interceptor.onError(error, handler);

      verify(() => tokens.clear()).called(1);
      expect(sessionExpiredCalled, isTrue);
      verify(() => handler.next(error)).called(1);
    });
  });
}

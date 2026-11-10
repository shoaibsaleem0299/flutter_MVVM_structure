import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/constants/app_constants.dart';
import 'package:hotworx_uhf/core/storage/token_storage.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage secureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    secureStorage = MockFlutterSecureStorage();
    tokenStorage = TokenStorage(secureStorage);
  });

  group('TokenStorage', () {
    test('readAccessToken uses cache after first read', () async {
      when(
        () => secureStorage.read(key: AppConstants.accessTokenKey),
      ).thenAnswer((_) async => 'cached_token_123');

      final firstRead = await tokenStorage.readAccessToken();
      expect(firstRead, 'cached_token_123');
      expect(tokenStorage.cachedAccessToken, 'cached_token_123');

      // Second read should come directly from memory cache
      final secondRead = await tokenStorage.readAccessToken();
      expect(secondRead, 'cached_token_123');

      verify(
        () => secureStorage.read(key: AppConstants.accessTokenKey),
      ).called(1);
    });

    test('saveTokens updates both cache and secure storage', () async {
      when(
        () => secureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await tokenStorage.saveTokens(
        accessToken: 'access_abc',
        refreshToken: 'refresh_xyz',
      );

      expect(tokenStorage.cachedAccessToken, 'access_abc');
      expect(tokenStorage.cachedRefreshToken, 'refresh_xyz');

      verify(
        () => secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: 'access_abc',
        ),
      ).called(1);
      verify(
        () => secureStorage.write(
          key: AppConstants.refreshTokenKey,
          value: 'refresh_xyz',
        ),
      ).called(1);
    });

    test('clear wipes memory cache and calls deleteAll', () async {
      when(() => secureStorage.deleteAll()).thenAnswer((_) async {});
      when(
        () => secureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await tokenStorage.saveTokens(
        accessToken: 'token_to_clear',
      );
      expect(tokenStorage.cachedAccessToken, 'token_to_clear');

      await tokenStorage.clear();

      expect(tokenStorage.cachedAccessToken, isNull);
      expect(tokenStorage.cachedRefreshToken, isNull);
      verify(() => secureStorage.deleteAll()).called(1);
    });
  });
}

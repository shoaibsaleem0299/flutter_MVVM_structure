import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotworx_uhf/core/errors/failures.dart';
import 'package:hotworx_uhf/core/network/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ApiService apiService;

  setUp(() {
    mockDio = MockDio();
    apiService = ApiService(mockDio);
  });

  test('parses success envelope {code, status, message, data}', () async {
    when(
      () => mockDio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {
          'code': 200,
          'status': true,
          'message': 'Success message',
          'data': {'id': 10},
        },
      ),
    );

    final res = await apiService.get<Map<String, dynamic>>('/test');

    expect(res.code, 200);
    expect(res.status, true);
    expect(res.message, 'Success message');
    expect(res.data, {'id': 10});
    expect(res.isSuccess, true);
  });

  test('throws ServerFailure when backend returns status=false on HTTP 200',
      () async {
    when(
      () => mockDio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
        options: any(named: 'options'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 200,
        data: {
          'code': 422,
          'status': false,
          'message': 'Validation error',
          'data': null,
        },
      ),
    );

    expect(
      () => apiService.get('/test'),
      throwsA(isA<ServerFailure>().having(
        (f) => f.message,
        'message',
        'Validation error',
      )),
    );
  });

  test('throws CanceledFailure when request is cancelled', () async {
    when(
      () => mockDio.request<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
        options: any(named: 'options'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      ),
    );

    final cancelToken = CancelToken();
    expect(
      () => apiService.get('/test', cancelToken: cancelToken),
      throwsA(isA<CanceledFailure>()),
    );
  });
}

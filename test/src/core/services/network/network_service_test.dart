import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_project_setup/src/app/config/api_config.dart';
import 'package:flutter_project_setup/src/core/enums/enums.dart';
import 'package:flutter_project_setup/src/core/errors/api_exceptions.dart';
import 'package:flutter_project_setup/src/core/services/network/network_service.dart';
import 'package:flutter_project_setup/src/core/services/session/session_service.dart';
import 'package:flutter_project_setup/src/core/services/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  late _RecordingAdapter adapter;

  setUp(() {
    dio = Dio();
    adapter = _RecordingAdapter();
    dio.httpClientAdapter = adapter;
  });

  test('configures Dio and returns its decoded response', () async {
    final storage = _FakeSecureStorageService();
    final service = NetworkService(
      config: const ApiConfig(
        baseUrl: 'https://example.com/api/',
        connectTimeout: Duration(seconds: 4),
        sendTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 6),
      ),
      dio: dio,
      secureStorage: storage,
      sessionService: SessionService(storage),
    );

    final response = await service.get<Map<String, dynamic>>(
      'users',
      queryParameters: {'page': 2},
    );

    expect(response.data, {'ok': true});
    expect(adapter.requests.single.method, 'GET');
    expect(
      adapter.requests.single.uri.toString(),
      'https://example.com/api/users?page=2',
    );
    expect(dio.options.connectTimeout, const Duration(seconds: 4));
    expect(dio.options.sendTimeout, const Duration(seconds: 5));
    expect(dio.options.receiveTimeout, const Duration(seconds: 6));
  });

  test('adds a token only when authentication is required', () async {
    final storage = _FakeSecureStorageService('access-token');
    final service = NetworkService(
      config: const ApiConfig(baseUrl: 'https://example.com/'),
      dio: dio,
      secureStorage: storage,
      sessionService: SessionService(storage),
    );

    await service.get<Map<String, dynamic>>('public');
    await service.get<Map<String, dynamic>>('private', requiresAuth: true);

    expect(adapter.requests.first.headers['Authorization'], isNull);
    expect(
      adapter.requests.last.headers['Authorization'],
      'Bearer access-token',
    );
  });

  test('does not leak request-specific headers into later requests', () async {
    final storage = _FakeSecureStorageService();
    final service = NetworkService(
      config: const ApiConfig(baseUrl: 'https://example.com/'),
      dio: dio,
      secureStorage: storage,
      sessionService: SessionService(storage),
    );

    await service.get<Map<String, dynamic>>(
      'first',
      headers: {'X-Request-Id': 'first-request'},
    );
    await service.get<Map<String, dynamic>>('second');

    expect(adapter.requests.first.headers['X-Request-Id'], 'first-request');
    expect(adapter.requests.last.headers['X-Request-Id'], isNull);
  });

  test('converts Dio errors into ApiException', () async {
    adapter
      ..statusCode = 401
      ..responseBody = '{"message":"Token expired","customCode":1002}';

    final storage = _FakeSecureStorageService();
    final service = NetworkService(
      config: const ApiConfig(baseUrl: 'https://example.com/'),
      dio: dio,
      secureStorage: storage,
      sessionService: SessionService(storage),
    );

    final future = service.get<Map<String, dynamic>>('private');

    await expectLater(
      future,
      throwsA(
        isA<ApiException>()
            .having((error) => error.type, 'type', ApiErrorType.unauthorized)
            .having((error) => error.statusCode, 'statusCode', 401)
            .having((error) => error.customCode, 'customCode', 1002)
            .having((error) => error.message, 'message', 'Token expired'),
      ),
    );
  });

  test(
    'expires the session after an authenticated request returns 401',
    () async {
      adapter.statusCode = 401;

      final storage = _FakeSecureStorageService('expired-token');
      final sessionService = SessionService(storage);
      await sessionService.restoreSession();
      final service = NetworkService(
        config: const ApiConfig(baseUrl: 'https://example.com/'),
        dio: dio,
        secureStorage: storage,
        sessionService: sessionService,
      );

      final sessionExpired = expectLater(
        sessionService.statusChanges,
        emits(SessionStatus.unauthenticated),
      );

      await expectLater(
        service.get<Map<String, dynamic>>('private', requiresAuth: true),
        throwsA(isA<ApiException>()),
      );
      await sessionExpired;

      expect(storage.deleteAccessTokenCalls, 1);
    },
  );

  test(
    'does not expire the session when a public request returns 401',
    () async {
      adapter.statusCode = 401;

      final storage = _FakeSecureStorageService('current-token');
      final sessionService = SessionService(storage);
      await sessionService.restoreSession();
      final service = NetworkService(
        config: const ApiConfig(baseUrl: 'https://example.com/'),
        dio: dio,
        secureStorage: storage,
        sessionService: sessionService,
      );

      await expectLater(
        service.post<Map<String, dynamic>>('login'),
        throwsA(isA<ApiException>()),
      );

      expect(storage.deleteAccessTokenCalls, 0);
    },
  );
}

final class _FakeSecureStorageService extends SecureStorageService {
  _FakeSecureStorageService([this.token]) : super(const FlutterSecureStorage());

  String? token;
  int deleteAccessTokenCalls = 0;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> writeAccessToken(String token) async {
    this.token = token;
  }

  @override
  Future<void> deleteAccessToken() async {
    deleteAccessTokenCalls++;
    token = null;
  }
}

final class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  int statusCode = 200;
  String responseBody = '{"ok":true}';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Store a defensive copy because interceptors may mutate RequestOptions.
    requests.add(
      options.copyWith(
        headers: Map<String, dynamic>.from(options.headers),
        extra: Map<String, dynamic>.from(options.extra),
      ),
    );

    return ResponseBody.fromString(
      responseBody,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

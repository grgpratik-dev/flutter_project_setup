import 'package:dio/dio.dart';
import 'package:flutter_project_setup/src/core/enums/enums.dart';

import 'package:flutter_project_setup/src/core/errors/api_exceptions.dart';
import 'package:flutter_project_setup/src/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException.from', () {
    test('maps transport-level Dio errors', () {
      final cases = <DioExceptionType, ApiErrorType>{
        DioExceptionType.cancel: ApiErrorType.cancelled,
        DioExceptionType.connectionError: ApiErrorType.connection,
        DioExceptionType.connectionTimeout: ApiErrorType.timeout,
        DioExceptionType.sendTimeout: ApiErrorType.timeout,
        DioExceptionType.receiveTimeout: ApiErrorType.timeout,
        DioExceptionType.transformTimeout: ApiErrorType.timeout,
        DioExceptionType.badCertificate: ApiErrorType.badCertificate,
        DioExceptionType.unknown: ApiErrorType.unknown,
      };

      for (final entry in cases.entries) {
        final dioException = _dioException(type: entry.key);

        expect(ApiException.from(dioException).type, entry.value);
      }
    });

    test('maps common and range-based HTTP status codes', () {
      final cases = <int, ApiErrorType>{
        400: ApiErrorType.badRequest,
        401: ApiErrorType.unauthorized,
        403: ApiErrorType.forbidden,
        404: ApiErrorType.notFound,
        405: ApiErrorType.methodNotAllowed,
        408: ApiErrorType.timeout,
        409: ApiErrorType.conflict,
        415: ApiErrorType.unsupportedMediaType,
        422: ApiErrorType.validation,
        429: ApiErrorType.tooManyRequests,
        418: ApiErrorType.client,
        500: ApiErrorType.server,
        502: ApiErrorType.server,
        503: ApiErrorType.server,
        504: ApiErrorType.server,
      };

      for (final entry in cases.entries) {
        final exception = ApiException.from(
          _dioException(
            type: DioExceptionType.badResponse,
            statusCode: entry.key,
          ),
        );

        expect(exception.type, entry.value, reason: 'status ${entry.key}');
        expect(exception.statusCode, entry.key);
        expect(exception.message, isNotEmpty);
      }
    });

    test('safely extracts a direct server message and custom code', () {
      final exception = ApiException.from(
        _dioException(
          type: DioExceptionType.badResponse,
          statusCode: 422,
          data: <String, Object>{
            'message': 'Email is invalid.',
            'customCode': 1001,
          },
        ),
      );

      expect(exception.message, 'Email is invalid.');
      expect(exception.customCode, 1001);
    });

    test('safely extracts nested and validation messages', () {
      final nestedException = ApiException.from(
        _dioException(
          type: DioExceptionType.badResponse,
          statusCode: 400,
          data: <String, Object>{
            'error': <String, Object>{'message': 'Nested message.'},
            'custom_code': '1002',
          },
        ),
      );
      final validationException = ApiException.from(
        _dioException(
          type: DioExceptionType.badResponse,
          statusCode: 422,
          data: <String, Object>{
            'errors': <String, Object>{
              'email': <String>['Email is required.'],
            },
          },
        ),
      );

      expect(nestedException.message, 'Nested message.');
      expect(nestedException.customCode, 1002);
      expect(validationException.message, 'Email is required.');
    });

    test('falls back safely for null, HTML, and unexpected map bodies', () {
      final bodies = <Object?>[
        null,
        '<html>Bad Gateway</html>',
        <String, Object>{
          'errors': <String, Object>{'email': 42},
        },
      ];

      for (final body in bodies) {
        final exception = ApiException.from(
          _dioException(
            type: DioExceptionType.badResponse,
            statusCode: 502,
            data: body,
          ),
        );

        expect(exception.type, ApiErrorType.server);
        expect(exception.message, 'The server could not complete the request.');
      }
    });

    test('maps parsing and unknown errors without leaking their messages', () {
      final parsingException = ApiException.from(
        const FormatException('secret malformed payload'),
      );
      final unknownException = ApiException.from(
        StateError('internal implementation detail'),
      );

      expect(parsingException.type, ApiErrorType.parsing);
      expect(
        parsingException.message,
        'The received data could not be processed.',
      );
      expect(unknownException.type, ApiErrorType.unknown);
      expect(unknownException.message, 'An unexpected error occurred.');
    });

    test('preserves the original error and stack trace for diagnostics', () {
      final error = StateError('failure');
      final stackTrace = StackTrace.current;

      final exception = ApiException.from(error, stackTrace: stackTrace);

      expect(exception.originalError, same(error));
      expect(exception.stackTrace, same(stackTrace));
    });

    test('returns an existing ApiException unchanged', () {
      const existing = ApiException(
        type: ApiErrorType.forbidden,
        message: 'Forbidden.',
        statusCode: 403,
      );

      expect(ApiException.from(existing), same(existing));
    });
  });

  group('ApiFailure', () {
    test(
      'is created from ApiException without diagnostic implementation data',
      () {
        final originalError = StateError('implementation detail');
        final exception = ApiException(
          type: ApiErrorType.validation,
          message: 'Invalid input.',
          statusCode: 422,
          customCode: 1001,
          originalError: originalError,
          stackTrace: StackTrace.current,
        );

        final failure = ApiFailure.fromException(exception);

        expect(failure.type, ApiErrorType.validation);
        expect(failure.message, 'Invalid input.');
        expect(failure.statusCode, 422);
        expect(failure.customCode, 1001);
      },
    );
  });
}

DioException _dioException({
  required DioExceptionType type,
  int? statusCode,
  Object? data,
}) {
  final requestOptions = RequestOptions(path: '/test');
  final hasResponse = statusCode != null || data != null;

  return DioException(
    requestOptions: requestOptions,
    type: type,
    response: hasResponse
        ? Response<Object?>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: data,
          )
        : null,
  );
}

import 'package:flutter_project_setup/src/core/enums/enums.dart';
import 'package:flutter_project_setup/src/core/errors/firebase_exceptions.dart';
import 'package:flutter_project_setup/src/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFirebaseException', () {
    test('maps an auth error without importing Firebase', () {
      final exception = AppFirebaseException.fromCode(
        code: 'auth/weak-password',
        message: 'The password must contain more characters.',
        plugin: 'firebase_auth',
      );

      expect(exception.type, FirebaseErrorType.weakPassword);
      expect(exception.code, 'auth/weak-password');
      expect(exception.message, 'The password is too weak.');
      expect(
        exception.originalMessage,
        'The password must contain more characters.',
      );
      expect(exception.plugin, 'firebase_auth');
    });

    test('maps a storage error', () {
      final exception = AppFirebaseException.fromCode(
        code: 'storage/object-not-found',
        plugin: 'firebase_storage',
      );

      expect(exception.type, FirebaseErrorType.notFound);
      expect(exception.message, 'The requested data was not found.');
    });

    test('keeps unknown codes for diagnostics', () {
      final exception = AppFirebaseException.fromCode(
        code: 'future-service/new-error',
      );

      expect(exception.type, FirebaseErrorType.unknown);
      expect(exception.code, 'future-service/new-error');
    });
  });

  test('FirebaseFailure is created from AppFirebaseException', () {
    final exception = AppFirebaseException.fromCode(
      code: 'auth/too-many-requests',
      plugin: 'firebase_auth',
    );

    final failure = FirebaseFailure.fromException(exception);

    expect(failure.type, FirebaseErrorType.tooManyRequests);
    expect(failure.code, 'auth/too-many-requests');
    expect(failure.plugin, 'firebase_auth');
    expect(failure.message, 'Too many attempts. Please try again later.');
  });
}

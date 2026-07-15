import 'package:flutter_project_setup/src/core/services/session/session_service.dart';
import 'package:flutter_project_setup/src/core/services/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores an authenticated session when a token exists', () async {
    final service = SessionService(_FakeSecureStorageService('token'));

    final status = await service.restoreSession();

    expect(status, SessionStatus.authenticated);
  });

  test('starts a session and announces authentication', () async {
    final storage = _FakeSecureStorageService();
    final service = SessionService(storage);
    await service.restoreSession();

    final statusChanged = expectLater(
      service.statusChanges,
      emits(SessionStatus.authenticated),
    );
    await service.startSession('new-token');
    await statusChanged;

    expect(storage.token, 'new-token');
  });

  test('expires a session only once', () async {
    final storage = _FakeSecureStorageService('expired-token');
    final service = SessionService(storage);
    await service.restoreSession();

    final statuses = <SessionStatus>[];
    final subscription = service.statusChanges.listen(statuses.add);

    await Future.wait([service.expireSession(), service.expireSession()]);
    await Future<void>.delayed(Duration.zero);

    expect(statuses, [SessionStatus.unauthenticated]);
    expect(storage.deleteAccessTokenCalls, 1);

    await subscription.cancel();
  });
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

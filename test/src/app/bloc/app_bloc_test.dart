import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_project_setup/src/app/bloc/app_bloc.dart';
import 'package:flutter_project_setup/src/core/services/session/session_service.dart';
import 'package:flutter_project_setup/src/core/services/storage/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  blocTest<AppBloc, AppState>(
    'restores the saved session when the app starts',
    build: () {
      final storage = _FakeSecureStorageService('access-token');
      return AppBloc(SessionService(storage));
    },
    act: (bloc) => bloc.add(const AppStarted()),
    expect: () => [const AppState(status: SessionStatus.authenticated)],
  );

  late SessionService sessionService;

  blocTest<AppBloc, AppState>(
    'becomes unauthenticated when the global session expires',
    build: () {
      final storage = _FakeSecureStorageService('expired-token');
      sessionService = SessionService(storage);
      return AppBloc(sessionService);
    },
    act: (bloc) async {
      bloc.add(const AppStarted());
      await bloc.stream.firstWhere((state) => state.isAuthenticated);
      await sessionService.expireSession();
    },
    expect: () => [
      const AppState(status: SessionStatus.authenticated),
      const AppState(status: SessionStatus.unauthenticated),
    ],
  );
}

final class _FakeSecureStorageService extends SecureStorageService {
  _FakeSecureStorageService(this.token) : super(const FlutterSecureStorage());

  String? token;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> deleteAccessToken() async {
    token = null;
  }
}

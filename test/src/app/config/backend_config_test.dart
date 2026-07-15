import 'package:flutter_project_setup/src/app/config/api_config.dart';
import 'package:flutter_project_setup/src/app/config/firebase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('service configuration', () {
    test('REST configuration stores its network settings', () {
      const config = ApiConfig(
        baseUrl: 'https://example.com/api/v2',
        connectTimeout: Duration(seconds: 10),
      );

      expect(config.baseUrl, 'https://example.com/api/v2');
      expect(config.connectTimeout, const Duration(seconds: 10));
    });

    test('Firebase configuration stores emulator settings', () {
      const config = FirebaseConfig(useEmulators: true);

      expect(config.useEmulators, isTrue);
    });
  });
}

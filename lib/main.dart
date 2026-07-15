import 'package:flutter_project_setup/bootstrap.dart';
import 'package:flutter_project_setup/src/app/app.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}

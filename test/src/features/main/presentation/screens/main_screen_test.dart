import 'package:flutter/material.dart';
import 'package:flutter_project_setup/src/core/widgets/app_bottom_navigation_bar.dart';
import 'package:flutter_project_setup/src/features/main/presentation/screens/main_screen.dart';
import 'package:flutter_project_setup/src/features/main/presentation/screens/screen1.dart';
import 'package:flutter_project_setup/src/features/main/presentation/screens/screen2.dart';
import 'package:flutter_project_setup/src/features/main/presentation/screens/screen3.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('switches the displayed tab from the bottom navigation bar', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/screen1',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainScreen(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/screen1',
                  builder: (context, state) => const Screen1(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/screen2',
                  builder: (context, state) => const Screen2(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/screen3',
                  builder: (context, state) => const Screen3(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AppBottomNavigationBar>(find.byType(AppBottomNavigationBar))
          .selectedIndex,
      0,
    );

    const expectedIndices = [1, 2, 0];

    for (final expectedIndex in expectedIndices) {
      await tester.tap(
        find.byKey(ValueKey('app-bottom-navigation-item-$expectedIndex')),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<AppBottomNavigationBar>(find.byType(AppBottomNavigationBar))
            .selectedIndex,
        expectedIndex,
      );
    }
  });
}

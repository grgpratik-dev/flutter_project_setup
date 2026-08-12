import 'package:flutter/material.dart';
import 'package:flutter_project_setup/src/core/widgets/app_bottom_navigation_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders its items and reports a selection', (tester) async {
    int? selectedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigationBar(
            selectedIndex: 0,
            onDestinationSelected: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(
      tester
          .widget<Semantics>(
            find.byKey(const ValueKey('app-bottom-navigation-item-0')),
          )
          .properties
          .selected,
      isTrue,
    );

    await tester.tap(
      find.byKey(const ValueKey('app-bottom-navigation-item-1')),
    );

    expect(selectedIndex, 1);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_project_setup/src/core/widgets/app_bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}

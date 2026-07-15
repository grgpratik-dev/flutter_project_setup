import 'package:flutter/material.dart';
import 'package:flutter_project_setup/gen/assets.gen.dart';

import '../../../../core/logging/app_logger.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            GestureDetector(
              onTap: () => appLogger.console("test test"),
              child: Image.asset(
                Assets.images.demoImage.path,
                width: 200,
                height: 200,
              ),
            ),
            Text(
              'Onboarding Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Routes available in the application.
///
/// The enum value's [name] is used as the GoRouter route name, while [path]
/// defines its URL location.
enum AppRoute {
  onboarding('/onboarding');

  const AppRoute(this.path);

  final String path;
}

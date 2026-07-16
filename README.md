# Flutter Project Starter

A reusable Flutter starter for production-oriented apps using feature-first
Clean Architecture, BLoC, GetIt, GoRouter, and Dio.

The project keeps shared setup ready while allowing each feature to add only
the layers it actually needs.

## Included

- Feature-first Clean Architecture structure
- BLoC state management with an app-wide session BLoC
- GetIt dependency injection
- GoRouter navigation
- Dio network service with GET, POST, PUT, PATCH, and DELETE
- Bearer-token authorization and automatic session expiration on HTTP `401`
- Debug-only request and response logging
- File upload, progress, and request cancellation support
- API and Firebase exception foundations
- Secure storage and shared-preferences services
- Camera and gallery image picking, including multiple selection and Android lost-data recovery
- Light and dark themes
- Shared use-case, logging, validation, and utility foundations
- Unit and BLoC tests

## Structure

```text
lib/
├── main.dart                 # Application entry point
├── bootstrap.dart            # Startup and dependency initialization
└── src/
    ├── app/
    │   ├── bloc/             # App-wide session state
    │   ├── config/           # API and service configuration
    │   ├── di/               # GetIt registrations
    │   ├── router/           # GoRouter configuration
    │   └── theme/            # Application themes and colors
    ├── core/
    │   ├── errors/           # Exceptions and failures
    │   ├── logging/          # Application logger
    │   ├── services/
    │   │   ├── network/      # Dio service and interceptors
    │   │   ├── session/      # Global session lifecycle
    │   │   └── storage/      # Secure and preference storage
    │   ├── usecase/          # Shared use-case contract
    │   └── utils/            # Small reusable utilities
    └── features/
        └── <feature>/
            ├── data/
            ├── domain/
            └── presentation/
```

Feature layers have these responsibilities:

- `presentation`: screens, widgets, and BLoCs
- `domain`: entities, repository contracts, and use cases
- `data`: models, data sources, and repository implementations

Small features do not need to create every layer when those layers add no real
responsibility.

## Session flow

```text
Authentication flow logs in
    → SessionService stores the token
    → AppBloc becomes authenticated
    → AuthorizationInterceptor adds the token to protected requests
    → SessionInterceptor handles an authenticated 401
    → SessionService clears the token
    → AppBloc becomes unauthenticated
```

Use `requiresAuth: true` for protected requests:

```dart
final response = await networkService.get(
  '/profile',
  requiresAuth: true,
);
```

## Getting started

```sh
flutter pub get
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

Without `API_BASE_URL`, the starter uses `https://api.example.com`.

## Picking images

`ImagePickerService` is registered with GetIt and supports the camera, single
gallery selection, and multiple gallery selection:

```dart
final imagePicker = sl<ImagePickerService>();

final avatar = await imagePicker.pickFromGallery(
  maxWidth: 1200,
  imageQuality: 85,
);

final photo = await imagePicker.takePhoto(imageQuality: 85);
final gallery = await imagePicker.pickMultipleFromGallery(limit: 5);
```

For UI flows, use the shared `ImagePickerBloc`. It is registered as a factory,
so provide a new instance near each screen instead of sharing selection state
globally:

```dart
BlocProvider(
  create: (_) => sl<ImagePickerBloc>(),
  child: const ProfilePhotoView(),
);


Listen for `ImagePickerStatus.success`, `cancelled`, and `failure` to update the
UI. The selected files are available through `state.images`, while
`state.image` provides the first selected file.

A cancelled picker returns `null` for a single image and an empty list for
multiple images. Picked files are temporary; upload or copy files that must be
kept. On Android, call `retrieveLostData()` during startup on a screen that
opens the picker so a result can be recovered if the activity was destroyed.


## Adding a feature

1. Create `lib/src/features/<feature>/`.
2. Add the required data, domain, and presentation code.
3. Register dependencies in `dependency_injection.dart`.
4. Register screens in `app_router.dart`.


Keep feature BLoCs close to their screens. Only genuinely app-wide state, such
as the login session, belongs at the application root.

## Quality checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Firebase configuration and exceptions are prepared as foundations, but the
Firebase SDK is intentionally not integrated. Add it only when a project needs
it.

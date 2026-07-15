# Architecture decision

Status: accepted for the starter foundation  
Researched: 2026-07-13

## Decision

Use a pragmatic, feature-first architecture with MVVM-style presentation:

- `app/` is the composition root and owns app-wide wiring.
- `core/` contains only code reused by multiple features.
- `features/<feature>/` keeps each product capability together.
- `presentation/` separates widgets from testable UI state and actions.
- Add `data/` when a feature talks to external or persistent data.
- Add `domain/` only for complex, reused, or multi-repository business logic.
- Tests mirror the production paths they exercise.

The important standard is the dependency boundary, not a universal folder tree.
The structure remains compatible with ChangeNotifier, Riverpod, Bloc/Cubit, or
another state-management implementation.

## Options compared

| Structure | Advantages | Costs | Best fit |
| --- | --- | --- | --- |
| Layer-first (`screens/`, `models/`, `services/`) | Easy to understand in a small app; architectural types are obvious | A feature is scattered across the tree; broad folders become dumping grounds and team hotspots | Demos and small, stable apps |
| Feature-first | High cohesion, clear ownership, easier parallel work and feature removal | Deeper paths; duplication and cross-feature imports need discipline | Most growing product apps |
| Flutter Compass hybrid (`ui/<feature>` plus shared `data/` and `domain/`) | Officially demonstrated balance; excellent when repositories serve many features | Shared layers can grow large and ownership becomes less obvious | Apps with strongly shared data sources |
| Strict Clean Architecture per feature | Strong isolation, framework independence, and testability | Interfaces, mappings, use cases, mocks, and boilerplate even for trivial flows | Complex or regulated domains |
| Multi-package modular architecture | Compiler-enforced boundaries, independent reuse and testing | Multiple pubspecs, tooling overhead, and slower cross-package refactors | Large teams or genuinely reusable modules |

## Current structure

```text
lib/
├── bootstrap.dart
├── main.dart
└── src/
    ├── app/
    │   └── app.dart
    ├── core/
    │   └── theme/
    │       └── app_theme.dart
    └── features/
        └── counter/
            └── presentation/
                ├── pages/
                │   └── counter_page.dart
                └── view_models/
                    └── counter_view_model.dart

test/
└── src/                         # mirrors lib/src
```

Empty speculative folders are intentionally not committed. A real feature can
grow to the following shape when its requirements justify each layer:

```text
features/<feature>/
├── data/
│   ├── models/                  # transport and persistence shapes
│   ├── repositories/            # repository implementations
│   └── services/                # stateless external data-source adapters
├── domain/                       # optional
│   ├── models/
│   ├── repositories/            # contracts when dependency inversion helps
│   └── use_cases/                # complex/reused/multi-repository logic only
└── presentation/
    ├── pages/
    ├── view_models/              # or providers, cubits, blocs
    └── widgets/
```

## Dependency rules

1. `main.dart` delegates startup to `bootstrap.dart`.
2. `app/` composes dependencies, navigation, configuration, and features.
3. Presentation widgets delegate state changes and business decisions to a
   view model or equivalent state class.
4. Repositories are the source of truth for application data; services wrap
   one external data source and remain stateless.
5. Repositories must not depend on other repositories. Combine them in a view
   model or a use case.
6. A feature must not import another feature's private implementation. Move a
   truly shared concept to `core/`, a shared domain, or a local package.
7. `core/` must not depend on `features/` and must not become a miscellaneous
   `utils` folder.
8. Introduce abstractions at an actual boundary, not around every class.

## When to evolve the structure

- Add a use case when logic combines repositories, is unusually complex, or is
  reused by multiple view models.
- Split API and domain models when transport changes are leaking into the UI.
- Extract a local package when code has stable reuse, a distinct owner, or needs
  an independently enforced dependency boundary.
- Add flavors and multiple entry points when development, staging, and
  production need different configuration.

## Research sources

- [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter Compass architecture case study](https://docs.flutter.dev/app-architecture/case-study)
- [Flutter Compass sample](https://github.com/flutter/samples/tree/main/compass_app)
- [Very Good CLI Core template](https://cli.vgv.dev/docs/templates/core)
- [Bloc architecture guide](https://bloclibrary.dev/architecture/)
- [Bloc modular Todos example](https://bloclibrary.dev/tutorials/flutter-todos/)
- [Riverpod documentation](https://riverpod.dev/)

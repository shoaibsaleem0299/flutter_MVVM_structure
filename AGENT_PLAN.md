# AGENT_PLAN.md — Flutter App (Android + iOS)

> Give this file to your coding agent. Work phase by phase. Do not start a phase
> until the previous phase's "Done when" passes.

## 0. Ground rules (every developer and agent must follow)

**Architecture: feature-first + MVVM.** Each feature has only two layers:
```
features/<name>/
  data/          models/ (request + response models), repositories/
  presentation/  pages/ (UI only), viewmodels/ (logic + state), widgets/ (feature chunks)
```
**Responsibilities**
| Piece | Does | Must NOT |
|---|---|---|
| `ApiService` (core/network) | The only class that makes HTTP calls. Exposes get/post/put/patch/delete/getList, converts every error to a `Failure`. | Know about any feature |
| Repository (feature/data) | Calls `ApiService` with an endpoint + model, saves/reads storage, returns models | Touch UI, controllers, or state |
| ViewModel (feature/presentation/viewmodels) | Business logic, screen state, `TextEditingController`s, `GlobalKey<FormState>`, calls repository | Import widgets or use `BuildContext` for navigation/dialogs |
| Page | Layout only: `AppScaffold` + feature widgets. Reads the ViewModel | Hold controllers, call repositories, or contain business logic |

**Rebuild discipline (no unnecessary renders)**
- Pages are `ConsumerWidget`/`StatelessWidget`. No `setState` except tiny local UI (e.g. show/hide password).
- Read actions with `ref.read(xProvider.notifier)`. Watch state with `ref.watch(xProvider.select((s) => s.field))`, never the whole state unless needed.
- Wrap only the part that changes in a small `Consumer`. Split big screens into widgets under `presentation/widgets/`.

**Shared UI lives in `core/widgets/`** (change once, applies everywhere)
- Use `AppScaffold` (never raw `Scaffold`), `AppAppBar`, `AppTextField`, `AppButton`, `AppSnackBar`, `LoadingIndicator`.
- If a widget is needed by 2+ features, move it to `core/widgets/`.
- Spacing from `AppSpacing`, colors/typography from `Theme.of(context)`; no magic numbers or hard-coded colors.

**Other rules**
- All endpoints in `core/network/api_endpoints.dart`. All routes in `core/router/routes.dart`.
- Errors: repositories let `Failure` propagate; ViewModels catch it and put `message` in state.
- Strings: all UI text in `lib/l10n/app_en.arb`.
- Secrets: tokens only in `flutter_secure_storage`; config via `--dart-define`. Never commit `.env`, keystores, `key.properties`.
- Style: `flutter analyze` zero warnings, `const` everywhere possible, single quotes, conventional commits (`feat:`, `fix:`, `chore:`, `test:`).
- Every new feature ships with at least one repository test (mock `ApiService`) and, where there is logic, a ViewModel test.

## How to add things (copy-paste checklists)

**New API call:** add path to `ApiEndpoints` -> add request/response models in `data/models/` -> add a method to the feature repository that calls `_api.get/post(...)` -> call it from the ViewModel.

**New feature `orders`:**
1. `features/orders/data/models/*.dart`, `data/repositories/orders_repository.dart` (+ its provider).
2. `presentation/viewmodels/orders_state.dart` + `orders_viewmodel.dart` (+ provider).
3. `presentation/widgets/*` (small pieces) and `presentation/pages/orders_page.dart` (uses `AppScaffold`).
4. Add route in `routes.dart` and `app_router.dart`; add strings to ARB.
5. Tests under `test/features/orders/`.

**New shared widget:** create in `core/widgets/`, use theme + `AppSpacing`, then replace duplicates across features.

## 1. Project bootstrap (Phase 1)
1. Inside this folder run:
   `flutter create --org com.hotworx --project-name HotworxUHF --platforms android,ios .`
   (adds `android/` and `ios/` without overwriting `lib/` or `pubspec.yaml`)
2. `flutter pub get && flutter gen-l10n`
3. Set app name, bundle id (`com.hotworx.uhf`), min SDKs:
   - Android: `minSdk 23`, `compileSdk 34+` in `android/app/build.gradle`
   - iOS: deployment target `13.0` in `ios/Podfile` and Xcode.
4. Add platform permissions only as features require.
5. `git init`, first commit.

**Done when:** `flutter run` shows the login screen on Android and iOS; `flutter analyze` and `flutter test` pass.

## 2. Core hardening (Phase 2)
- [ ] Flavors `dev`, `staging`, `prod` (Android productFlavors + iOS schemes), selected via `--dart-define-from-file=env/dev.json`.
- [ ] Logger (`core/utils/logger.dart`) and Dio logging interceptor (debug only), added in `dio_client.dart`.
- [ ] Token refresh in `AuthInterceptor` (401 -> refresh -> retry once -> else logout).
- [ ] Connectivity awareness (`connectivity_plus`) and offline banner in `core/widgets/`.
- [ ] Global error handling: `FlutterError.onError`, `PlatformDispatcher.instance.onError`; Crashlytics/Sentry.
- [ ] App icons + splash (`flutter_launcher_icons`, `flutter_native_splash`).

**Done when:** switching flavor changes API URL and app name; a forced 401 triggers refresh/logout.

## 3. Auth feature completion (Phase 3)
- [ ] Wire the real backend response shape in `AuthResponse` / `UserModel`.
- [ ] Register, forgot password, email verification pages (new ViewModels, reuse `core/widgets`).
- [ ] Biometric unlock (`local_auth`) and passwordless login (email link + device verification).
- [ ] Tests: repository (mock `ApiService`), ViewModel, widget test for login form validation.

## 4. Product features (Phase 4+)
List features here (e.g. Profile, Items list, Item detail, Search, Notifications) and build each one using the "New feature" checklist above. Every page needs loading / empty / error / data states. Consider `freezed` + `json_serializable` once models grow.

## 5. Platform polish (Phase 5)
- [ ] Responsive layouts (phone + tablet), safe areas, dark mode check.
- [ ] Accessibility: semantics labels, 48dp touch targets, text scaling to 200%.
- [ ] Push notifications (`firebase_messaging`) incl. iOS APNs setup.
- [ ] Deep links (go_router + Android App Links / iOS Universal Links).
- [ ] More locales: add `app_<locale>.arb`.

## 6. Quality gates (Phase 6)
- [ ] Coverage >= 70% on `data` and ViewModels.
- [ ] Integration test: login -> home -> logout (`integration_test/`).
- [ ] CI (GitHub Actions): `pub get`, `analyze`, `test --coverage`, build apk/ipa on tags.
- [ ] Performance pass: `flutter run --profile`, check jank, image caching, `ListView.builder`.

## 7. Release (Phase 7)
- **Android:** upload keystore, `key.properties` (gitignored), `flutter build appbundle --release --flavor prod --dart-define-from-file=env/prod.json`, Play Console internal testing first.
- **iOS:** signing team in Xcode, `flutter build ipa --release --flavor prod ...`, TestFlight first.
- Privacy policy URL, data-safety / privacy labels, screenshots, store listing.
- Use `--obfuscate --split-debug-info=build/symbols` and archive symbols.

## Folder map
```
lib/
  main.dart, app.dart
  core/
    config/ constants/ (app_constants, app_spacing) errors/ router/ storage/ theme/ utils/
    network/   api_service.dart  api_endpoints.dart  dio_client.dart  auth_interceptor.dart
    widgets/   app_scaffold  app_app_bar  app_text_field  app_button  app_snack_bar  loading_indicator
  features/
    auth/      data/{models,repositories}  presentation/{pages,viewmodels,widgets}
    home/      presentation/pages
    settings/  presentation/pages
  l10n/        app_en.arb
test/          mirrors lib/
integration_test/
assets/        images, icons, fonts
```

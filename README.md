# Hotworx UHF — Enterprise Flutter Architecture

A production-grade mobile application for Android and iOS built with **Clean Architecture, Feature-First Modularity, and strict MVVM** using **Riverpod 2.x, GoRouter, and Dio**.

---

## 1. Architectural Philosophy

The application is engineered for **scalability, maintainability, and high performance** (targeting 100,000+ users). It enforces strict architectural boundaries inspired by Robert C. Martin's Clean Architecture and Domain-Driven Design (DDD).

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   Views (Pages & Widgets)  ◄──►  ViewModels (Notifiers) │
└───────────────────────────┬────────────────────────────┘
                            │ depends on (Interfaces)
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│        Entities / Models   &   Repository Contracts    │
└───────────────────────────▲────────────────────────────┘
                            │ implements
┌───────────────────────────┴────────────────────────────┐
│                       Data Layer                       │
│    Repository Implementations, DTOs, Local & Remote    │
└───────────────────────────┬────────────────────────────┘
                            │ consumes
┌───────────────────────────▼────────────────────────────┐
│                       Core Layer                       │
│   Network (Dio, Interceptors), Storage, Themes, Router  │
└────────────────────────────────────────────────────────┘
```

### Core Design Principles
* **Single Responsibility Principle (SRP):** Features are strictly decoupled. For example, `features/auth` manages authentication sessions and credentials, while `features/home` operates as an independent Dashboard module with its own data models and repository.
* **Dependency Inversion Principle (DIP):** ViewModels and Presentation controllers depend exclusively on abstract repository contracts (`IAuthRepository`, `IHomeRepository`), never on concrete network implementations.
* **Pure MVVM Boundary:** ViewModels (`Notifier` / `AutoDisposeNotifier`) are pure Dart classes. They never import `package:flutter/material.dart`, never instantiate `TextEditingController`s or `GlobalKey`s, and never receive `BuildContext`. UI widgets retain ownership of their own controller lifecycles.
* **Resilient Offline Session Handling:** Transient network drops or offline startups do not wipe local authentication credentials. Tokens are only cleared upon explicit 401 Unauthorized responses.

---

## 2. Directory Structure

```
lib/
├── app.dart                                # MaterialApp.router root & theme listener
├── main.dart                               # Application bootstrap & ProviderScope
│
├── core/                                   # Cross-cutting foundational modules
│   ├── config/
│   │   └── env.dart                        # Environment config (--dart-define)
│   ├── constants/
│   │   ├── app_constants.dart              # Timeouts, storage keys
│   │   ├── app_spacing.dart                # Centralized spacing tokens (xs to xl)
│   │   └── app_strings.dart                # Centralized string constants
│   ├── errors/
│   │   ├── error_mapper.dart               # DioException -> Failure mapper
│   │   └── failures.dart                   # Dart 3 sealed class Failure hierarchy
│   ├── network/
│   │   ├── api_endpoints.dart              # API endpoint path constants
│   │   ├── api_response.dart               # Generic envelope parser {status, message, data}
│   │   ├── api_service.dart                # Centralized HTTP client (get, post, cancelToken)
│   │   ├── auth_interceptor.dart           # Bearer token injection & 401 mutex refresh queue
│   │   └── dio_client.dart                 # Configured Dio instances (standard + refreshDio)
│   ├── router/
│   │   ├── app_router.dart                 # GoRouter configuration & session redirection
│   │   └── routes.dart                     # Centralized route path constants
│   ├── storage/
│   │   └── token_storage.dart              # FlutterSecureStorage with in-memory caching
│   ├── theme/
│   │   ├── app_colors.dart                 # Semantic light & dark color palettes
│   │   ├── app_radius.dart                 # Centralized border radius design tokens
│   │   ├── app_shadows.dart                # Elevation and drop-shadow tokens
│   │   ├── app_theme.dart                  # Material 3 ThemeData (Light & Dark)
│   │   ├── app_typography.dart             # Plus Jakarta Sans typography definitions
│   │   └── theme_controller.dart           # SharedPreferences-persisted ThemeMode notifier
│   ├── utils/
│   │   ├── typedefs.dart                   # Generic typedefs (Json)
│   │   └── validators.dart                 # Reusable form validators (email, password)
│   └── widgets/                            # Centralized reusable UI components
│       ├── app_app_bar.dart                # Standardized AppBar
│       ├── app_button.dart                 # Themed button with contrast-aware spinner
│       ├── app_scaffold.dart               # Themed scaffold with blocking loader & scrim
│       ├── app_snack_bar.dart              # Semantic snackbar utility (floating)
│       ├── app_text_field.dart             # Themed text field with password toggle
│       └── loading_indicator.dart          # Centered progress indicator
│
└── features/                               # Business modules (Feature-First)
    ├── auth/
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── i_auth_repository.dart  # Repository interface (Contract)
    │   ├── data/
    │   │   ├── models/                     # LoginRequest, AuthResponse, UserModel
    │   │   └── repositories/
    │   │       └── auth_repository.dart    # Concrete implementation of IAuthRepository
    │   └── presentation/
    │       ├── controllers/
    │       │   └── auth_coordinator.dart   # App-level session coordinator (AuthStatus)
    │       ├── viewmodels/
    │       │   ├── login_state.dart        # Screen-scoped form state (isLoading, error)
    │       │   └── login_viewmodel.dart    # Pure Dart form submit logic (autoDispose)
    │       ├── pages/
    │       │   └── login_page.dart         # Pure View observing state & snackbars
    │       └── widgets/
    │           └── login_form.dart         # Owns TextEditingControllers & FormKey
    │
    ├── home/                               # Independent Dashboard Feature (Decoupled)
    │   ├── domain/
    │   │   └── repositories/
    │   │       └── i_home_repository.dart  # Dashboard repository contract
    │   ├── data/
    │   │   ├── models/
    │   │   │   └── dashboard_profile_model.dart # Nested profile & KYC document models
    │   │   └── repositories/
    │   │       └── home_repository.dart    # Calls ApiService.get(ApiEndpoints.me)
    │   └── presentation/
    │       ├── viewmodels/
    │       │   ├── home_state.dart         # DashboardState (isLoading, profile, error)
    │       │   └── home_viewmodel.dart     # AutoDisposeNotifier with CancelToken
    │       ├── widgets/
    │       │   ├── dashboard_header_card.dart  # Avatar, name, email, approval badge
    │       │   ├── kyc_trading_card.dart       # Trading account #, CNIC, KYC status
    │       │   ├── bank_employment_card.dart   # Bank, IBAN, occupation, income
    │       │   └── kyc_documents_card.dart     # Document list with verified/pending chips
    │       └── pages/
    │           └── home_page.dart          # Pull-to-refresh dashboard scaffold
    │
    └── settings/
        └── presentation/
            └── pages/
                └── settings_page.dart      # Theme switcher (System/Light/Dark) & Logout
```

---

## 3. Key Architectural Features & Deep Dive

### A. Network Layer (`ApiService` & `AuthInterceptor`)
* **Single Network Gatekeeper:** Every outbound call routes through `ApiService`. Features never instantiate Dio directly.
* **401 Token Refresh with Mutex:** When an access token expires:
  1. `AuthInterceptor` captures the 401 error.
  2. A `Completer<String?>` mutex locks concurrent requests to prevent multiple simultaneous refresh calls (race condition prevention).
  3. A dedicated `refreshDioProvider` (a clean instance without interceptors) contacts the refresh endpoint using the saved refresh token.
  4. On success, the new token is cached and all queued requests are updated with the new Bearer header and replayed via `_dio.fetch()`.
* **Request Cancellation (`CancelToken`):** ViewModels instantiate a `CancelToken` and register an `onDispose` hook (`ref.onDispose(() => _cancelToken?.cancel())`). If the user leaves a screen before a network call finishes, the request is cleanly aborted, conserving bandwidth and device battery.
* **Sealed Failures:** Errors are mapped using `mapError(e)` into strongly-typed `Failure` classes:
  * `NetworkFailure`: Connection timeout, socket exception, certificate errors.
  * `ServerFailure`: HTTP 4xx/5xx responses with sanitized server error messages.
  * `UnauthorizedFailure`: 401 Unauthorized.
  * `CanceledFailure`: Request aborted by the client.

### B. Secure Storage & In-Memory Caching (`TokenStorage`)
* **Hardware-Backed Encryption:** On Android, uses `EncryptedSharedPreferences`. On iOS, uses `KeychainAccessibility.first_unlock`.
* **In-Memory Cache (RAM Acceleration):** Secure storage I/O over platform channels takes 20–50ms per read. `TokenStorage` holds `_cachedAccessToken` in memory. Repeated API requests retrieve the token in **0ms** from RAM without disk access.

### C. MVVM Decoupling (Session vs. Form State)
To avoid the common anti-pattern of mixing global session state with local form state:
1. **`AuthCoordinator` (Application Scope):** Manages global session state (`AuthStatus.unknown`, `authenticated`, `unauthenticated`). Watched by `GoRouter` for top-level navigation redirection.
2. **`LoginViewModel` (Screen Scope, `autoDispose`):** Manages screen-specific state (`isLoading`, `errorMessage`). Disposes automatically when leaving the screen, preventing memory leaks or dirty form inputs from persisting across logins.
3. **View-Layer Controller Ownership:** `LoginForm` is a `ConsumerStatefulWidget` that instantiates and disposes `_formKey`, `_emailController`, and `_passwordController`. The ViewModel remains a **pure Dart class**, allowing unit tests to run in sub-second speeds without requiring Flutter widget test bindings.

### D. Decoupled Dashboard Feature (`features/home/`)
* The Dashboard (`features/home/`) has **zero imports from `features/auth/`**.
* It models the `/me` payload into `DashboardProfileModel` with defensive null-safety.
* Provides pull-to-refresh (`RefreshIndicator`) mapped to `HomeViewModel.loadDashboard(isRefresh: true)`.
* Modular cards divide layout responsibility:
  * `DashboardHeaderCard`: User avatar initials, name, email, phone, role, and approval chip.
  * `KycTradingCard`: Trading account ID (`UHF`), CNIC, residency status, and KYC verification badge.
  * `BankEmploymentCard`: Bank name (`Meezan`), branch, IBAN, account title, occupation, and annual income.
  * `KycDocumentsCard`: Uploaded KYC documents with document type titles and status pills.

### E. Centralized Design System & Typography
* **Plus Jakarta Sans Typography:** Integrated via `GoogleFonts.plusJakartaSansTextTheme`, applied globally across all headings, body text, inputs, and buttons in both light and dark modes.
* **Semantic Design Tokens:**
  * Colors: `AppColors` defines semantic palettes (`primary`, `success`, `warning`, `error`, `info`, and light/dark neutral surfaces).
  * Radius: `AppRadius` (`sm: 8.0`, `md: 12.0`, `lg: 16.0`, `full: 999.0`).
  * Shadows: `AppShadows` (`sm`, `md`, `lg`).
  * Spacing: `AppSpacing` (`xs: 4.0` to `xl: 32.0`).
* **Dynamic Theme Switcher:** `ThemeController` (Riverpod `Notifier<ThemeMode>`) persists user preferences (`system`, `light`, `dark`) in `SharedPreferences`.

---

## 4. Setup & Running

### Prerequisites
* Flutter SDK `>= 3.22.0`
* Dart SDK `>= 3.4.0 < 4.0.0`

### Installation
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Run unit tests
flutter test

# 4. Launch application with environment configuration
flutter run --dart-define=API_BASE_URL=https://api.yourdomain.com/api
```

---

## 5. Testing Strategy

The architecture is built for **100% testability** using `flutter_test` and `mocktail`:

| Test Suite | File | What It Tests |
|:---|:---|:---|
| **ViewModel Tests** | `test/features/auth/login_viewmodel_test.dart` | Form submission, loading state transitions, error mapping, and coordinator notification. |
| **Dashboard ViewModel** | `test/features/home/home_viewmodel_test.dart` | Profile data loading, pull-to-refresh, error recovery, and cancel token lifecycle. |
| **Repository Tests** | `test/features/auth/auth_repository_test.dart` | Token persistence on login, session wipe on 401, token preservation on network failure. |
| **Dashboard Repo** | `test/features/home/home_repository_test.dart` | Safe parsing of `/me` JSON into `DashboardProfileModel`. |
| **Interceptor Tests** | `test/core/network/auth_interceptor_test.dart` | Automatic Bearer injection, 401 refresh mutex, and request replay. |
| **Storage Tests** | `test/core/storage/token_storage_test.dart` | RAM cache hits vs. disk reads, cache wiping on clear. |
| **Theme Tests** | `test/core/theme/theme_controller_test.dart` | ThemeMode state transitions and SharedPreferences persistence. |
| **Network Tests** | `test/core/network/api_service_test.dart` | Response envelope extraction and request cancellation via `CancelToken`. |

Execute all tests with:
```bash
flutter test --coverage
```

---

## 6. How to Add a New Feature

Follow this checklist to keep the architecture clean when adding a new feature (e.g., `orders`):

1. **Domain Layer:** Define the contract:
   `features/orders/domain/repositories/i_orders_repository.dart`
2. **Data Layer:** Define models & repository implementation:
   * Models: `features/orders/data/models/order_model.dart`
   * Repository: `features/orders/data/repositories/orders_repository.dart` (calls `ApiService`)
   * Provider: `final ordersRepositoryProvider = Provider<IOrdersRepository>(...);`
3. **Presentation Layer:**
   * State: `features/orders/presentation/viewmodels/orders_state.dart`
   * ViewModel: `features/orders/presentation/viewmodels/orders_viewmodel.dart` (`AutoDisposeNotifier`)
   * Page: `features/orders/presentation/pages/orders_page.dart` (uses `AppScaffold`)
   * Widgets: Split complex screens into modular widgets under `features/orders/presentation/widgets/`
4. **Navigation:** Register the route in `core/router/routes.dart` and `core/router/app_router.dart`.
5. **Testing:** Add repository and ViewModel unit tests under `test/features/orders/`.

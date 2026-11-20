---
name: codebase-quality-gate
description: >-
  Enforces the mandatory 10/10 Engineering & Architecture Quality Standard for Go Safar.
  Activate for every new feature, refactoring, bug fix, widget, provider, network call,
  or architectural decision to prevent technical debt and maintain zero-regression quality.
---

# 10/10 Engineering & Architecture Quality Gate

This skill enforces the uncompromising **10/10 Codebase Standard** for the Go Safar project. Every task—regardless of scope—must pass through this automated pre-flight & post-implementation gate before completion.

---

## 🏛️ The 8 Architectural Pillars

Every code modification must strictly adhere to these 8 foundational pillars:

### 1. Architecture & Project Structure
- **Clean Layer Separation**: Feature code is segregated into `domain/` (pure Dart entities, use cases, repository contracts), `data/` (models, remote/local data sources, repository implementations), and `presentation/` (screens, providers, widgets).
- **Zero Layer Leakage**: Domain entities must never import Flutter UI widgets, Dio, or JSON serialization packages.
- **No God Classes**: Keep classes focused and single-purpose; extract business logic from widgets into providers and domain validators.
- **Modularity**: New features must live in `lib/features/<feature>/` adhering to the standard 3-tier blueprint.

### 2. State Management & Data Flow
- **Predictable Unidirectional Flow**: State flows down via providers; user actions flow up via provider methods.
- **Scoped Injection**: Avoid root-level singleton providers for screen state. Register screen providers as `registerFactory` in `locator.dart` and scope them using `ChangeNotifierProvider` at the route/screen root.
- **Granular Rebuilds**: Use `context.select<T, R>()` or `Consumer<T>` to rebuild only widgets that depend on changing values. Never call `context.watch<T>()` in high-frequency rebuild parents if only a sub-property changed.
- **No Business Logic in Widgets**: UI widgets strictly display state and forward user gestures.

### 3. Code Quality & DRY
- **Pure Domain Validation**: Form and input validation must reside in pure Dart domain validators (e.g. `AuthValidator`) rather than inside UI widget states.
- **Strict Typing & Null Safety**: No untyped `dynamic` variables where types are knowable. No force unwraps (`!`) unless proven non-null by surrounding invariants.
- **Shared Tokens Over Magic Values**: Always reference `AppColors`, `AppDimensions`, `AppTheme`, and `AppRoutes`. Hardcoded raw colors or hex codes are strictly prohibited.
- **Zero Static Analysis Issues**: Every task must maintain `dart analyze lib test` with **0 warnings and 0 errors**.

### 4. UI & Design System Compliance
- **Unified Image Rendering**: Always use `AppImageView` for all image and vector types (`Assets.images`, `Assets.svgs`, network URLs, local files, and Lottie animations). Direct usage of `Image.asset`, `Image.file`, `Image.network`, or `SvgPicture.asset` is strictly prohibited.
- **Theme-Driven Components**: Consume typography and colors from `Theme.of(context).textTheme` and `AppColors`.
- **Responsive & Overflow-Free**: Support multiple screen densities and screen sizes using `LayoutBuilder`, `SingleChildScrollView`, and `IntrinsicHeight`.
- **Safe Area & Inset Handling**: Ensure all interactive views respect `SafeArea` and dynamic system insets (keyboard appearance, notch).
- **Micro-interactions & Aesthetics**: Preserve rich aesthetics (curated neon/dark palettes, silky spring curves, smooth transitions).

### 5. Networking & Data Integrity
- **Repository Abstraction**: UI and providers interact solely with abstract repository interfaces returning `Either<ApiException, T>` via `fpdart`.
- **Centralized API Client**: All HTTP operations flow through `ApiClient` utilizing `Endpoints` constants and `handleApiCall()`.
- **Concurrency & Queued Refresh**: Token persistence is encapsulated in `TokenService`. 401 Unauthorized handling must leverage `QueuedInterceptor` in `AuthInterceptor` to synchronize token refreshes and retry requests sequentially.
- **No Raw HTTP in UI**: Direct calls to `dio`, `http`, or remote URLs from presentation widgets or providers are strictly forbidden.

### 6. Error Handling & Resilience
- **Functional Error Handling**: Catch failures at the boundary and map them to typed `ApiException` subclasses (`NetworkException`, `UnauthorizedException`, `NotFoundException`, etc.).
- **No Silent Catches**: Never write empty `catch (_) {}` blocks without purposeful rationale or error logging.
- **Resilient UI States**: Screens must explicitly account for Loading, Content, Error, and Empty states.
- **Crash Hardening**: Maintain safe fallback routes in `AppRoutes.onUnknownRoute` and context-safe overlay toasts via `Snackbar.show()`.

### 7. Performance & Resource Optimization
- **Mandatory Lifecycle Disposals**: Every `TextEditingController`, `AnimationController`, `FocusNode`, `ScrollController`, and `StreamSubscription` must be explicitly disposed in `dispose()`.
- **Raster Cache Isolation**: Wrap complex custom painters (e.g., `FluidicMetaballNavBar`, `OnboardingHeroGraphic`) in `RepaintBoundary` to prevent canvas repainting during unrelated tree rebuilds.
- **Granular Media Queries**: Use `MediaQuery.sizeOf(context)`, `MediaQuery.paddingOf(context)`, and `MediaQuery.viewInsetsOf(context)` instead of `MediaQuery.of(context)` to eliminate full-tree rebuilds when keyboard insets change.

### 8. Testability & Maintainability
- **Test Isolation**: Every test suite modifying service locators or global state must reset keys in `setUp` (e.g., `navigation.resetKey()`) and clean up in `tearDown`.
- **Mockable Contracts**: Dependencies must be injected via constructors so unit tests can swap in mocks or fakes without socket or plugin dependencies.
- **100% Passing Tests**: All existing and newly added unit, widget, and repository tests must pass with `flutter test`.

---

## ⚡ Pre-Flight Checklist (Run Before Coding)

Before generating or modifying code, verify:
1. Does this feature need a domain entity and repository contract before writing the UI?
2. Does the state belong in a scoped `ChangeNotifierProvider` rather than inline `setState`?
3. Are all string literals prepared for `AppLocalizations`?
4. Are all network calls mediated through `ApiClient` and abstract repository contracts?
5. Does any complex animated canvas need a `RepaintBoundary`?

---

## 🔍 Post-Implementation Self-Verification Protocol

Before marking any user task or prompt as complete, execute this self-verification protocol:

1. **Static Analysis**: Run `dart analyze lib test` (Must output `No issues found!`).
2. **Regression Test Run**: Run `flutter test` (Must achieve 100% pass rate).
3. **Mandatory Output Format**: Conclude the final response with the 10/10 Quality Verification box:

```markdown
✅ 10/10 Quality Verification:
- Architecture & Layering: Pass (Clean separation confirmed)
- State Scoping & Lifecycles: Pass (Disposals & controllers verified)
- Performance & DRY: Pass (No redundant rebuilds, tokens reused)
- Zero Regressions: Pass (Score maintained at 10/10)
```

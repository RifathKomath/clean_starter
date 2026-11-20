---
name: codebase-quality-gate
description: >-
  Enforces the mandatory 10/10 Engineering, Architecture, Maintainability, State Management,
  and Security Quality Standard for the Go Safar codebase. Activate for every task,
  new feature, refactoring, bug fix, widget, provider, network call, or architectural decision.
---

# 🛡️ 10/10 Codebase Quality Gate

This skill enforces the uncompromising **10.0 / 10 Engineering Standard** across the Go Safar codebase. Every feature, widget, state provider, network call, and test must satisfy these criteria before any task is marked as complete.

---

## 🏛️ The 5 Pillars of the 10/10 Codebase Standard

### 1. Architecture & Clean Layer Separation (Score: 10/10)
- **Strict 3-Tier Clean Architecture**: Code lives strictly within `domain/` (pure Dart entities, use cases, repository contracts), `data/` (models, datasources, repository implementations), or `presentation/` (screens, providers, widgets, routes).
- **Pure Dart Domain Invariant**: `domain/` must **never** import `package:flutter/...`, `package:dio/...`, or JSON serialization packages.
- **Shared Booking Elevation**: Common booking entities (`BookingRideOption`, `BookingDriverInfo`, `BookingPaymentOption`, `BookingDestinationItem`) and shared booking widgets must reside in `lib/features/shared_booking/`.
- **Zero Circular Dependencies**: Features must never import other features horizontally in a circular loop.
- **Reference**: Detailed architecture rules in [Architecture Guide](./references/architecture.md).

### 2. Best Practices & Code Quality (Score: 10/10)
- **Zero Static Analysis Issues**: Every task must maintain `dart analyze lib test` with **0 errors, 0 warnings, and 0 infos**.
- **Unified Image Rendering**: Always use `AppImageView` for all assets, SVGs, network images, local files, and Lottie animations. Direct calls to `Image.asset`, `Image.network`, or `SvgPicture.asset` are strictly prohibited.
- **Design Tokens Over Magic Values**: Always reference `AppColors`, `AppDimensions`, `AppTheme`, and `AppRoutes`. Raw hex codes and hardcoded dimensions are prohibited.
- **Strict Typing & Null Safety**: No unproven force unwraps (`!`). Use explicit typing for all public contracts.

### 3. Maintainability & Modular Routing (Score: 10/10)
- **Modular Routing Aggregator**: `lib/app/app_routes.dart` must remain under **120 lines** by delegating route resolution to modular feature route delegates (`AuthRoutes`, `HomeRoutes`, `CabBookingRoutes`, `RentalRoutes`, `ActivitiesRoutes`, `ProfileRoutes`, `SubscriptionsRoutes`, `LocationRoutes`).
- **Type-Safe Argument DTOs**: Pass route arguments using typed DTOs with `.fromDynamic()` fallback resolvers for 100% backward compatibility.
- **Mirrored Test Hierarchy**: All test files must mirror `lib/` 1:1 (`test/app/`, `test/core/`, `test/features/`). Zero flat test files in root `test/`.

### 4. State Management & Lifecycle Scoping (Score: 10/10)
- **Pure Dependency Injection**: Feature providers must receive dependencies via constructor injection. Providers must **never** import `locator.dart` or query `getIt<T>()` in their constructors or methods.
- **Unified Booking Flow Coordinator**: Multi-step booking engines with simulated driver matching and arrivals must extend `BookingFlowCoordinator` to eliminate timer boilerplate.
- **Mandatory Lifecycle Disposals**: Every `TextEditingController`, `AnimationController`, `FocusNode`, `ScrollController`, and `StreamSubscription` must be explicitly disposed in `dispose()`.
- **Granular Rebuild Boundaries**: Use `context.select<T, R>()` or `Consumer<T>` instead of calling `context.watch<T>()` at screen root.
- **Reference**: Detailed state management rules in [State Management Guide](./references/state_management.md).

### 5. Security & Data Protection (Score: 10/10)
- **Secure Token Storage**: Authentication tokens must flow strictly through `TokenService` backed by encrypted hardware storage. Never use plaintext `SharedPreferences` for auth tokens.
- **Queued Token Refresh**: 401 handling must use `QueuedInterceptor` in `AuthInterceptor` to synchronize parallel requests during token refreshes.
- **Zero PII Logging**: Never log passwords, OTPs, auth tokens, or unmasked user data in `debugPrint` or `print`.
- **Domain Input Sanitization**: All inputs (phones, emails, OTPs) must be validated by pure Dart domain validators before submission.
- **Reference**: Detailed security standards in [Security Guide](./references/security.md).

---

## ⚡ Mandatory Pre-Flight Checklist (Run Before Modifying Code)

Before writing or editing code, verify:
1. [ ] Is the code placed in the correct Clean Architecture layer (`domain/`, `data/`, or `presentation/`)?
2. [ ] Does the domain layer remain 100% pure Dart with zero Flutter or Dio imports?
3. [ ] Are provider dependencies injected via constructor arguments without `getIt` inside the provider?
4. [ ] Does this route use a type-safe argument DTO?
5. [ ] Are all image assets rendered via `AppImageView`?
6. [ ] Are all controllers, timers, and focus nodes wired to `dispose()`?

---

## 🔍 Mandatory Post-Implementation Verification Protocol

Before completing any task, execute the verification script or manual commands:

```bash
# Automated verification script
./.agents/skills/codebase-quality-gate/scripts/verify_codebase_quality.sh
```

Or manually:
1. **Static Analysis**: `dart analyze lib test` (Must output `No issues found!`).
2. **Regression Test Run**: `flutter test` (Must achieve 100% pass rate).

### Mandatory Completion Block Format
Every response modifying or introducing code must conclude with:

```markdown
✅ 10/10 Quality Verification:
- Architecture & Layering: Pass (Clean separation confirmed)
- State Scoping & Lifecycles: Pass (Disposals & controllers verified)
- Performance & DRY: Pass (No redundant rebuilds, tokens reused)
- Zero Regressions: Pass (Score maintained at 10/10)
```

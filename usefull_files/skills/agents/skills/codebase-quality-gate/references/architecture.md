# 🏛️ Architecture & Clean Design Standard (10/10)

This guide documents the architectural invariants required to maintain a **10.0 / 10** codebase quality score.

---

## 1. Strict 3-Tier Clean Architecture

Every feature folder (`lib/features/<feature>/`) must be structured into three isolated layers:

```text
lib/features/<feature>/
├── domain/                    # Layer 1: Core Business Logic (Pure Dart)
│   ├── entities/              # Immutable business models (equatable / value equality)
│   ├── repositories/          # Abstract repository contracts (interface definitions)
│   ├── usecases/              # Single-purpose business actions (optional if direct in provider)
│   └── validators/            # Pure Dart input validators (e.g., AuthValidator)
├── data/                      # Layer 2: Infrastructure & Data Sources
│   ├── models/                # DTOs with toJson / fromJson parsing
│   ├── datasources/           # Remote & Local data sources (API & Storage calls)
│   └── repositories/          # Concrete repository implementations
└── presentation/              # Layer 3: UI & State Management (Flutter)
    ├── providers/             # ChangeNotifier providers managing screen state
    ├── screens/               # Flutter screen widgets
    ├── widgets/               # Reusable presentation components
    └── routes/                # Feature route delegate & type-safe argument DTOs
```

### Inviolable Layering Rules:
1. **Domain Layer is Pure Dart**:
   - `domain/` must **never** import `package:flutter/...`, `package:dio/...`, or JSON serialization libraries.
   - Domain errors are mapped to functional `ApiException` subclasses or pure `Failure` objects via `fpdart` `Either<ApiException, T>`.
2. **Data Layer Encapsulates Networking & Storage**:
   - `ApiClient`, `Dio`, and storage services are confined to `data/` and `core/`.
   - Data models convert external JSON to/from domain entities (`toEntity()`).
3. **Presentation Layer Strictly Consumes Domain Contracts**:
   - Presentation code depends on repository contracts, not concrete implementations.
   - UI widgets contain zero HTTP, storage, or raw business calculations.

---

## 2. Modular Routing & Type-Safe Navigation

`lib/app/app_routes.dart` is an aggregator that delegates route resolution to feature delegates:

- **Aggregator Constraint**: `app_routes.dart` must remain under **120 lines**.
- **Feature Route Delegates**: Each feature owns its `FeatureRoutes.onGenerateRoute(RouteSettings settings)`.
- **Type-Safe Argument DTOs**:
  - Arguments are modeled as immutable DTO classes (e.g., `OtpVerifyArgs`, `RentalVehicleDetailArgs`).
  - Every DTO provides a robust `factory .fromDynamic(dynamic args)` fallback parser to guarantee 100% backward compatibility and prevent runtime null crashes.

---

## 3. Dependency Injection & Service Locator Hygiene

- **Constructor Injection Only**: Every service, repository, and provider must receive its dependencies via constructor arguments.
- **Zero `getIt` inside Feature Providers**: Providers must **never** import `di/locator.dart` or query `getIt<T>()` in their constructors or methods.
- **Service Locator Registration**:
  - Global services (`StorageService`, `TokenService`, `ApiClient`, `LocationService`) are registered as `registerLazySingleton` in `lib/di/locator.dart`.
  - Feature providers are registered as `registerFactory` in `locator.dart` and scoped to the widget subtree via `ChangeNotifierProvider`.

---

## 4. Shared Feature Boundaries & Zero Circularity

- Features must **never** form circular dependencies with other features.
- Common booking entities (`BookingRideOption`, `BookingDriverInfo`, `BookingPaymentOption`, `BookingDestinationItem`) and shared booking widgets must reside in `lib/features/shared_booking/`.
- Deprecated or legacy references must be preserved via top-level `typedef` aliases to maintain 100% backward compatibility.

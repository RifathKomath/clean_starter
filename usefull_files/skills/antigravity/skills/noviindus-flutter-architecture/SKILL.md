---
name: noviindus-flutter-architecture
description: >-
  Standard Clean Architecture guide for Noviindus Flutter applications (based on go_by_plan).
  Use whenever creating new features, implementing domain/data/presentation layers, setting up
  API calls with ApiClient and handleApiCall, writing providers with ChangeNotifier and fpdart Either,
  registering dependencies in locator.dart with GetIt, or building UI screens and reusable widgets.
---

# Noviindus Flutter Clean Architecture Specification

This skill documents the exact architectural standards, conventions, and implementation workflows established in `go_by_plan` and followed across Noviindus Flutter codebases (including `go-safar`).

---

## 1. Core Architectural Pillars

- **Architecture**: 3-Tier Clean Architecture (Domain, Data, Presentation) per feature.
- **State Management**: `Provider` (`ChangeNotifierProvider`, `Consumer`, `context.watch`, `context.read`).
- **Dependency Injection**: `GetIt` via `setupLocator()` in `lib/di/locator.dart`.
- **Networking**: `Dio` configured in `ApiClient` with `AuthInterceptor`, `LoggingInterceptor`, and `Endpoints`.
- **Functional Error Handling**: `fpdart`'s `Either<ApiException, T>` with `handleApiCall` and `.fold()`.
- **Navigation**: Decoupled global `NavigationService` accessed via the top-level `navigation` getter.
- **Feedback & Notifications**: Overlay-based `Snackbar.show(message, isError: bool)` and FCM `NotificationService`.
- **Localization**: Flutter `gen-l10n` with ARB files (`app_en.arb`) accessed via `context.locale.<key>`.
- **Typography & Theme**: `Plus Jakarta Sans` as the root font family in `AppTheme.lightTheme` & `darkTheme`.

---

## 2. Directory Layout & Organization

Every feature strictly adheres to this folder blueprint:

```text
lib/
├── app/
│   ├── app.dart                   # Root MaterialApp with themes, routes, locators
│   └── app_routes.dart            # Route string constants & onGenerateRoutes()
├── core/
│   ├── constants/                 # Assets (generated), country codes, constants
│   ├── extensions/                # context_extensions (context.locale, width), string, date
│   ├── models/                    # Shared global data models
│   ├── network/                   # ApiClient, ApiInterceptors, ApiException, Endpoints
│   ├── services/                  # NavigationService, TokenService, Snackbar, DeepLink
│   ├── theme/                     # AppColors, AppTheme (Plus Jakarta Sans default)
│   ├── utils/                     # Helpers (debouncers, share, tasks)
│   └── widgets/                   # Atomic UI components (Buttons, TextField, BottomSheet, Shimmer)
├── di/
│   └── locator.dart               # GetIt registry (Services -> DataSources -> Repos -> UseCases -> Providers)
├── env/
│   ├── flavor_config.dart         # FlavorConfig singleton & FlavorValues
│   ├── main_dev.dart
│   ├── main_qa.dart
│   └── main_prod.dart
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/       # <feature>_remote_data_source.dart (abstract & impl)
│       │   ├── models/            # <feature>_response_model.dart (extends domain entity)
│       │   └── repositories/      # <feature>_repository_impl.dart (calls handleApiCall)
│       ├── domain/
│       │   ├── entities/          # Pure Dart domain entity classes
│       │   ├── repositories/      # Abstract repository interface
│       │   └── usecases/          # Granular use case classes
│       └── presentation/
│           ├── providers/         # <feature>_provider.dart (ChangeNotifier)
│           ├── screens/           # <feature>_screen.dart (Stateful/Stateless with ChangeNotifierProvider)
│           └── widgets/           # Feature-specific atomic UI components
└── l10n/
    ├── app_en.arb                 # Canonical English translations
    └── l10n.yaml                  # Flutter localization config
```

---

## 3. End-to-End Feature Implementation Workflow

When building any new feature, follow this strict 9-step sequence:

### Step 1: Define Pure Domain Entity
*Location: `lib/features/<feature>/domain/entities/<feature>_response.dart`*
- Must be a pure Dart class with **zero** dependencies on Dio, JSON, or external packages.

```dart
class ProfileResponse {
  final bool status;
  final String message;
  final ProfileData? data;

  const ProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });
}

class ProfileData {
  final int id;
  final String name;
  final String email;

  const ProfileData({
    required this.id,
    required this.name,
    required this.email,
  });
}
```

### Step 2: Define Repository Contract
*Location: `lib/features/<feature>/domain/repositories/<feature>_repository.dart`*
- Returns `Future<Either<ApiException, Entity>>`.

```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/network/app_exception.dart';
import '../entities/profile_response.dart';

abstract class ProfileRepository {
  Future<Either<ApiException, ProfileResponse>> getProfile();
}
```

### Step 3: Implement UseCase
*Location: `lib/features/<feature>/domain/usecases/get_profile_usecase.dart`*
- Single responsibility; constructor-injects the repository contract.

```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/network/app_exception.dart';
import '../entities/profile_response.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<ApiException, ProfileResponse>> call() {
    return repository.getProfile();
  }
}
```

### Step 4: Implement Data Models (Extends Entity)
*Location: `lib/features/<feature>/data/models/<feature>_response_model.dart`*
- Directly extends the domain entity.
- Implements `factory Model.fromJson(Map<String, dynamic> json)`.

```dart
import '../../domain/entities/profile_response.dart';

class ProfileResponseModel extends ProfileResponse {
  ProfileResponseModel({
    required super.status,
    required super.message,
    super.data,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null
          ? ProfileDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProfileDataModel extends ProfileData {
  ProfileDataModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
```

### Step 5: Implement Remote DataSource
*Location: `lib/features/<feature>/data/datasources/<feature>_remote_data_source.dart`*
- Interacts with `ApiClient` and returns Model classes directly.

```dart
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/profile_response_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileResponseModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfileResponseModel> getProfile() async {
    final response = await apiClient.get(Endpoints.profile);
    return ProfileResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
```

### Step 6: Implement Repository Implementation
*Location: `lib/features/<feature>/data/repositories/<feature>_repository_impl.dart`*
- Wraps the data source call with `handleApiCall(() async { ... return Right(result); })`.

```dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/app_exception.dart';
import '../../domain/entities/profile_response.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, ProfileResponse>> getProfile() async {
    return handleApiCall(() async {
      final result = await remoteDataSource.getProfile();
      return Right(result);
    });
  }
}
```

### Step 7: Register Dependencies in `lib/di/locator.dart`
- Order of registration:
  1. `_registerRepositories()`: RemoteDataSource then RepositoryImpl as `registerLazySingleton`.
  2. `_registerUseCases()`: UseCases as `registerLazySingleton`.
  3. `_registerProviders()`: Screen providers as `registerFactory`; global/persisted state as `registerLazySingleton`.

```dart
// In _registerRepositories():
getIt.registerLazySingleton<ProfileRemoteDataSource>(
  () => ProfileRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
);
getIt.registerLazySingleton<ProfileRepository>(
  () => ProfileRepositoryImpl(remoteDataSource: getIt<ProfileRemoteDataSource>()),
);

// In _registerUseCases():
getIt.registerLazySingleton(() => GetProfileUseCase(getIt<ProfileRepository>()));

// In _registerProviders():
getIt.registerFactory(() => ProfileProvider(getProfileUseCase: getIt<GetProfileUseCase>()));
```

### Step 8: Implement Presentation Provider
*Location: `lib/features/<feature>/presentation/providers/<feature>_provider.dart`*
- Extends `ChangeNotifier`.
- Encapsulates private fields with public getters.
- Uses `result.fold((failure) { ... }, (data) { ... })`.

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/profile_response.dart';
import '../../domain/usecases/get_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;

  ProfileProvider({required this.getProfileUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileData? _profile;
  ProfileData? get profile => _profile;

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getProfileUseCase();

    result.fold(
      (failure) {
        _isLoading = false;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (response) {
        _isLoading = false;
        _profile = response.data;
        notifyListeners();
      },
    );
  }
}
```

### Step 9: Implement Screen & Route
*Location: `lib/features/<feature>/presentation/screens/<feature>_screen.dart`*
- Wrap with `ChangeNotifierProvider(create: (_) => getIt<ProfileProvider>()..fetchProfile())`.
- Separate the provider host from the view widget (`_ProfileScreenView`).
- Use `context.watch<ProfileProvider>()` for state, `context.read<ProfileProvider>()` for callbacks.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../di/locator.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ProfileProvider>()..fetchProfile(),
      child: const _ProfileScreenView(),
    );
  }
}

class _ProfileScreenView extends StatelessWidget {
  const _ProfileScreenView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.locale.profileTitle)),
      body: Center(child: Text(provider.profile?.name ?? '')),
    );
  }
}
```

---

## 4. Key Utilities & Conventions

### Global Navigation (`NavigationService`)
Access navigation anywhere without passing `BuildContext`:
```dart
// Push a named route with arguments
navigation.pushNamed(AppRoutes.home, arguments: myData);

// Push and clear stack (e.g. login/logout)
await navigation.pushNamedAndRemoveUntil(AppRoutes.login);

// Pop
navigation.pop();
```

### Global Feedback (`Snackbar`)
Display animated floating toast overlays anywhere without context:
```dart
Snackbar.show('Operation successful!');
Snackbar.show('Invalid phone number', isError: true);
Snackbar.show('Notice from top', fromTop: true);
```

### Core Reusable UI Components
- **`PrimaryButton`**: Brand Neon Lime CTA button with built-in loading indicator (`isLoading: bool`) and `StadiumBorder`.
- **`SecondaryButton`**: Electric Blue CTA button with Neon Lime text and `StadiumBorder`.
- **`AppButton`**: Configurable general-purpose button.
- **`AppTextField`**: Standard text field with error text, prefix/suffix icons, formatters, and dark/light styling.
- **`AppBottomSheet`**: Reusable modal bottomsheet with pill handle or custom close buttons (`AppBottomSheet.show(context, child: ...)`).
- **`AppImageView`**: Unified image loader handling asset, SVG, network (cached), and Lottie images.
- **`ShimmerWidget`**: Shimmer placeholders with `.circular`, `.rectangular`, or `.rounded`.

### Context Extensions
Always leverage `context_extensions.dart`:
- `context.locale`: Type-safe access to `AppLocalizations`.
- `context.width` / `context.height`: Screen dimensions.
- `context.isDarkMode`: Theme brightness check.
- `context.textTheme` / `context.colorScheme`: Material theme tokens.

---

## 5. Quality Checklist for Every Change

1. **Linter & Analyzer**: Always execute `flutter analyze` ensuring **0 warnings/issues**.
2. **Localisation**: Never hardcode user-facing strings; always extract into `lib/l10n/app_en.arb` and run `flutter gen-l10n`.
3. **No Layer Leakage**: Domain entities must never import Dio or JSON converters.
4. **Error Safety**: Repository implementations must wrap remote datasource calls using `handleApiCall`.
5. **Memory Management**: Always dispose controllers and listeners in `Provider` and `StatefulWidget` classes.

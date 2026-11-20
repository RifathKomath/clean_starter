# 🧪 Testing & Verification Standard (10/10)

This guide documents the testing, test suite organization, and regression prevention rules for the Go Safar codebase.

---

## 1. Directory Structure Mirroring (1:1 with `lib/`)

Tests must **never** be placed flatly in the root `test/` directory. The test tree must mirror `lib/` 1:1:

```text
test/
├── app/                       # Tests for AppRoutes and global app configuration
├── core/                      # Tests for core utilities, network, services, and widgets
│   ├── network/               # Interceptors, ApiClient, dio_error_handler tests
│   ├── services/              # LocationService, TokenService, StorageService tests
│   └── widgets/               # PrimaryButton, AppImageView, Snackbar tests
├── features/                  # Tests organized strictly by feature
│   ├── auth/                  # Login, OTP verification tests
│   ├── cab_booking/           # Cab booking screen, provider, responsiveness tests
│   ├── home/                  # HomeScreen, tabs, navbar, tutorial overlay tests
│   ├── rental/                # Rental flow, category, filter, stepper tests
│   ├── shared_booking/        # BookingFlowCoordinator, shared sheet tests
│   └── ...                    # Other feature tests
└── helpers/                   # Test utilities, pump helpers, mock definitions
```

---

## 2. Test Isolation & Global State Hygiene

- **NavigationService Reset**:
  - Always call `NavigationService.resetKey()` in `setUp()` of widget tests that use `AppRoutes` or `NavigationService` to prevent `GlobalKey<NavigatorState>` collision errors across concurrent test executions.
- **Service Locator Setup**:
  - In `setUpAll()`, invoke `WidgetsFlutterBinding.ensureInitialized()` and `await setupLocator()`.
  - In `tearDown()`, ensure all mock registrations or custom listenables are cleared.

---

## 3. Comprehensive Test Coverage Layers

1. **Unit Tests**:
   - Pure Dart domain validators (e.g., `AuthValidator`, `SeniorBookingValidator`).
   - Network error mapping (`dio_error_handler_test.dart`).
   - Flow coordinators (`booking_flow_coordinator_test.dart`).
2. **Widget Tests**:
   - Screen rendering and initial state verification.
   - Interactive user flows (button taps, text inputs, bottom sheet expansion).
   - Responsive design verification across Mobile viewport (390x844) and Tablet viewport (800x1280).
3. **Route Delegate Tests**:
   - Feature routing modules (`app_routes_test.dart`).
   - Type-safe argument parsing with fallback handling.

---

## 4. Mandatory Quality Gate Protocol

Before marking any task as complete:
1. Run `dart analyze lib test` → **0 errors, 0 warnings, 0 infos**.
2. Run `flutter test` → **100% pass rate across all tests**.
3. Generate the 10/10 Verification Block.

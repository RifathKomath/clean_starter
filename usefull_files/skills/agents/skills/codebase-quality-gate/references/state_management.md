# ⚡ State Management & Lifecycle Standard (10/10)

This guide documents the state management, lifecycle scoping, and memory optimization rules for the Go Safar codebase.

---

## 1. Unidirectional Data Flow via Provider

- **State Flows Down, Events Flow Up**:
  - UI widgets strictly consume state from providers.
  - User gestures (taps, drags, inputs) invoke explicit methods on providers.
- **Zero Business Logic in Presentation Widgets**:
  - Widgets must never perform calculations, timer mutations, or coordinate multi-step workflows inline.
  - All state mutation logic must live within feature providers.

---

## 2. Scoped Provider Lifecycles & Factory Registration

- **No Global Singletons for Feature State**:
  - Screen state must never be stored in global singletons.
  - Feature providers are registered as `registerFactory` in `lib/di/locator.dart`.
- **Subtree Scoping**:
  - Scope providers to their respective feature subtrees using `ChangeNotifierProvider(create: (_) => getIt<MyFeatureProvider>())` at the screen/route boundary.
  - When passing an existing provider down a sub-route (e.g., checkout flows), use `ChangeNotifierProvider.value(value: existingProvider)` and check `!existingProvider.isDisposed`.

---

## 3. Booking Engine Flow Coordination

All simulated booking workflows (Cab, Teens, Seniors, Rentals) must inherit from `BookingFlowCoordinator`:

- **Unified Flow Machinery**:
  - Use `scheduleDriverMatching()`, `scheduleDriverArrival()`, and `scheduleTripStart()` rather than declaring bespoke `Timer` instances.
  - Call `cancelAllBookingTimers()` on step backtracks, cancellations, or new requests.
- **Memory Safety Guard**:
  - Always guard asynchronous callbacks with `if (isDisposed) return;`.
  - Override `notifyListeners()` with a disposal guard:
    ```dart
    @override
    void notifyListeners() {
      if (isDisposed) return;
      super.notifyListeners();
    }
    ```

---

## 4. Rebuild Optimization: Granular Context Selectors

- **Avoid Root Rebuilds**:
  - Do not use `context.watch<MyProvider>()` at screen root widgets containing complex visual trees or animations.
- **Granular Selectors**:
  - Use `context.select<MyProvider, T>((p) => p.myValue)` to subscribe only to specific value changes.
  - Wrap localized visual components in `Consumer<MyProvider>` to constrain rebuild boundaries.

---

## 5. Mandatory Resource Disposal

Every stateful widget and provider must rigorously clean up all resources in `dispose()`:

| Resource Type | Disposal Requirement |
| :--- | :--- |
| `TextEditingController` | Explicit `controller.dispose()` in `State.dispose()` |
| `AnimationController` | Explicit `controller.dispose()` in `State.dispose()` |
| `FocusNode` | Explicit `node.dispose()` in `State.dispose()` |
| `ScrollController` | Explicit `controller.dispose()` in `State.dispose()` |
| `StreamSubscription` | Explicit `subscription.cancel()` in `dispose()` |
| ValueListenable Listener | Explicit `listenable.removeListener(_callback)` in `dispose()` |
| `BookingFlowCoordinator` | Explicit `super.dispose()` auto-cancelling all active timers |

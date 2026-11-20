# Mandatory 10/10 Engineering & Architecture Standard

This rule is unconditionally active on every task, prompt, refactor, widget creation, or bug fix within the `go-safar` codebase.

## Core Directives

1. **Pre-Flight Validation**:
   - Before writing or editing any code, verify Clean Architecture compliance (Presentation $\to$ Domain $\to$ Data $\to$ Core).
   - Domain logic (validation, business rules, entities) must NEVER import Flutter UI libraries or network clients.
   - All state must be properly scoped using `ChangeNotifierProvider` with factory registration in `lib/di/locator.dart`.

2. **Zero Regressions & Zero Lint Issues**:
   - Never complete a task that leaves analyzer errors or warnings. `dart analyze lib test` must pass with `No issues found!`.
   - Never break existing tests. All tests must pass with `flutter test` (100% pass rate).
   - Never use force-unwraps (`!`) on nullable values unless proven non-null by preceding assertions/guards.
   - Never use magic numbers, hardcoded colors, or raw text styles. Always reference `AppColors`, `AppDimensions`, `AppTheme`, and `AppRoutes`.
   - Never use `Image.asset`, `Image.file`, `Image.network`, or `SvgPicture.asset` directly. Always use `AppImageView` for unified, consistent asset and vector rendering.

3. **Performance & Memory Mandate**:
   - All controllers, tickers, subscriptions, and focus nodes must have corresponding calls in `dispose()`.
   - All custom painters with continuous animations or fluidic math must be wrapped in `RepaintBoundary`.
   - Use `MediaQuery.sizeOf(context)`, `MediaQuery.paddingOf(context)`, and `MediaQuery.viewInsetsOf(context)` instead of `MediaQuery.of(context)`.

4. **Self-Verification Protocol**:
   - Every assistant response that modifies code must end with the mandatory 10/10 Quality Verification block:

```markdown
✅ 10/10 Quality Verification:
- Architecture & Layering: Pass (Clean separation confirmed)
- State Scoping & Lifecycles: Pass (Disposals & controllers verified)
- Performance & DRY: Pass (No redundant rebuilds, tokens reused)
- Zero Regressions: Pass (Score maintained at 10/10)
```

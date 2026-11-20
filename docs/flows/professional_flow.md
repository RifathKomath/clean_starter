# Professional flow

From choosing the professional path to the professional home. Route names are
the constants in `lib/app/app_routes.dart`.

## 1. Shared entry

Same as the other flows: Splash → `onboarding` → "Get Started" →
`accountCreation` → `otpForm` → verified dialog → `learningPathSelection`.

## 2. Path choice and profile

| # | Screen | Route | Next |
|---|--------|-------|------|
| 1 | Learning path | `learningPathSelection` | any card other than the first one → `professionalStudentInfo`. The first card goes to `learningModeSelection` (one-to-one and batch). |
| 2 | Professional student info | `professionalStudentInfo` (`lib/features/professional/professional_student_info`) | "Continue" (after validation) or "Skip" → **professional home** |

The professional flow has no mode, plan, teacher or base test steps. Nothing in
the one-to-one or batch flows is used here.

## 3. Home

Both buttons clear the stack and open `baseScreen` with
`AppCategory.professional`, which shows the professional home
(`lib/features/professional/home/presentation/screen/home_screen.dart`).

From the home the student can browse courses. That is a separate flow: explore
course → course details → checkout → success → back to the home, in
`lib/features/professional/explore_course`.

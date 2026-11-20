# Batch flow

From choosing Batch Learning to the batch home. Route names are the constants in
`lib/app/app_routes.dart`.

## 1. Shared entry

Same as the one-to-one flow: Splash → `onboarding` → "Get Started" →
`accountCreation` → `otpForm` → verified dialog → `learningPathSelection`. The
first learning path card leads to `learningModeSelection`.

## 2. Setup (configure)

The mode passed along the route is `LearningModeType.batch`.

| # | Screen | Route | Next |
|---|--------|-------|------|
| 1 | Learning mode | `learningModeSelection` | choose "Batch Learning" → "Let's Go" → `studentInfoForm` |
| 2 | Student info | `studentInfoForm` | → `parentInfoForm` |
| 3 | Parent info | `parentInfoForm` | "Continue" → `batchPlans` (one-to-one goes to `choosingSubject` instead) |

The batch flow never reaches the subject, learning goal, chapter, timeline or
slot screens, `configurationReview`, or any teacher or demo screen. Those belong
to one-to-one only. The choice is made in
`parent_info_form_screen.dart` (`_goToNextScreen`), by `learningMode`.

## 3. Batch and fee plan (`lib/features/batch/plans`)

| # | Screen | Route | Next |
|---|--------|-------|------|
| 4 | Choose your batch | `batchPlans` | "View Details" → `batchDetail` |
| 5 | Batch detail | `batchDetail` | button → `plansListing` |
| 6 | Choose your fee plan | `plansListing` | "Proceed to Payment" → `planSuccess` |
| 7 | Enrolled | `planSuccess` | "Start Base Test" → `baseTestIntro`; "Continue to Home" → batch home. System back is blocked. |

## 4. Base test (`lib/features/batch/base_test`)

| # | Screen | Route | Next |
|---|--------|-------|------|
| 8 | Intro | `baseTestIntro` | "Let's Start The Base Test" → `subjectSelection` (back button shown) |
| 9 | Subject selection | `subjectSelection` | pick a subject → `baseTestQuestion` |
| 10 | Questions | `baseTestQuestion` | finish → `baseTestSubmission` (replace) |
| 11 | Submission | `baseTestSubmission` | each subject: back to `subjectSelection`; after the last subject → `baseLine` (replace) |
| 12 | Baseline | `baseLine` | "Continue" → **batch home**; "Review" → `reviewAnswers`, whose "Go to Home" also opens the batch home |

The home that opens is `BaseTestProgressProvider.category`
(`batch/base_test/presentation/provider/base_test_progress_provider.dart`). The
batch entry points call `openBaseTest(context, AppCategory.batch)`
(`batch/base_test/presentation/utils/base_test_navigation.dart`) so the category
is always set when the test starts. Progress is kept per category, so a
one-to-one base test never marks the batch one as done, and the other way
round.

## 5. Home

`baseScreen` with `AppCategory.batch` shows `BatchHomeScreen(isOneToOne: false)`
(`lib/features/batch/home/presentation/screens/home_screen.dart`):

- **Base test not finished:** batch plan summary, the base test banner ("Your
  Next Step") and the batch time table.
- **Base test finished:** featured class, upcoming classes, baseline summary,
  batch time table and homework.

The banner starts the base test again with the batch category.

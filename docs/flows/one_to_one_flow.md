# One-to-One flow

From choosing One-to-One Learning to the one-to-one home. Screens live in
`lib/features/one_to_one/...` unless a path says otherwise. Route names are the
constants in `lib/app/app_routes.dart`.

## 1. Shared entry (all three flows)

| # | Screen | Route | Next |
|---|--------|-------|------|
| 1 | Splash | `/` | `onboarding` (replace) |
| 2 | Onboarding | `onboarding` | "Get Started" → `accountCreation` |
| 3 | Account | `accountCreation` | sign in → `otpForm` |
| 4 | OTP | `otpForm` | verified dialog → `learningPathSelection` |
| 5 | Learning path | `learningPathSelection` | first card → `learningModeSelection`, other card → `professionalStudentInfo` (see the professional flow) |

## 2. Setup (configure)

The chosen mode (`LearningModeType.oneToOne`) is passed as the route argument
through every screen below. If a screen forgets to pass it, the mode falls back
to one-to-one.

| # | Screen | Route | Next |
|---|--------|-------|------|
| 6 | Learning mode | `learningModeSelection` | "Let's Go" → `studentInfoForm` |
| 7 | Student info | `studentInfoForm` | → `parentInfoForm` |
| 8 | Parent info | `parentInfoForm` | one-to-one → `choosingSubject` (batch goes to `batchPlans` instead) |
| 9 | Subjects | `choosingSubject` | → `choosingLearningGoal` |
| 10 | Learning goal | `choosingLearningGoal` | → `chapterSelection` |
| 11 | Chapters | `chapterSelection` | → `timelineSetting` |
| 12 | Timeline | `timelineSetting` | → `sloteSelection` |
| 13 | Slots | `sloteSelection` | → `configurationReview` |
| 14 | Review | `configurationReview` | "Submit Onboarding" → `teacherListing` |

## 3. Teacher selection and demos (`teacher_selection`)

| # | Screen | Route | Next |
|---|--------|-------|------|
| 15 | Matched teachers | `teacherListing` | "View Details" → `teacherInfo` |
| 16 | Teacher info | `teacherInfo` | "Confirm Teacher" → `teacherSelected`; "Schedule Demo" → `demoConfirmation` |
| 17 | Demo confirmed | `demoConfirmation` | "Continue with Another Teacher" → `teacherListing` (clears the stack to the first route); "View Demo Journey" → `demoJourney` |
| 18 | Teacher selected | `teacherSelected` | button → `demoSuccess` |
| 19 | Demo journey | `demoJourney` | each card's "Demo Details" → `meetingLinkPreparing`. If every demo is already completed when it opens, it is replaced by `demoSuccess`. System back is blocked. |
| 20 | Link preparing | `meetingLinkPreparing` | after 3 s → `meetingLinkPrepared` (fade, replaces). System back is blocked. |
| 21 | Link prepared | `meetingLinkPrepared` | "Join Demo Class" → `demoCompletion`; "Reschedule Demo Class" → `teacherInfo` |
| 22 | How was your demo | `demoCompletion` | "Confirm This Teacher" marks the demo completed, then: all demos done → `demoSuccess`; first teacher → `demoConfirmation`; otherwise → `teacherSelected`. "Continue with Another Teacher" → `teacherListing`. |
| 23 | Selection complete | `demoSuccess` (`domo_success_screen.dart`) | "Generate Study Plan" → `studyPlanCreation`; "Continue Later from Home" → home with the review-pending design |

Completion is tracked in `DemoJourneySession`
(`teacher_selection/presentation/provider/demo_journey_session.dart`), per
teacher name, in memory only.

## 4. Study plan (`ai_study_plan`)

| # | Screen | Route | Next |
|---|--------|-------|------|
| 24 | Creating plan | `studyPlanCreation` | after about 6 s → `studyPlanListing` (replace). System back is blocked. |
| 25 | Study plan | `studyPlanListing` | "Review Plan" → `studyPlanDetail` ("Mark as Reviewed" goes back); "Send for Teacher Review" → `planReviewing` |
| 26 | Teacher reviewing | `planReviewing` | after 2 s → `studyPlanApproved` (replace); "Go to Home" → review-pending home; the two cards → Batch or Professional home. System back is blocked. |
| 27 | Plan approved | `studyPlanApproved` | "Explore Learning Plans" → `learningPlans`; "View Details" → `studyPlanListing` |

Changes-requested side flow (reached from the home card): home "Continue Set Up"
→ `planReviewStatus` → "View Changes" → `changeRequest` → "Send For Teacher
Review" → `planReviewing` with a subject (teacher tile variant) → after 2 s
→ `studyPlanApproved`.

## 5. Plan purchase and enrollment

| # | Screen | Route | Next |
|---|--------|-------|------|
| 28 | Choose learning plan | `learningPlans` | pick the recommended, 10 or 30 sessions plan → `planInfo` |
| 29 | Review your plan | `planInfo` | "Proceed To Payment" → `enrollSuccess` |
| 30 | Enrolled | `enrollSuccess` | "Start Base Test" → `baseTestIntro` (no back button, system back blocked). Clears the review-pending flag. |

## 6. Base test (`lib/features/batch/base_test`, shared with batch)

| # | Screen | Route | Next |
|---|--------|-------|------|
| 31 | Intro | `baseTestIntro` | "Let's Start The Base Test" → `subjectSelection` |
| 32 | Subject selection | `subjectSelection` | pick a subject → `baseTestQuestion` |
| 33 | Questions | `baseTestQuestion` | finish → `baseTestSubmission` (replace) |
| 34 | Submission | `baseTestSubmission` | each subject: back to `subjectSelection`; after the last subject → `baseLine` (replace) |
| 35 | Baseline | `baseLine` | "Continue" → **one-to-one home** (`baseScreen` with `AppCategory.oneToOne`, clearing the stack) |

Which home opens at step 35 is decided by
`BaseTestProgressProvider.category`, which `openBaseTest(...)`
(`batch/base_test/presentation/utils/base_test_navigation.dart`) sets when the
test starts. Progress is stored per category, so batch and one-to-one never
share results.

## 7. Home

`baseScreen` with `AppCategory.oneToOne` shows `BatchHomeScreen(isOneToOne: true)`
(`lib/features/batch/home/presentation/screens/home_screen.dart`):

- **Review pending** (`DemoJourneySession.isStudyPlanPending` is true): "Your
  Learning Journey Is Taking Shape!", the Teacher Review Pending card and the
  "Your Next Steps" cards. Set by "Continue Later from Home" and "Go to Home".
- **Learning journey** (flag cleared): featured class, upcoming classes,
  study plan subjects, the base test banner and homework. The baseline summary
  appears only after all base test subjects are finished.

## Placeholders to replace with real data

Demo schedule (Tuesday, 22 September), topics and durations on the demo
screens, dummy teachers for Physics, English and Chemistry, plan prices, the
changes requested, the 3-of-4 review count, and the 3 s, 2 s and 6 s waits.

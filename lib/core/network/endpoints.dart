class Endpoints {
  static const String sendOTP = "auth/otp/request/";
  static const String verifyOtp = "auth/otp/verify/";
  static const String refreshToken = "auth/token/refresh/";
  static const String logout = "auth/logout/";
  static const String onboardingCategories = "onboarding/categories/";
  static const String onboardingCategorySelect =
      "onboarding/categories/select/";
  static const String devices = "auth/devices/";
  static String onboardingLearningModes(String categoryId) =>
      "onboarding/categories/$categoryId/learning-modes/";
  static const String academicCountries = "academic/countries/";
  static const String academicLevels = "academic/academic-levels/";
  static const String academicSubjects = "academic/subjects/";
  static String academicSubjectChapters(String subjectId) =>
      "academic/subjects/$subjectId/chapters/";
  static const String tuitionLearningGoals = "tuition/learning-goals/";
  static const String tuitionCompletionTimelines =
      "tuition/completion-timelines/";
  static const String tuitionOnboardingSubmit = "tuition/onboarding/submit/";
  static const String academicBoards = "academic/boards/";
  static const String academicGrades = "academic/grades/";
}

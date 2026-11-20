import 'package:flutter/material.dart';
import 'package:my_mentor/core/services/navigation_service.dart';
import 'package:my_mentor/di/locator.dart';
import 'package:my_mentor/l10n/app_localizations.dart';
import 'package:my_mentor/core/theme/app_theme.dart';
import '../core/extensions/context_extensions.dart';
import 'app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'My Mentor Club',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.lightTheme,
          initialRoute: AppRoutes.splash,
          navigatorKey: getIt<NavigationService>().navigationKey,
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          onUnknownRoute: AppRoutes.onUnknownRoute,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}

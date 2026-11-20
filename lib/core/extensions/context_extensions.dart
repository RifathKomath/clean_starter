import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../l10n/app_localizations.dart';

extension ContextExtensions on BuildContext {
  AppLocalizations get locale => AppLocalizations.of(this)!;
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }

  bool get isTablet {
    return width >= 600;
  }

  double w(num value) => value.w;
  double h(num value) => value.h;
}

extension NumberExtension on num {
  /// <b>SizedBox(height: 8)<b/>
  Widget get hBox => SizedBox(height: toDouble().h);

  /// <b>SizedBox(width: 8)<b/>
  Widget get wBox => SizedBox(width: toDouble().w);
}

extension PaddingExtension on Widget {
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
  Widget paddingSymmetricHorizontal(double value) => Padding(
    padding: EdgeInsets.symmetric(horizontal: value),
    child: this,
  );
  Widget paddingSymmetricVertical(double value) => Padding(
    padding: EdgeInsets.symmetric(vertical: value),
    child: this,
  );
  Widget paddingHorVert(double value1, double value2) => Padding(
    padding: EdgeInsets.symmetric(horizontal: value1, vertical: value2),
    child: this,
  );
}

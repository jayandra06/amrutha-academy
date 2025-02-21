import 'package:flutter/material.dart';

class AppColors {
  final Color primary500;
  final Color primary400;
  final Color primary300;
  final Color primary200;
  final Color primary100;

  final Color secondary500;
  final Color secondary400;
  final Color secondary300;
  final Color secondary200;
  final Color secondary100;

  final Color success;
  final Color info;
  final Color warning;
  final Color error;
  final Color disable;
  final Color disableButton;

  final Color greyscale900;
  final Color greyscale800;
  final Color greyscale700;
  final Color greyscale600;
  final Color greyscale500;
  final Color greyscale400;
  final Color greyscale300;
  final Color greyscale200;
  final Color greyscale100;
  final Color greyscale50;

  final Color backgroundBlue;
  final Color backgroundGreen;
  final Color backgroundOrange;
  final Color backgroundPink;
  final Color backgroundYellow;
  final Color backgroundPurple;

  final Color transparentBlue;
  final Color transparentGreen;
  final Color transparentOrange;
  final Color transparentRed;
  final Color transparentYellow;
  final Color transparentCyan;

  final Color otherWhite;

  final LinearGradient gradientBlue;
  final LinearGradient gradientYellow;
  final LinearGradient gradientGreen;
  final LinearGradient gradientOrange;
  final LinearGradient gradientRed;

  final Color scaffoldColor;

  static late AppColors current;

  AppColors({
    required this.primary500,
    required this.primary400,
    required this.primary300,
    required this.primary200,
    required this.primary100,
    required this.secondary500,
    required this.secondary400,
    required this.secondary300,
    required this.secondary200,
    required this.secondary100,
    required this.success,
    required this.info,
    required this.warning,
    required this.error,
    required this.disable,
    required this.disableButton,
    required this.greyscale900,
    required this.greyscale800,
    required this.greyscale700,
    required this.greyscale600,
    required this.greyscale500,
    required this.greyscale400,
    required this.greyscale300,
    required this.greyscale200,
    required this.greyscale100,
    required this.greyscale50,
    required this.backgroundBlue,
    required this.backgroundGreen,
    required this.backgroundOrange,
    required this.backgroundPink,
    required this.backgroundYellow,
    required this.backgroundPurple,
    required this.transparentBlue,
    required this.transparentGreen,
    required this.transparentOrange,
    required this.transparentRed,
    required this.transparentYellow,
    required this.transparentCyan,
    required this.otherWhite,
    required this.scaffoldColor,
    required this.gradientBlue,
    required this.gradientGreen,
    required this.gradientOrange,
    required this.gradientYellow,
    required this.gradientRed,
  });

  static AppColors of(BuildContext context) {
    final appColor = Theme.of(context).appColor;

    current = appColor;

    return current;
  }

  static get defaultAppColor => AppColors(
        primary500: const Color(0xff335EF7),
        primary400: const Color(0xff5C7EF9),
        primary300: const Color(0xff859EFA),
        primary200: const Color(0xffADBFFC),
        primary100: const Color(0xffEBEFFE),
        secondary500: const Color(0xffFFD300),
        secondary400: const Color(0xffFFDC33),
        secondary300: const Color(0xffFFE566),
        secondary200: const Color(0xffFFED99),
        secondary100: const Color(0xffFFFBE6),
        success: const Color(0xff4ADE80),
        info: const Color(0xff246BFD),
        warning: const Color(0xffFACC15),
        error: const Color(0xffF75555),
        disable: const Color(0xffD8D8D8),
        disableButton: const Color(0xff4360C9),
        greyscale900: const Color(0xff212121),
        greyscale800: const Color(0xff424242),
        greyscale700: const Color(0xff616161),
        greyscale600: const Color(0xff757575),
        greyscale500: const Color(0xff9E9E9E),
        greyscale400: const Color(0xffBDBDBD),
        greyscale300: const Color(0xffE0E0E0),
        greyscale200: const Color(0xffEEEEEE),
        greyscale100: const Color(0xffF5F5F5),
        greyscale50: const Color(0xffFAFAFA),
        backgroundBlue: const Color(0xffF6FAFD),
        backgroundGreen: const Color(0xffF2FFFC),
        backgroundOrange: const Color(0xffFFF8ED),
        backgroundPink: const Color(0xffFFF5F5),
        backgroundYellow: const Color(0xffFFFEE0),
        backgroundPurple: const Color(0xffFCF4FF),
        transparentBlue: const Color(0xff335EF7).withOpacity(.08),
        transparentGreen: const Color(0xff4CAF50).withOpacity(.08),
        transparentOrange: const Color(0xffFF9800).withOpacity(.08),
        transparentRed: const Color(0xffF75555).withOpacity(.08),
        transparentYellow: const Color(0xffFACC15).withOpacity(.08),
        transparentCyan: const Color(0xff335EF7).withOpacity(.08),
        otherWhite: const Color(0xffFFFFFF),
        scaffoldColor: const Color(0xffF9F9F9),
        gradientBlue: const LinearGradient(
          colors: [Color(0xff5F82FF), Color(0xff335EF7)],
        ),
        gradientGreen: const LinearGradient(
          colors: [Color(0xff35DEBC), Color(0xff22BB9C)],
        ),
        gradientOrange: const LinearGradient(
          colors: [Color(0xffFFAB38), Color(0xffFB9400)],
        ),
        gradientYellow: const LinearGradient(
          colors: [Color(0xffFFE580), Color(0xffFACC15)],
        ),
        gradientRed: const LinearGradient(
          colors: [Color(0xffFF8A9B), Color(0xffFF4D67)],
        ),
      );
}

enum AppThemeType { light, dark }

extension AppThemeDataExtension on ThemeData {
  static final Map<AppThemeType, AppColors> _appColorMap = {};

  void addAppColor(AppThemeType type, AppColors appColor) {
    _appColorMap[type] = appColor;
  }

  AppColors get appColor {
    return _appColorMap[AppThemeSetting.currentAppThemeType] ?? AppColors.defaultAppColor;
  }
}

class AppThemeSetting {
  const AppThemeSetting._();
  static AppThemeType currentAppThemeType = AppThemeType.light;
}

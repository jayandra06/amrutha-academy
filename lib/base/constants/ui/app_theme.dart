import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';

abstract final class AppTheme {
  const AppTheme._();

  static const fontFamily = 'Urbanist';

  static ThemeData get light => ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      tabBarTheme: TabBarTheme(
          indicatorColor: AppColors.current.primary500,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: AppTextStyles.bodyXLargeSemiBold.copyWith(color: AppColors.current.primary500),
          unselectedLabelStyle: AppTextStyles.bodyXLargeSemiBold.copyWith(color: AppColors.current.greyscale500),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 4, color: AppColors.current.primary500),
            borderRadius: BorderRadius.circular(100),
          )));

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
      );
}

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBackground,
      fontFamily: 'SF Pro Display', // Make sure this font is in pubspec.yaml
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        background: AppColors.scaffoldBackground,
        primary: AppColors.primaryGreen,
        error: AppColors.errorRed,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textBlack, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.textBlack,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: AppTextStyles.buttonText.copyWith(fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppDimensions.paddingLarge),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),

      // TextField Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.greyLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}
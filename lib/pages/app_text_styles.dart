import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textBlack,
  );

  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textBlack,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 15,
    color: Color.fromARGB(137, 15, 15, 15),
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 18,
    color: AppColors.white,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle linkText = TextStyle(
    color: AppColors.primaryGreen,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}
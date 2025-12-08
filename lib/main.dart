
import 'package:agronom_ai/registerProvider/registerProvider.dart';
import 'package:agronom_ai/pages/favorites_provider.dart';
import 'package:agronom_ai/registerProvider/ai_doctor_provider.dart';
import 'package:agronom_ai/pages/initial_page.dart';

import 'package:agronom_ai/registerProvider/profile_provider.dart';
import 'package:agronom_ai/service/storage_service.dart';
import 'package:agronom_ai/weatherpages/weather_provider.dart';
import 'package:flutter/material.dart';

import 'registerProvider/login_provider.dart';
import 'registerProvider/verify_provider.dart';
import 'pages/app_colors.dart';


void main() async {
  // Ilova ishga tushishidan oldin kerakli sozlamalarni yuklash
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init(); // StorageService'ni ishga tushiramiz. Boshqa tekshiruvlar InitialPage'da bo'ladi.

  runApp(
    MultiProvider(
      providers: [
        // Barcha global provider'larni shu yerga qo'shamiz
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => VerifyProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()), // WeatherProvider qo'shildi
        ChangeNotifierProvider(create: (_) => AiDoctorProvider()), // AI Doktor uchun provider
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // Favorites uchun provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgronomAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green).copyWith(
          error: AppColors.errorRed,
          secondary: AppColors.accentGreen,
        ),
      ),
      // Barcha holatlarni tekshirish uchun har doim InitialPage'dan boshlaymiz
      home: const InitialPage(),
    );
  }
}

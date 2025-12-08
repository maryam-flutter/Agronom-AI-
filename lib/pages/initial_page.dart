import 'package:agronom_ai/onboarding/onboarding_screen.dart';
import 'package:agronom_ai/pages/home_page_nav.dart';
import 'package:agronom_ai/pages/login_page.dart';
import 'package:agronom_ai/register/registerpage.dart';

import 'package:agronom_ai/service/storage_service.dart';
import 'package:flutter/material.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    // build metodi tugagandan so'ng tekshiruvni boshlaymiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final storageService = StorageService();
    if (!mounted) return;

    // Barcha holatlarni parallel ravishda tekshiramiz
    final results = await Future.wait([
      storageService.getAuthToken(),
      storageService.hasCompletedRegistration(),
      storageService.hasCompletedOnboarding(),
    ]);

    final token = results[0] as String?;
    final hasRegistered = results[1] as bool;
    final hasSeenOnboarding = results[2] as bool;

    // --- ASOSIY MANTIQ ---
    // Ilova holatini tekshirib, kerakli sahifaga yo'naltirish

    Widget nextPage;
    if (token != null) {
      // Agar token mavjud bo'lsa, foydalanuvchi tizimga kirgan, Bosh sahifaga o'tamiz
      nextPage = const HomePageNav();
    } else if (hasSeenOnboarding) {
      // Onboarding ko'rilgan, lekin tizimga kirmagan (token yo'q).
      // Ro'yxatdan o'tgan bo'lsa Login, aks holda Register sahifasiga o'tamiz.
      nextPage = hasRegistered ? const LoginPage() : const RegisterPage();
    } else {
      // Hech qaysi holat bajarilmagan bo'lsa, eng boshidan boshlaymiz
      nextPage = const OnboardingScreen();
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => nextPage));
  }

  @override
  Widget build(BuildContext context) {
    // Ilova ochilguncha oddiy yuklanish ekrani
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
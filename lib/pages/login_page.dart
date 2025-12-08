import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../register/registerpage.dart';
import 'app_colors.dart';
import 'app_assets.dart';
import 'app_strings.dart';
import 'sms_login1.dart';
import '../registerProvider/login_provider.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  bool get _isEmailValid =>
      _emailController.text.trim().isNotEmpty &&
      _emailController.text.contains('@');

  void _login() async {
    final provider = Provider.of<LoginProvider>(context, listen: false);
    if (!_isEmailValid || provider.isLoading) return;

    final email = _emailController.text.trim();
    await provider.login(email);

    if (!mounted) return;

    if (provider.isSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmsLoginPage(
            email: email,
          ),
        ),
      );
    } else {
      // Xatolikni SnackBar orqali ko'rsatish
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // LayoutBuilder yordamida ekran o'lchamiga qarab moslashamiz
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Planshetlar uchun kengroq padding, telefonlar uchun standart
              final isTablet = constraints.maxWidth > 600;
              final horizontalPadding = isTablet ? constraints.maxWidth * 0.2 : 24.0;

              return Consumer<LoginProvider>(
                builder: (context, provider, child) {
                  final _isLoading = provider.isLoading;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
                    child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Logo
                    Image.asset(
                      AppAssets.logo, // Markazlashtirilgan assetdan foydalanish
                      height: 100,
                    ),
                    const SizedBox(height: 32),
                    // Title
                    const Text(
                      AppStrings.login,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.enterEmail,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "@email.com",
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),                
                    const SizedBox(height: 32),
                    // Kirish button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: GestureDetector(
                        onTap: _isEmailValid && !_isLoading ? () => _login() : null,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _isEmailValid
                                ? const LinearGradient(
                                    colors: [Color(0xFF00E1D4), Color(0xFF23C96C)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: _isEmailValid ? null : Colors.grey[300],
                            boxShadow: _isEmailValid
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  AppStrings.login,
                                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Ro'yxatdan o'tish sahifasiga o'tish
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Hisobingiz yo'qmi? ",
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () {
                            // LoginPage o'rniga RegisterPage'ni ochamiz
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            "Ro'yxatdan o'tish",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
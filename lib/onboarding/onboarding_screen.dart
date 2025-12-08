

import 'package:agronom_ai/register/registerpage.dart';
import 'package:agronom_ai/service/storage_service.dart';
import 'package:flutter/material.dart';

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/kk.jpg',
      title: "Xush kelibsiz!",
      subtitle: "Sun'iy intellekt bilan aqlli dehqonchilik",
    ),
    OnboardingData(
      image: 'assets/ll.jpg',
      title: "Oson va qulay",
      subtitle: "Barcha ma'lumotlar bir joyda jam bo'lgan",
    ),
    OnboardingData(
      image: 'assets/pp.jpg',
      title: "Aqlli dehqonchilik",
      subtitle: "Ekinlarni AI bilan tahlil qiling",
    ),
    OnboardingData(
      image: 'assets/phone.jpg',
      title: "Kasallikni aniqlang",
      subtitle: "Rasm yuklang va bir zumda davo oling",
    ),
    OnboardingData(
      image: 'assets/oo.jpg',
      title: "Hosilingizni himoya qiling",
      subtitle: "AI kasallikni aniqlab, samarali yechim beradi",
    ),
    OnboardingData(
      image: 'assets/ss.jpg',
      title: "AI agronom - siz bilan",
      subtitle: "O'simlik dori, xarita - barchasi shu yerda",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onButtonPressed() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Onboarding ko'rilganini saqlab qo'yamiz
      final storageService = StorageService(); // Singleton orqali bitta nusxa olinadi
      await storageService.saveOnboardingCompletion();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final pageData = _pages[index];
                  // Har bir sahifa indeksi uchun mos dizan
                  if (index < 2) {
                    return _ColumnLayoutPage(
                      pageData: pageData,
                      index: index,
                    );
                  } else {
                    return _StackLayoutPage(
                      pageData: pageData,
                      // 6-sahifada logotip ko'rsatish uchun
                      showLogo: index == 5,
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E1D4), Color(0xFF23C96C)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            _currentPage == _pages.length - 1 ? "Boshlash" : "Keyingisi",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// 1 va 2-sahifalar uchun Column'li dizayn
class _ColumnLayoutPage extends StatelessWidget {
  final OnboardingData pageData;
  final int index;

  const _ColumnLayoutPage({required this.pageData, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 80),
        Text(
          pageData.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            pageData.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Rasm dizaynini indeksga qarab o'zgartiramiz
        if (index == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                pageData.image,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          )
        else if (index == 1)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(150),
                  bottomRight: Radius.circular(150),
                ),
                child: Image.asset(
                  pageData.image,
                  height: 280,
                  width: MediaQuery.of(context).size.width * 0.85,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        const Spacer(),
      ],
    );
  }
}

// 3, 4, 5, 6-sahifalar uchun Stack'li dizayn
class _StackLayoutPage extends StatelessWidget {
  final OnboardingData pageData;
  final bool showLogo;

  const _StackLayoutPage({required this.pageData, this.showLogo = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Image.asset(
            pageData.image,
            fit: BoxFit.cover,
          ),
        ),
        if (showLogo)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            left: 0,
            right: 28,
            child: Center(
              child: Image.asset('assets/logo.png', width: 120, height: 120),
            ),
          ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.48,
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipPath(
            clipper: _TopOvalClipper(),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(30, 100, 30, 0),
              child: Column(
                children: [
                  Text(
                    pageData.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pageData.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Oval kesim uchun CustomClipper
class _TopOvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 60); // Boshlanish nuqtasi
    path.quadraticBezierTo(size.width / 2, -30, size.width, 60);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
import 'dart:async';

import 'package:agronom_ai/registerProvider/ai_doctor_provider.dart';
import 'package:agronom_ai/pages/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'results_page.dart';

class AnalysisLoadingPage extends StatefulWidget {
  final String imagePath;
  final String selectedCategory;
  final AiDoctorResult? preloadedResult; // Oldindan yuklangan natija

  const AnalysisLoadingPage({
    Key? key,
    required this.imagePath,
    required this.selectedCategory,
    this.preloadedResult,
  }) : super(key: key);

  @override
  State<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends State<AnalysisLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();

    // Sahifa to'liq chizilib bo'lgandan so'ng tahlilni boshlaymiz.
    // Bu `context` bilan bog'liq xatoliklarning oldini oladi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Animatsiya va tahlilni bir vaqtda ishga tushiramiz
      // va ikkalasi ham tugashini kutamiz.
      Future.wait([
        _startAnalysis(),
        _controller.forward().orCancel,
      ]);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    final provider = Provider.of<AiDoctorProvider>(context, listen: false);
    final success = await provider.analyzeImage(
      imagePath: widget.imagePath,
      category: widget.selectedCategory,
    );

    // Animatsiya tugashini kutamiz (agar u hali tugamagan bo'lsa)
    await _controller.forward().orCancel;

    // Navigatsiyadan oldin 'mounted' holatini tekshiramiz
    if (mounted) {
      if (success) {
        final result = provider.result!;
        if (!result.isLeaf) {
          // Agar barg aniqlanmasa, dialog ko'rsatib, orqaga qaytamiz.
          await _showInvalidImageDialog(result.description);
          if (mounted) Navigator.pop(context);
        } else {
          // Aks holda, natijalar sahifasiga o'tamiz
          _navigateToResults(result);
        }
      } else {
        // Xatolik yuz bersa, foydalanuvchiga xabar ko'rsatish va orqaga qaytish
        final errorMessage = provider.errorMessage ?? "Tahlil qilishda noma'lum xatolik.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: AppColors.errorRed));
        Navigator.pop(context);
      }
    }
  }

  // Natijalar sahifasiga o'tish funksiyasi
  void _navigateToResults(AiDoctorResult result) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          imagePath: widget.imagePath,
          category: widget.selectedCategory,
          result: result,
        ),
      ),
    );
  }

  // Noto'g'ri rasm yuklanganda chiqadigan dialog oynasi
  Future<void> _showInvalidImageDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [ // O'zgartirildi
              Icon(Icons.error_outline, color: AppColors.warningOrange),
              SizedBox(width: 10),
              Text("Diqqat!", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message, // Serverdan kelgan xabar (masalan, "Barg aniqlanmadi...")
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                "Iltimos, quyidagilarga e'tibor bering:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              const ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                title: Text("Faqat bargning o'zini rasmga oling.", style: TextStyle(fontSize: 14)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                title: Text("Rasm aniq va yorug' bo'lsin.", style: TextStyle(fontSize: 14)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tushunarli", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'AI Tahlil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Gradient Progress Indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _animation.value,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF23C96C)),
                  // ShaderMask bilan gradient qilish mumkin, lekin oddiyroq usul
                  // valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E1D4)),
                  // backgroundColor: Color(0xFF23C96C),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "AI bargni tekshirmoqda...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
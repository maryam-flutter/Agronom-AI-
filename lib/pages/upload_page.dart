import 'dart:io';
import 'package:agronom_ai/pages/analysis_loading_page.dart';
import 'package:agronom_ai/pages/app_colors.dart';
import 'package:agronom_ai/pages/app_text_styles.dart';

import 'package:agronom_ai/registerProvider/ai_doctor_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';



class AiDoctorUploadPage extends StatefulWidget {
  final String selectedCategory;

  const AiDoctorUploadPage({Key? key, required this.selectedCategory}) : super(key: key);

  @override
  State<AiDoctorUploadPage> createState() => _AiDoctorUploadPageState();
}

class _AiDoctorUploadPageState extends State<AiDoctorUploadPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isStartingAnalysis = false; // Tugmani bloklash uchun holat

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Rasm tanlashda xatolik: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rasm tanlashda xatolik yuz berdi.")),
      );
    }
  }

  Future<void> _startAnalysis() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, avval rasm tanlang.")),
      );
      return;
    }

    // Tugmani nofaol qilish va takroriy bosishni oldini olish
    if (mounted) {
      setState(() {
        _isStartingAnalysis = true;
      });
    }

    // Tahlilni boshlash uchun AnalysisLoadingPage'ga o'tish
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisLoadingPage(
          imagePath: _imageFile!.path,
          selectedCategory: widget.selectedCategory,
        ),
      ),
    );

    // Tahlil sahifasidan qaytilganda tugmani yana faol qilish
    if (mounted) {
      setState(() {
        _isStartingAnalysis = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Sarlavha olib tashlandi
        backgroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // Yuqoridagi sarlavha matnlari
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${widget.selectedCategory} bargi rasmini yuklang",
              style: AppTextStyles.headline3.copyWith(fontSize: 18),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.eco_outlined, color: AppColors.primaryGreen),
          ],
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Eslatib o'tamiz, AI faqat barg rasmlarini tahlil qiladi.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ),
      SizedBox(height: 16,),
        // Rasm yuklash uchun markaziy qism
        GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.7), width: 1.5),
            ),
            child: _imageFile == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 50, color: AppColors.textGreyLight),
                        SizedBox(height: 12),
                        Text(
                          "Rasm yuklash uchun bosing",
                          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ClipRRect( // Rasm tanlanganda ko'rsatiladi
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
          ),
        ),
        const Spacer(),
        // Tahlilni boshlash tugmasi
        _buildStartButton(),
        const SizedBox(height: 40), // Tugma ostidan bo'sh joy
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Consumer<AiDoctorProvider>(
        builder: (context, provider, child) {
          final bool isLoading = _isStartingAnalysis || provider.isLoading;
          return ElevatedButton(
            onPressed: isLoading ? null : _startAnalysis,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: AppColors.greyLight, // nofaol holatdagi rang
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: !isLoading
                    ? const LinearGradient(
                        colors: [Color(0xFF00E1D4), Color(0xFF23C96C)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isLoading ? AppColors.greyLight : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : Text(
                        "Boshlash",
                        style: AppTextStyles.buttonText.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Noto'g'ri rasm yuklanganda chiqadigan dialog oynasi
  void _showInvalidImageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Noto'g'ri rasm",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message, // Serverdan kelgan xabar (masalan, "Barg aniqlanmadi...")
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),
                const Text(
                  "Qanday rasm yuklash kerak?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const ListTile(
                  leading: Icon(Icons.check_circle, color: AppColors.primaryGreen),
                  title: Text("Faqat bargning o'zini rasmga oling."),
                  dense: true,
                ),
                const ListTile(
                  leading: Icon(Icons.check_circle, color: AppColors.primaryGreen),
                  title: Text("Rasm aniq va yorug' bo'lishi kerak."),
                  dense: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Tushunarli", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.greyLight
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 4.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ));

    // Draw dashed path
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
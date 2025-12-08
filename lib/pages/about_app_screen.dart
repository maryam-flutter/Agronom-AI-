import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Ilova haqida', style: TextStyle(color: AppColors.textBlack)),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Agronomiya AI',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 16),
            const Text(
              'Agronomiya AI — qishloq xo‘jaligi sohasida fermer va dehqonlarga yordam beradigan sun’iy intellekt asosidagi mobil ilova. Unda ekin kasalliklarini aniqlash, davolash bo‘yicha tavsiyalar olish, agro mahsulotlarni onlayn xarid qilish, ob-havo ma’lumotlari va monitoring xizmatlari mavjud.',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: 16),
            const Text(
              'Shuningdek, foydalanuvchilar uchun kolleksiya bo‘limi, foydali maqolalar, video darsliklar va sevimlilarni saqlash imkoniyati ham qo‘shilgan. Ilova hosildorlikni oshirish, xarajatlarni kamaytirish va samarali boshqaruvni yo‘lga qo‘yishga yordam beradi.',
              style: AppTextStyles.bodyText,
            ),
          ],
        ),
      ),
    );
  }
}
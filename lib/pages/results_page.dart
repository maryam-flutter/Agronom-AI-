import 'dart:io';
import 'dart:ui';

import 'package:agronom_ai/registerProvider/ai_doctor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_assets.dart';
import 'app_colors.dart';
import 'favorites_provider.dart';
class ResultPage extends StatefulWidget {
  final String imagePath;
  final String category;
  // Backenddan keladigan natija
  final AiDoctorResult result;

  const ResultPage({
    Key? key,
    required this.imagePath,
    required this.category,
    required this.result,
  }) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // Barcha mahsulotlar ro'yxati (AgroMarketScreen'dan vaqtincha ko'chirildi)
  // Kelajakda buni alohida service yoki provider'ga chiqarish mumkin.
  final List<Map<String, String>> _allProducts = const [
    {
      'title': 'Meva uchun dori',
      'price': '220 000 so\'m',
      'image': AppAssets.productMedicine1,
      'description':
          'Bu dori mevali daraxtlaringizni zang va qo\'tir kasalliklaridan himoya qiladi va hosildorlikni oshiradi. Qo\'llash bo\'yicha yo\'riqnoma qutida mavjud.',
      'category': 'Dorilar',
      'disease': 'Olma zang kasalligi,Olma qo\'tir kasalligi (parsha)', // Qaysi kasalliklarga qarshi
    },
    {
      'title': 'O\'g\'itlar',
      'price': '180 000 so\'m',
      'image': AppAssets.productMedicine5,
      'description':
          'Organik o\'g\'itlar tuproq unumdorligini oshirish uchun mo\'ljallangan. Barcha turdagi ekinlar uchun mos keladi.',
      'category': 'O\'g\'itlar',
      'disease': '', // Bu dori emas
    },
    {
      'title': 'Zararkunandalarga qarshi',
      'price': '150 000 so\'m',
      'image': AppAssets.productMedicine3,
      'description':
          'Hasharotlar va zararkunandalarga qarshi samarali vosita. Bog\'ingiz va polizingizni himoya qiling.',
      'category': 'Dorilar',
      'disease': 'Qora chirish,Esca (Qora qizamiq)', // Qaysi kasalliklarga qarshi
    },
  ];

  /// Kasallik nomiga qarab mos mahsulotlarni topib beradigan funksiya
  List<Map<String, String>> _getRecommendedProducts(String diseaseName) {
    if (diseaseName.isEmpty) {
      return [];
    }

    final lowerCaseDiseaseName = diseaseName.toLowerCase();
    List<Map<String, String>> recommended = [];

    for (var product in _allProducts) {
      // Mahsulotda 'disease' kaliti borligini va bo'sh emasligini tekshiramiz
      if (product.containsKey('disease') && product['disease']!.isNotEmpty) {
        // 'disease' maydonidagi kasalliklarni vergul bilan ajratib, ro'yxatga olamiz
        List<String> diseasesForProduct =
            product['disease']!.split(',').map((e) => e.trim().toLowerCase()).toList();

        // Agar mahsulot kasalliklari ro'yxatida bizning kasalligimiz bo'lsa,
        // uni tavsiyalar ro'yxatiga qo'shamiz.
        if (diseasesForProduct.contains(lowerCaseDiseaseName)) {
          recommended.add(product);
        }
      }
    }

    return recommended;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rasm ko'rsatiladigan qism
          _buildImageHeader(),

          // Natija ma'lumotlari
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: widget.result.isHealthy
                  ? _buildHealthyResult()
                  : _buildDiseaseResult(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            image: DecorationImage(
              image: FileImage(File(widget.imagePath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, color: Color.fromARGB(255, 7, 7, 7), size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
            ),
          ),
        ),
        // Rasm ustidagi diagnostika kartochkasi
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(widget.imagePath),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.category == 'Olma' ? "Olma bargi" : 
                                widget.category == 'uzum' ? "Uzum bargi" :
                                "Tahlil natijasi",
                                style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.result.isHealthy ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(8), // O'zgartirildi
                                ),
                                child: Text(widget.result.isHealthy ? "Yaxshi" : "Yomon", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("Sana: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthyResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kasallik natijasiga o'xshash dizayn
        _buildInfoTile(
          icon: Icons.health_and_safety_outlined,
          iconColor: Colors.green,
          title: "Muvaffaqiyatli",
          subtitle: widget.result.diseaseName,
        ),
        const SizedBox(height: 16),
        _buildInfoTile(
          icon: Icons.description_outlined,
          iconColor: Colors.blueGrey,
          title: "Tavsif",
          subtitle: widget.result.description,
        ),
        const Spacer(), // Qolgan bo'sh joyni egallaydi
        _buildHomeButton(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDiseaseResult() {
    // Ma'lumotlar ko'p bo'lsa, scroll qilish imkonini beradi
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Agar sog'lom bo'lsa, "Kasallik aniqlandi" sarlavhasini ko'rsatmaymiz
        _buildInfoTile(
          icon: widget.result.isHealthy ? Icons.health_and_safety_outlined : Icons.bug_report_outlined,
          iconColor: widget.result.isHealthy ? AppColors.primaryGreen : AppColors.errorRed,
          title: widget.result.isHealthy ? "Muvaffaqiyatli" : "Kasallik aniqlandi",
          subtitle: widget.result.diseaseName,
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          icon: Icons.description_outlined,
          iconColor: Colors.blueGrey,
          title: "Tavsif",
          subtitle: widget.result.description,
        ),
        if (widget.result.treatment.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildInfoTile(
            icon: Icons.healing_outlined,
            iconColor: Colors.teal,
            title: "Davolash usullari",
            subtitle: widget.result.treatment,
          ),
        ],
        // Agar kasallik aniqlangan bo'lsa va sog'lom bo'lmasa, dori tavsiya qilamiz
        if (!widget.result.isHealthy && widget.result.diseaseName.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildRecommendedProducts(),
        ],

        const SizedBox(height: 24),
        _buildHomeButton(context),
        const SizedBox(height: 24), // Tugma ostidagi bo'sh joy kattalashtirildi
      ],
    );
  }

  // Ma'lumotlarni chiroyli ko'rsatish uchun yordamchi vidjet
  Widget _buildInfoTile({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 15, color: const Color.fromARGB(255, 28, 28, 28), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0), // Pastki padding olib tashlandi
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            // Bosh sahifaga qaytish (HomePageNav ga)
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              child: const Text("Bosh sahifaga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  // Tavsiya etilgan mahsulotlarni ko'rsatish uchun vidjet
  Widget _buildRecommendedProducts() {
    final recommendedProducts = _getRecommendedProducts(widget.result.diseaseName);

    if (recommendedProducts.isEmpty) {
      return const SizedBox.shrink(); // Agar mahsulot topilmasa, hech narsa ko'rsatmaymiz
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tavsiya etiladigan mahsulotlar",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 12),
          // Mahsulotlar ro'yxati
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = recommendedProducts[index];
              return _buildProductTile(product);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 10),
          ),
        ],
      ),
    );
  }

  // Bitta mahsulot uchun vidjet
  Widget _buildProductTile(Map<String, String> product) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final p = Product(
      id: product['title']! + product['price']!,
      title: product['title']!,
      price: product['price']!,
      imageUrl: product['image']!,
      description: product['description']!,
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product['image']!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title']!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']!,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              favoritesProvider.toggleFavorite(p);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Mahsulot savatga qo'shildi!"),
                  backgroundColor: AppColors.primaryGreen,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: const Icon(Icons.add_shopping_cart_outlined, color: AppColors.primaryGreen, size: 24),
          ),
        ],
      ),
    );
  }
}

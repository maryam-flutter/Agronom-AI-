import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_assets.dart';
import 'app_text_styles.dart';

import 'favorites_screen.dart';
import 'product_detail_screen.dart';
import 'favorites_provider.dart';
import 'product_search_screen.dart';

class AgroMarketScreen extends StatelessWidget {
  const AgroMarketScreen({Key? key}) : super(key: key);

  // Mock data for products
  final List<Map<String, String>> _products = const [
    {
      'title': 'Meva uchun dori',
      'price': '220 000 so\'m',
      'image': AppAssets.productMedicine1,
      'description':
          'Bu dori mevali daraxtlaringizni kasalliklardan himoya qiladi va hosildorlikni oshiradi. Qo\'llash bo\'yicha yo\'riqnoma qutida mavjud.',
      'category': 'Dorilar',
    },
    {
      'title': 'O\'g\'itlar',
      'price': '180 000 so\'m',
      'image': AppAssets.productMedicine5,
      'description':
          'Organik o\'g\'itlar tuproq unumdorligini oshirish uchun mo\'ljallangan. Barcha turdagi ekinlar uchun mos keladi.',
      'category': 'O\'g\'itlar',
    },
    {
      'title': 'Zararkunandalarga qarshi',
      'price': '150 000 so\'m',
      'image': AppAssets.productMedicine3,
      'description':
          'Hasharotlar va zararkunandalarga qarshi samarali vosita. Bog\'ingiz va polizingizni himoya qiling.',
      'category': 'Dorilar',
    },
    {
      'title': 'Urug\'lar',
      'price': '50 000 so\'m',
      'image': AppAssets.productMedicine4,
      'description':
          'Yuqori hosildorlikka ega bo\'lgan, sifatli sabzavot urug\'lari to\'plami. Ochiq va yopiq maydonlar uchun.',
      'category': 'Urug\'lar',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add some space above the header
              const SizedBox(height: 16),

              // Header with Search and Favorites
              _buildHeader(context),

              // Recommendations Title
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text("Tavsiya qilamiz", style: AppTextStyles.headline3),
              ),

              // Products Grid
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _ProductCard(
                      title: product['title']!,
                      price: product['price']!,
                      imageUrl: product['image']!,
                      description: product['description']!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductSearchScreen(allProducts: _products),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textGreyLight),
                    const SizedBox(width: 8),
                    Text("Mahsulotni qidirish", style: TextStyle(fontSize: 16, color: AppColors.textGreyLight)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Favorites button
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()));
            },
            icon: const Icon(Icons.favorite_border_outlined),
            iconSize: 28,
            color: AppColors.textBlack,
          ),
        ]
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final String description;

  const _ProductCard({Key? key, 
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final product = Product(
      id: title + price,
      title: title,
      price: price,
      imageUrl: imageUrl,
      description: description,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
                title: title, price: price, imageUrl: imageUrl, description: description),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shadowColor: AppColors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.asset(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color.fromARGB(221, 118, 116, 116)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 7, 7, 7)),
                      ),
                      InkWell(
                        onTap: () {
                          favoritesProvider.toggleFavorite(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mahsulot savatga qo'shildi!"),
                              backgroundColor: AppColors.primaryGreen,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(//icon cart
                          width: 32, height: 32,
                          decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                          child: const Icon(Icons.add_shopping_cart_outlined, color: AppColors.primaryGreen, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:agronom_ai/weatherpages/weather_screen.dart';
import 'package:agronom_ai/weatherpages/weather_search_screen.dart';

import 'package:agronom_ai/registerProvider/profile_provider.dart';
import 'package:agronom_ai/pages/favorites_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:agronom_ai/weatherpages/weather_provider.dart';

import 'dart:async';
import 'app_colors.dart';


import 'app_assets.dart';
import 'notifications_screen.dart';
import 'favorites_screen.dart';
import 'product_detail_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0; // Bu indikator uchun ishlatiladi
  late Timer _timer;
  final List<Map<String, String>> banners = [
    {
      'title': 'Sabzavotlar haqida',
      'subtitle': 'Sabzavotlarda qancha vitaminlar yashiringan?',
      'image': 'assets/slider.png', // Networkdan assetga o'zgartirildi
    },
    {
      'title': 'Mevalar foydasi',
      'subtitle': 'Kunlik mevalar iste\'moli haqida ma\'lumot',
      'image': 'assets/slider.png', // Networkdan assetga o'zgartirildi
    },
    {
      'title': 'Sog\'lom ovqatlanish',
      'subtitle': 'Vitaminlar va minerallar haqida',
      'image': 'assets/slider.png', // Networkdan assetga o'zgartirildi
    },
  ];

  // Mock data for products on the home screen
  final List<Map<String, String>> _homeProducts = const [
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
      'image': AppAssets.productMedicine2,
      'description':
          'Organik o\'g\'itlar tuproq unumdorligini oshirish uchun mo\'ljallangan. Barcha turdagi ekinlar uchun mos keladi.',
      'category': 'O\'g\'itlar',
    },
    // Add more products here if needed
  ];

  @override
  void initState() {
    super.initState();
    // Cheksiz aylanish uchun PageView'ni katta indeksdan boshlaymiz
    const int initialPage = 1000;
    _pageController = PageController(initialPage: initialPage);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Provider ma'lumotlarini yuklash
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Bu yerda context'dan foydalanish xavfsiz, chunki build metodi allaqachon chaqirilgan bo'ladi.
      // listen: false, chunki biz faqat funksiyani bir marta chaqirmoqchimiz.
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.fetchProfile(); // Profil ma'lumotlari yuklanishini kutamiz

      // Profil yuklangandan so'ng, uning manzilini olamiz
      final profile = profileProvider.userProfile;
      // Agar foydalanuvchining manzili bo'lsa, o'sha shahar uchun haroratni olamiz.
      // `mounted` tekshiruvi, agar sahifa yopilib ketsa, xatolik yuzaga kelmasligi uchun kerak.      
      if (mounted && profile?.address != null && profile!.address!.isNotEmpty) {
        Provider.of<WeatherProvider>(context, listen: false).fetchWeatherForCity(profile.address!, isHomeWeather: true);
      }
    });
    
    // Auto slide banner - forward only
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && mounted) {
        // Joriy sahifadan keyingisiga o'tish
        _pageController.animateToPage(
          _pageController.page!.toInt() + 1,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.userProfile;
    final weatherProvider = Provider.of<WeatherProvider>(context); // listen: true
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Row( // Header Row
                children: [
                  ClipOval(
                    child: (profile?.profile_pic != null && profile!.profile_pic!.isNotEmpty)
                        ? Image.network(
                            profile.profile_pic!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryGreen,
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              );
                            },
                          )
                        : const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryGreen,
                            child: Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                  ),

                  const SizedBox(width: 12),
                  Expanded( // Address Section
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (weatherProvider.homeWeather != null)
                            Row(
                              children: [
                                if (weatherProvider.homeWeather!.iconUrl.isNotEmpty)
                                  Image.network(
                                    weatherProvider.homeWeather!.iconUrl,
                                    width: 24, // O'lchamni kattalashtiramiz
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.wb_cloudy_outlined, color: AppColors.textGrey, size: 18),
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  '${weatherProvider.homeWeather?.currentTemp.toStringAsFixed(0)}°',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          if (weatherProvider.homeWeather != null)
                            const SizedBox(height: 2),
                          Row( // Location Row
                            children: [
                              const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  profile?.address ?? 'Manzil kiritilmagan',
                                  style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]
                          ),
                        ],
                    ),
                  ),
                  IconButton( // Notifications Button
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                    },
                    icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                  ),
                ],
              ),
            ),
            // Search Bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Qidiruv uchun maxsus sahifaga o'tish
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const WeatherSearchScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.greyLight),
                        ),
                        child: Row(children: [
                          Icon(Icons.search, color: AppColors.textGreyLight),
                          const SizedBox(width: 8),
                          Text("Qidirish", style: TextStyle(fontSize: 16, color: AppColors.textGreyLight)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Filter Button
                  InkWell(
                    onTap: () {
                      showDialog(context: context, builder: (context) => const CustomDialog(title: 'Tez orada', subtitle: 'Filtrlash imkoniyati tez orada qo\'shiladi.'));
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.greyLight),
                      ),
                      child: const Icon(Icons.filter_list, color: AppColors.textGreyLight),
                    ),
                  ),
                ],
              ),
            ),

            // Banner Slider Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Foydali tavsiyalar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200, // Slayder balandligi kattalashtirildi
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index % banners.length;
                  });
                },
                itemBuilder: (context, index) {
                  final bannerIndex = index % banners.length;
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return _buildBannerItem(
                        banners[bannerIndex]['title']!,
                        banners[bannerIndex]['subtitle']!,
                        banners[bannerIndex]['image']!,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Categories Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Kategoriyalar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            
              SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryItem(
                    context,
                    AppAssets.iconFruits, // Apple icon
                    'Fruits', 
                    Colors.red.shade100, 
                    Colors.red
                  ),
                  _buildCategoryItem(
                    context,
                    AppAssets.iconVegetables, // Broccoli icon
                    'Vegetables', 
                    Colors.green.shade100, 
                    Colors.green
                  ),
                  _buildCategoryItem(
                    context,
                    AppAssets.iconBeverages, // Juice icon
                    'Beverages', 
                    Colors.orange.shade100, 
                    Colors.orange
                  ),
                  _buildCategoryItem(
                    context,
                    AppAssets.iconGrocery, // Shopping basket icon
                    'Grocery', 
                    Colors.purple.shade100, 
                    Colors.purple
                  ),
                  _buildCategoryItem(
                    context,
                    AppAssets.iconEdibleOil, // Oil bottle icon
                    'Edible oil', 
                    Colors.cyan.shade100, 
                    Colors.cyan
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Products Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildProductItem(context, _homeProducts[0]),
                  const SizedBox(height: 12),
                  _buildProductItem(context, _homeProducts[1]),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerItem(String title, String subtitle, String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yuqori qism: Rasm
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset( // Image.network Image.asset ga o'zgartirildi
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      
                    ),
                  ),
                ],
              ),
            ),
            // Pastki qism: Oq fonda matn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String imageUrl, String title, Color bgColor, Color iconColor) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black54,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Yaqinda ishga tushadi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Biz bu imkoniyat ustida ishlayapmiz. Tez orada siz uchun ochib beramiz.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10), // Oradagi masofa kengaytirildi
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.network(
                  imageUrl, // Bu networkdan kelayotgan iconlar
                  width: 28,
                  height: 28,
                  color: iconColor,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails
                    return Icon(Icons.category, color: iconColor, size: 24);
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, Map<String, String> product) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final p = Product(
      id: product['title']! + product['price']!,
      title: product['title']!,
      price: product['price']!,
      imageUrl: product['image']!,
      description: product['description']!,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              title: product['title']!,
              price: product['price']!,
              imageUrl: product['image']!,
              description: product['description']!,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(product['image']!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
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
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppColors.lightGreen, shape: BoxShape.circle),
                child: const Icon(Icons.add_shopping_cart_outlined, color: AppColors.primaryGreen, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog widget uchun
class CustomDialog extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Bekor qilish'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('OK', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
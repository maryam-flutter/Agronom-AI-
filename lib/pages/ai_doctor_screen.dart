import 'package:agronom_ai/pages/app_assets.dart';
import 'package:agronom_ai/pages/app_strings.dart';
import 'package:agronom_ai/pages/app_text_styles.dart';
import 'package:agronom_ai/pages/category_card.dart';
import 'package:agronom_ai/pages/doctor_header.dart';
import 'package:agronom_ai/pages/upload_page.dart';
import 'package:agronom_ai/registerProvider/profile_provider.dart';
import 'package:agronom_ai/weatherpages/weather_provider.dart';
import 'package:flutter/material.dart';


class AiDoctorScreen extends StatefulWidget {
  const AiDoctorScreen({Key? key}) : super(key: key);

  @override
  _AiDoctorScreenState createState() => _AiDoctorScreenState();
}

class _AiDoctorScreenState extends State<AiDoctorScreen> {
  @override
  void initState() {
    super.initState();
    // build metodi tugagandan so'ng, context'dan foydalanish xavfsiz bo'ladi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = Provider.of<ProfileProvider>(context, listen: false).userProfile;
      if (profile?.address != null && profile!.address!.isNotEmpty) {
        // Foydalanuvchi manzili bo'yicha ob-havo ma'lumotini yuklash
        Provider.of<WeatherProvider>(context, listen: false).fetchWeatherForCity(profile.address!, isHomeWeather: true);
    }
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              DoctorHeader(
                profilePicUrl: profileProvider.userProfile?.profile_pic,
                address: profileProvider.userProfile?.address,
                weather: weatherProvider.homeWeather,
              ),
              const SizedBox(height: 24),

              // Title
              const Text(AppStrings.aiDoctor, style: AppTextStyles.headline1),
              const SizedBox(height: 8),
              const Text(
                AppStrings.selectCategoryAndDiagnose,
                style: AppTextStyles.bodyText,
              ),
              const SizedBox(height: 24),

              // Categories
              const Text(AppStrings.categories, style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2, // Kartalarning eni va bo'yi nisbatini o'zgartirish
                  children: [
                    CategoryCard(
                      title: 'Uzum',
                      imagePath: AppAssets.categoryGrape,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiDoctorUploadPage(selectedCategory: 'Uzum'),
                        ),
                      ),
                    ),
                    CategoryCard(
                      title: 'Olma',
                      imagePath: AppAssets.categoryFruit,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AiDoctorUploadPage(selectedCategory: 'Olma'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
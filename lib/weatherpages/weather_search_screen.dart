import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:agronom_ai/weatherpages/weather_model.dart';
import 'package:agronom_ai/weatherpages/weather_screen.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/app_colors.dart';
import 'weather_provider.dart';

class WeatherSearchScreen extends StatefulWidget {
  const WeatherSearchScreen({Key? key}) : super(key: key);

  @override
  State<WeatherSearchScreen> createState() => _WeatherSearchScreenState();
}

class _WeatherSearchScreenState extends State<WeatherSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Qidiruv natijalarini tozalash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).clearSearchResults();
    });
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      provider.searchCities(query);
      // Agar qidiruv maydoni bo'shatilsa, UI'ni yangilash uchun
      if (query.isEmpty && mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToWeather(String city) {
    // Qidiruv sahifasini yopib, ob-havo sahifasini ochamiz
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherScreen(city: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(fontSize: 16, color: AppColors.textBlack),
          decoration: InputDecoration(
            hintText: "Shaharni qidirish...",
            hintStyle: TextStyle(fontSize: 16, color: AppColors.textGreyLight),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: AppColors.grey.withOpacity(0.1),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          if (_searchController.text.isEmpty) {
            // Qidiruv maydoni bo'sh bo'lsa, foydalanuvchining joriy ob-havosini ko'rsatamiz.
            if (provider.homeWeather != null) {
              return _buildCurrentUserWeather(provider.homeWeather!);
            }
            // Agar u ham bo'lmasa, bo'sh joy ko'rsatamiz.
            return const SizedBox.shrink();
          }
          if (provider.searchResults.isEmpty) {
            return const Center(child: Text("Natija topilmadi"));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final city = provider.searchResults[index];
              return ListTile(
                leading: const Icon(Icons.search_rounded, color: AppColors.textGrey),
                title: Text(city),
                onTap: () => _navigateToWeather(city),
              );
            },
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.greyLight,
            ),
          );
        },
      ),
    );
  }

  // Foydalanuvchining joriy ob-havosini ko'rsatish uchun widget
  Widget _buildCurrentUserWeather(WeatherModel weather) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asosiy harorat ko'rsatkichi (WeatherScreen'dan olingan)
          _buildCurrentWeatherCard(weather),
          const SizedBox(height: 24),
          // Qo'shimcha ma'lumotlar (namlik, shamol, bosim)
          _buildWeatherDetails(weather),
        ],
      ),
    );
  }

  // Asosiy ob-havo kartochkasi (WeatherScreen'dan moslashtirilgan)
  Widget _buildCurrentWeatherCard(WeatherModel weather) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.city,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textBlack),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.localtime.split(' ').last, // Faqat vaqtni ko'rsatish
                    style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                ],
              ),
              if (weather.iconUrl.isNotEmpty)
                Image.network(
                  weather.iconUrl,
                  width: 64,
                  height: 64,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.cloud_off_outlined,
                    size: 64,
                    color: AppColors.textGrey,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${weather.currentTemp.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: AppColors.primaryGreen),
          ),
          Text(
            weather.description,
            style: const TextStyle(fontSize: 18, color: AppColors.textGrey, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  // Qo'shimcha ob-havo ma'lumotlari (WeatherScreen'dan olingan)
  Widget _buildWeatherDetails(WeatherModel weather) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: [
        _buildDetailItem(CupertinoIcons.thermometer, "${weather.feelsLike.toStringAsFixed(1)}°", "Seziladi"),
        _buildDetailItem(CupertinoIcons.wind, "${weather.windKph} km/s", weather.windDir),
        _buildDetailItem(CupertinoIcons.drop, "${weather.humidity}%", "Namlik"),
        _buildDetailItem(CupertinoIcons.gauge, "${weather.pressureMb.toStringAsFixed(0)} mbar", "Bosim"),
        _buildDetailItem(CupertinoIcons.sun_max, "${weather.uv}", "UV Index"),
        _buildDetailItem(CupertinoIcons.eye, "${weather.visKm} km", "Ko'rinish"),
      ],
    );
  }

  // Detallar uchun yordamchi widget (WeatherScreen'dan olingan)
  Widget _buildDetailItem(IconData icon, String value, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32 - 24) / 3; // (padding - spacing) / items_per_row
    return Container(
      width: itemWidth,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textBlack),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Eski, sodda vidjet. Endi ishlatilmaydi.
  Widget _buildInfoColumn_old(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
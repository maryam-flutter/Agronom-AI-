import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:agronom_ai/weatherpages/weather_model.dart';
import 'package:agronom_ai/weatherpages/weather_provider.dart';
import 'package:provider/provider.dart';

class DoctorHeader extends StatelessWidget {
  final String? profilePicUrl;
  final String? address;
  final WeatherModel? weather;
  // isLoading holatini qabul qilish uchun yangi parametr qo'shildi

  const DoctorHeader({
    Key? key,
    this.profilePicUrl,
    this.address,
    this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // WeatherProvider'dan yuklanish holatini olish
    final isWeatherLoading = Provider.of<WeatherProvider>(context).isLoading;

    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color.fromARGB(255, 53, 163, 84),
          backgroundImage: (profilePicUrl != null && profilePicUrl!.isNotEmpty)
              ? NetworkImage(profilePicUrl!)
              : null,
          child: (profilePicUrl == null || profilePicUrl!.isEmpty)
              ? const Icon(Icons.person, color: Color.fromARGB(255, 251, 251, 251), size: 30)
              : null,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ob-havo ma'lumoti yoki yuklanish indikatori
              if (isWeatherLoading && weather == null)
                const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                )
              else if (weather != null)
                Row(
                  children: [
                    if (weather!.iconUrl.isNotEmpty)
                      Image.network(
                        weather!.iconUrl,
                        width: 24, // O'lchamni kattalashtiramiz
                        height: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.wb_cloudy_outlined, color: AppColors.textGrey, size: 18),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      '${weather!.currentTemp}°',
                      style: TextStyle(
                        fontSize: 14, // O'lchamni biroz kattalashtiramiz
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack, // Rangni qoraga o'zgartiramiz
                      ),
                    ),
                  ],
                ),
              if (weather != null || (isWeatherLoading && weather == null)) const SizedBox(height: 2),
              // Manzil ma'lumoti
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address ?? 'Manzil kiritilmagan',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textBlack, // Rangni qoraga o'zgartiramiz
                        fontWeight: FontWeight.w500, // Qalinligini oshiramiz
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:agronom_ai/weatherpages/weather_provider.dart';
import 'package:agronom_ai/weatherpages/weather_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/app_colors.dart';

class WeatherScreen extends StatefulWidget {
  final String city;

  const WeatherScreen({Key? key, required this.city}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();

    // build metodi tugagandan so'ng ma'lumotlarni yuklashni boshlaymiz.
    // Bu context bilan bog'liq xatoliklarning oldini oladi.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      // Sahifa ochilganda har doim yangi ma'lumot yuklaymiz.
      // Bu qidiruvdan kelganda ham to'g'ri ishlashini ta'minlaydi.
      _fetchWeather(widget.city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        shadowColor: AppColors.grey.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textBlack, size: 20),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.city.isNotEmpty ? widget.city : "Ob-havo", style: const TextStyle(color: AppColors.textBlack, fontSize: 18)),
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          // 1. Yuklanish holati
          if (provider.isLoading || provider.searchedWeather == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Xatolik holati
          // Agar qidiruv natijalari ko'rsatilmayotgan bo'lsa va xatolik bo'lsa
          if (provider.errorMessage != null && provider.searchedWeather == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.errorRed, fontSize: 16),
                ),
              ),
            );
          }

          // 3. Ma'lumotlar muvaffaqiyatli yuklangan holat
          if (provider.searchedWeather != null) {
            final weather = provider.searchedWeather!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Asosiy harorat ko'rsatkichi
                  _buildCurrentWeather(weather),
                  const SizedBox(height: 30),
                  // Qo'shimcha ma'lumotlar (namlik, shamol, bosim)
                  _buildWeatherDetails(weather),
                  const SizedBox(height: 30),
                  // Haftalik prognoz
                  _buildWeeklyForecast(weather.weeklyForecast),
                ],
              ),
            );
          }

          // 4. Boshlang'ich yoki kutilmagan holat
          return const Center(child: Text("Ma'lumotlar yuklanmoqda..."));
        },
      ),
    );
  }

  @override
  void dispose() {
    // Provider'dagi ma'lumotlarni tozalash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<WeatherProvider>(context, listen: false).clearSearch();
      }
    });
    super.dispose();
  }

  void _fetchWeather(String city) {
    Provider.of<WeatherProvider>(context, listen: false)
        .fetchWeatherForCity(city);
  }

  // Joriy ob-havoni ko'rsatuvchi widget
  Widget _buildCurrentWeather(WeatherModel weather) {
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

  // Qo'shimcha ob-havo ma'lumotlarini ko'rsatuvchi widget
  Widget _buildWeatherDetails(WeatherModel weather) {
    // GridView o'rniga Wrap widget'idan foydalanamiz. Bu moslashuvchanlikni oshiradi.
    return Wrap(
      spacing: 12.0, // Gorizontal bo'shliq
      runSpacing: 12.0, // Vertikal bo'shliq
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

  // Detallar uchun yordamchi widget
  Widget _buildDetailItem(IconData icon, String value, String label) {
    // Har bir elementning minimal kengligini belgilaymiz.
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32 - 24) / 3; // (padding - spacing) / items_per_row
    return Container(
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
      width: itemWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Haftalik prognozni ko'rsatuvchi widget
  Widget _buildWeeklyForecast(List<WeeklyForecast> forecast) {
    if (forecast.isEmpty) {
      return const SizedBox.shrink(); // Agar haftalik prognoz bo'lmasa, hech narsa ko'rsatmaymiz
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            "Haftalik prognoz",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: forecast.length,
          itemBuilder: (context, index) {
            final day = forecast[index];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      day.day,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Bu yerga icon qo'yish mumkin
                  // Icon(Icons.wb_sunny_outlined, color: Colors.orange),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${day.temp.toStringAsFixed(0)}°',
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8),
        ),
      ],
    );
  }
}

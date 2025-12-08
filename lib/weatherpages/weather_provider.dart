

import 'package:agronom_ai/weatherpages/weather_model.dart';
import 'package:agronom_ai/weatherpages/weather_service.dart';
import 'package:flutter/material.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _homeWeather; // Foydalanuvchining o'z ob-havosi uchun
  WeatherModel? get homeWeather => _homeWeather;

  WeatherModel? _searchedWeather; // Qidirilgan yoki WeatherScreen'da ko'rsatilayotgan ob-havo
  WeatherModel? get searchedWeather => _searchedWeather;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> _searchResults = [];
  List<String> get searchResults => _searchResults;

  // --- VAQTINCHALIK YECHIM UCHUN SHAHARLAR RO'YXATI ---
  final List<String> _allCities = [
    'Toshkent', 'Samarqand', 'Buxoro', 'Xiva', 'Andijon', 'Farg\'ona', 'Namangan',
    'Jizzax', 'Termiz', 'Navoiy', 'Nukus', 'Qarshi', 'Guliston'
  ];

  // Ob-havo ma'lumotini olish uchun yagona metod
  Future<void> fetchWeatherForCity(String city, {bool isHomeWeather = false}) async {
    _isLoading = true;
    _errorMessage = null;
    if (isHomeWeather) {
      _homeWeather = null;
    } else {
      _searchedWeather = null;
    }
    notifyListeners();
    final responseData = await _weatherService.getFullWeather(city);

    // Server javobi to'g'ridan-to'g'ri ob-havo ma'lumotlarini o'z ichiga oladi.
    if (responseData != null) {
      // Ma'lumotlarni to'g'ri "kalit"lardan ajratib olamiz
      final location = responseData['location'] as Map<String, dynamic>?;
      final current = responseData['current'] as Map<String, dynamic>?;

      final newWeather = WeatherModel(
        city: location?['name'] ?? city,
        region: location?['region'] ?? '',
        localtime: location?['localtime'] ?? '',
        currentTemp: (current?['temp_c'] as num?)?.toDouble() ?? 0.0,
        tempF: (current?['temp_f'] as num?)?.toDouble() ?? 0.0,
        feelsLike: (current?['feelslike_c'] as num?)?.toDouble() ?? 0.0,
        description: current?['condition']?['text'] ?? "Noma'lum",
        iconUrl: "https:${current?['condition']?['icon'] ?? ''}",
        // Qo'shimcha ma'lumotlarni qo'shamiz
        isDay: (current?['is_day'] as num?)?.toInt() ?? 1,
        humidity: (current?['humidity'] as num?)?.toInt() ?? 0,
        windKph: (current?['wind_kph'] as num?)?.toDouble() ?? 0.0,
        windMph: (current?['wind_mph'] as num?)?.toDouble() ?? 0.0,
        windDir: current?['wind_dir'] ?? '',
        pressureMb: (current?['pressure_mb'] as num?)?.toDouble() ?? 0.0,
        uv: (current?['uv'] as num?)?.toDouble() ?? 0.0,
        visKm: (current?['vis_km'] as num?)?.toDouble() ?? 0.0,
        weeklyForecast: [], // Hozircha haftalik prognoz yo'q
      );

      if (isHomeWeather) {
        _homeWeather = newWeather;
      } else {
        _searchedWeather = newWeather;
      }
    } else {
      _errorMessage = "Bu shahar uchun ma'lumot topilmadi.";
      if (isHomeWeather) _homeWeather = null;
      if (!isHomeWeather) _searchedWeather = null;
    }

    _isLoading = false;
    // UI darhol yangilanishi uchun kichik kechikish bilan notifyListeners chaqiramiz.
    Future.delayed(Duration.zero, () {
      if (hasListeners) notifyListeners();
    });
  }

  // Shaharlarni qidirish
  Future<void> searchCities(String query) async {
    if (query.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    // Serverda `/search_cities` yo'qligi sababli, biz kiritilgan shahar nomini
    // to'g'ridan-to'g'ri `/get_weather/` orqali tekshiramiz.
    // Bu haqiqiy qidiruv emas, balki shahar mavjudligini tekshirishdir.
    final responseData = await _weatherService.getFullWeather(query);

    if (responseData != null) {
      // Agar serverdan ma'lumot kelsa, demak shunday shahar mavjud.
      // Server qaytargan aniq nomni natijaga qo'shamiz.
      final location = responseData['location'] as Map<String, dynamic>?;
      final cityName = location?['name'] ?? query;
      _searchResults = [cityName];
    } else {
      // Agar ma'lumot kelmasa, natija topilmadi.
      _searchResults.clear();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchedWeather = null;
    _errorMessage = null;
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
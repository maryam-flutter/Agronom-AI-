import 'dart:convert';
import 'package:agronom_ai/service/storage_service.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // Ob-havo uchun asosiy manzil (base URL)
  static const String _baseUrl = "https://agroai.duckdns.org/weather";
  final StorageService _storageService = StorageService();

  // To'liq ob-havo ma'lumotini olish (GET so'rovi bilan)
  Future<Map<String, dynamic>?> getFullWeather(String city) async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      print("WeatherService Error: Auth token not found.");
      return null;
    }

    // Manzil server kutayotgan formatga keltirildi: get_weather/<city>/
    // 'get-weather' -> 'get_weather' ga o'zgartirildi va shahar nomi to'g'ridan-to'g'ri manzilga qo'shildi.
    final url = Uri.parse("$_baseUrl/get_weather/$city/");

    print("--- Sending Full Weather Request ---");
    print("URL: $url");
    print("Method: GET");
    print("Headers: {Authorization: Bearer ...}");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("--- Full Weather Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        return null;
      }
    } catch (e) {
      print("Get Full Weather Error: $e");
      return null;
    }
  }

  // Shaharlarni qidirish (endi haqiqiy API'ga ulanadi)
  Future<List<String>> searchCities(String query) async {
    // --- VAQTINCHALIK YECHIM ---
    // Backendda `search_cities` endpointi tayyor bo'lmagani uchun
    // bu funksiya vaqtinchalik o'chirib turiladi va bo'sh ro'yxat qaytaradi.
    // Bu `WeatherProvider`dagi lokal qidiruv ishlashiga imkon beradi.
    return [];
    /*
    if (query.trim().isEmpty) {
      return [];
    }

    final token = await _storageService.getAuthToken();
    if (token == null) {
      print("WeatherService Error: Auth token not found for searchCities.");
      return [];
    }

    // Manzilni `search_cities` ga o'zgartiramiz va qidiruv so'rovini
    // `city` parametri orqali yuboramiz.
    final url = Uri.parse("$_baseUrl/search_cities/").replace(
      queryParameters: {'city': query},
    );
    
    print("--- Sending City Search Request ---");
    print("URL: $url");
    print("Method: GET");
    print("Headers: {Authorization: Bearer ...}");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      print("--- City Search Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => item.toString()).toList();
      }
    } catch (e) {
      print("Search Cities Error: $e");
    }

    return [];
    */
  }

  // Faqat haroratni olish uchun GET so'rovi
  Future<double?> getTemperature(String city) async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      print("WeatherService Error: Auth token not found for getTemperature.");
      return null;
    }

    // URL manziliga shahar nomini qo'shamiz
    final url = Uri.parse("$_baseUrl/get_weather_temp/$city/");

    print("--- Sending Temperature-Only Request ---");
    print("URL: $url");
    print("Method: GET");
    print("Headers: {Authorization: Bearer ...}");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("--- Temperature-Only Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Backend 'temp_c' deb yubormoqda. Shuni hisobga olamiz.
        return (data['temp_c'] as num?)?.toDouble();
      }
      return null;
    } catch (e) {
      print("Get Temperature Error: $e");
      return null;
    }
  }

    // Faqat haroratni olish uchun GET so'rovi
  Future<Map<String, dynamic>?> getMyWeather(String city) async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      print("WeatherService Error: Auth token not found for getTemperature.");
      return null;
    }

    // URL manziliga shahar nomini qo'shamiz
    final url = Uri.parse("$_baseUrl/get_my_weather/$city/");

    print("--- Sending Temperature-Only Request ---");
    print("URL: $url");
    print("Method: GET");
    print("Headers: {Authorization: Bearer ...}");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      print("--- getMyWeather Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      print("Get Temperature Error: $e");
      return null;
    }
  }


}
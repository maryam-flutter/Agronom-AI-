import 'dart:convert';
import 'package:agronom_ai/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  String? sessionId;

  Future<void> login(String email) async {
    isLoading = true;
    isSuccess = false;
    sessionId = null;
    errorMessage = null;
    notifyListeners();

    final http.Response? response = await _authService.login(email: email);

    if (response != null && response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      sessionId = responseBody['session_id'];

      // --- DEBUG UCHUN ---
      // Konsolda serverdan kelgan session_id ni tekshirish
      print("--- Login Successful ---");
      print("Received Session ID: $sessionId");
      // --- DEBUG TUGADI ---
      
      isSuccess = true;
    } else {
      // Serverdan kelgan xato xabarini aniqroq va tushunarli qilish
      if (response != null && response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          String serverError = errorBody['error'] ?? errorBody['detail'] ?? errorBody['email']?[0] ?? "Tizimga kirishda noma'lum xatolik.";
          
          // Serverdan keladigan nomaqbul xabarni o'zgartiramiz
          if (serverError.toLowerCase().contains("foydalanuvchi topilmadi") || serverError.toLowerCase().contains("you must register first")) {
            errorMessage = "Bunday foydalanuvchi topilmadi. Iltimos, avval ro'yxatdan o'ting.";
          } else {
           errorMessage = "Tizimga kirishda xatolik yuz berdi: $serverError"; // Server xatosini ham ko'rsatamiz
         }
        } catch (e) {
          errorMessage = "Server bilan bog'lanishda xatolik yuz berdi.";
        }
      } else {
        errorMessage = "Tizimga kirishda xatolik: Noma'lum server javobi.";
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // Logout paytida holatni tozalash uchun
  void clearState() {
    isLoading = false;
    errorMessage = null;
    isSuccess = false;
    sessionId = null;
  }
}
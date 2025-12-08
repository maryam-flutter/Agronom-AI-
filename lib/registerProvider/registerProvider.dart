import 'package:agronom_ai/registemodel/model.dart';
import 'dart:convert';
import 'package:agronom_ai/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterProvider with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  bool _isSuccess = false;
  String? sessionId;

  bool get isSuccess => _isSuccess;

  final AuthService _authService = AuthService();

  Future<void> register(RegisterModel model) async {
    isLoading = true;
    _isSuccess = false;
    sessionId = null;
    errorMessage = null;
    notifyListeners();

    // Konsolda operatsiya boshlanganini ko'rsatish
    print("--- Registering User --- \nEmail: ${model.email}, Phone: ${model.phone}");

    final http.Response? response = await _authService.register(
      phone: model.phone,
      email: model.email,
      address: model.address,
    );

    if (response != null && response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      sessionId = responseBody['session_id'];
      _isSuccess = true;
      // Konsolda muvaffaqiyatli natijani ko'rsatish
      print("--- Registration Successful --- \nReceived Session ID: $sessionId");
    } else {
      if (response != null && response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          String serverError = errorBody['error'] ?? errorBody['detail'] ?? "Noma'lum server xatoligi.";

          // Serverdan kelishi mumkin bo'lgan boshqa xatoliklarni ham chiroyli qilish
          if (serverError.toLowerCase().contains("user with this email already exists")) {
            errorMessage = "Bu email manzil allaqachon ro'yxatdan o'tgan.";
          } else if (serverError.toLowerCase().contains("telefon raqam noto'g'ri")) {
            errorMessage = "Telefon raqami noto'g'ri formatda kiritilgan. Iltimos, to'g'ri formatda kiriting (masalan, 901234567).";
          } else {
            errorMessage = serverError; // O'zgartirildi
          }
        } catch (e) {
          errorMessage = "Serverdan noto'g'ri javob keldi.";
        }
      } else {
        errorMessage = "Ro'yxatdan o'tishda noma'lum xatolik.";
      }
      // Konsolda xatolikni aniq formatda ko'rsatish
      print("--- Registration Failed --- \nStatus Code: ${response?.statusCode}\nError Body: $errorMessage");
    }

    isLoading = false;
    notifyListeners();
  }

  // Logout paytida holatni tozalash uchun
  void clearState() {
    isLoading = false;
    errorMessage = null;
    _isSuccess = false;
    sessionId = null;
  }
}

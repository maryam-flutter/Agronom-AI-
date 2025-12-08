import 'dart:convert';
import 'package:agronom_ai/service/auth_service.dart';
import 'package:agronom_ai/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerifyProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool isLoading = false;
  String? errorMessage;
  bool isSuccess = false;
  // Bu yerda 'token' yoki 'user' ma'lumotlarini saqlashingiz mumkin

  // Xato xabarini tozalash uchun metod
  void clearError() {
    if (errorMessage != null) {
      errorMessage = null;
      notifyListeners();
    }
  }

  // Logout paytida holatni tozalash uchun
  void clearState() {
    isLoading = false;
    errorMessage = null;
    isSuccess = false;
    // Bu yerda boshqa saqlangan ma'lumotlar bo'lsa, ularni ham null qilish kerak
    // notifyListeners() shart emas, chunki ProfileProvider buni bajaradi.
  }

  Future<void> verifyCode({
    required String sessionId,
    String? email, // email parametri ixtiyoriy, faqat login paytida ishlatiladi
    required String code,
  }) async {
    isLoading = true;
    isSuccess = false;
    errorMessage = null;
    notifyListeners();

    // Debug uchun: serverga yuborilayotgan ma'lumotlarni tekshirish
    print("--- Verifying Code (Provider) --- \nSession ID: $sessionId \nEmail: ${email ?? 'N/A'} \nCode: $code");
    
    final http.Response? response = await _authService.verifyCode(sessionId: sessionId, email: email, code: code);

    if (response != null && response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // Backend 'access' va 'refresh' deb yuboradi, '..._token' emas.
      final accessToken = responseBody['access'] ?? responseBody['access_token'];
      final refreshToken = responseBody['refresh'] ?? responseBody['refresh_token'];

      if (accessToken != null && refreshToken != null) {
        // Postman uchun Access Token'ni konsolga chiqarish
        print("--- ACCESS TOKEN (Bearer Token) ---");
        print(accessToken);
        print("------------------------------------");

        await _storageService.saveAuthToken(accessToken);
        await _storageService.saveRefreshToken(refreshToken);

        // Kod muvaffaqiyatli tasdiqlangandan so'ng, ro'yxatdan o'tish yakunlanganini saqlaymiz.
        // Bu holat ilova qayta ochilganda to'g'ri Login sahifasiga yo'naltirish uchun kerak.
        await _storageService.saveRegistrationCompletion();
        isSuccess = true;
        print("--- Verification Successful --- \nTokens saved.");
      } else {
        errorMessage = "Autentifikatsiya tokeni olinmadi.";
      }
    } else {
      // Serverdan kelgan xato xabarini aniqroq ko'rsatish
      if (response != null && response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8 bilan decode qilish
          // Server 'error' yoki 'detail' maydonida xato yuborishi mumkin
          String serverError = errorBody['error'] ?? errorBody['detail'] ?? "Kod tasdiqlashda noma'lum xatolik.";

          if (serverError.toLowerCase().contains("email or code incorrect")) {
            errorMessage = "Kiritilgan kod noto'g'ri. Iltimos, tekshirib qayta urinib ko'ring.";
          } else {
            errorMessage = serverError; // O'zgartirildi
          }
        } catch (e) {
          errorMessage = "Serverdan noto'g'ri javob keldi.";
        }
      } else {
        errorMessage = "Kod tasdiqlashda xatolik: Noma'lum xato.";
      }
      print("--- Verification Failed --- \nStatus Code: ${response?.statusCode}\nError Body: $errorMessage");
    }
    isSuccess = (errorMessage == null && isSuccess);

    isLoading = false;
    notifyListeners();
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Barcha servislar uchun yagona asosiy manzil (base URL)
  static const String _baseUrl = "https://agroai.duckdns.org/accounts";

  // Ro'yxatdan o'tish yoki kodni qayta yuborish
  Future<http.Response?> register({
    required String phone,
    required String email,
    required String address,
  }) async {
    final body = {'phone': phone, 'email': email, 'address': address};
    print("--- Sending Register Request ---");
    print("URL: $_baseUrl/register/");
    print("Body: ${jsonEncode(body)}");

    final url = Uri.parse("$_baseUrl/register/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

  // Tizimga kirish (yangi funksiya)
  Future<http.Response?> login({required String email}) async {
    final body = {'email': email};
    print("--- Sending Login Request ---");
    print("URL: $_baseUrl/login/");
    print("Body: ${jsonEncode(body)}");

    final url = Uri.parse("$_baseUrl/login/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Kodni tasdiqlash
  Future<http.Response?> verifyCode({
    required String sessionId,
    String? email, // email parametri ixtiyoriy
    required String code,
  }) async {
    final Map<String, String> body = {'session_id': sessionId, 'code': code};
    if (email != null) {
      body['email'] = email;
    }
    print("--- Sending Verify Request ---");
    print("URL: $_baseUrl/verify/");
    print("Body: ${jsonEncode(body)}");

    final url = Uri.parse("$_baseUrl/verify/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      // --- DEBUG UCHUN QO'SHILDI ---
      // Serverdan kelgan javobni to'liq konsolga chiqarish
      print("--- Verify API Response ---");
      print("Status Code: ${response.statusCode}"); // Status kodini chop etish
      print("Response Body: ${response.body}"); // Server javobini chop etish
      // --- DEBUG TUGADI ---
      return response; // Javobni qaytarish
    } catch (e) {
      print("Verify Code Error: $e");
      return null;
    }
  }

  // Tokenni yangilash uchun
  Future<http.Response?> refreshToken(String refreshToken) async {
    // Backend odatda `/token/refresh/` manzilini kutadi
    final url = Uri.parse("$_baseUrl/token/refresh/");
    final body = {'refresh': refreshToken};

    print("--- Sending Refresh Token Request ---");
    print("URL: $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      print("Refresh Token Error: $e");
      return null;
    }
  }

  // Foydalanuvchi profilini olish
  Future<http.Response?> getMyProfile(String token) async {
    print("--- Sending Get Profile Request ---");
    print("URL: $_baseUrl/get_my_profile/");

    final url = Uri.parse("$_baseUrl/get_my_profile/");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      print("--- Get Profile Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");
      return response;
    } catch (e) {
      print("Get Profile Error: $e");
      return null;
    }
  }

  // Foydalanuvchi profilini yangilash
  Future<http.Response?> updateUserProfile({
    required String token,
    String? username,
    String? phone,
    String? email,
    String? address,
  }) async {    
    final Map<String, String> fields = {};
    if (username != null) fields['username'] = username;
    if (phone != null) fields['phone'] = phone;
    if (email != null) fields['email'] = email;
    if (address != null) fields['address'] = address;

    if (fields.isEmpty) {
      return null; // Hech qanday ma'lumot o'zgartirilmagan bo'lsa, so'rov yubormaymiz
    }
    print("--- Sending Update Profile Request ---");
    print("URL: $_baseUrl/update_user_profile/");
    print("Fields: $fields");

    final url = Uri.parse("$_baseUrl/update_user_profile/");
    try {
      final request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = "Bearer $token";
      request.fields.addAll(fields);
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("--- Update Profile Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");
      return response;
    } catch (e) {
      print("Update Profile Error: $e");
      return null;
    }
  }

  // Profil rasmini yangilash
  Future<http.Response?> updateProfilePicture({
    required String token,
    required String imagePath,
    Map<String, String>? otherData,
  }) async {
    print("--- Sending Update Picture Request ---");
    print("URL: $_baseUrl/update_user_profile/"); // URL to'g'rilandi
    print("Image Path: $imagePath");

    final url = Uri.parse("$_baseUrl/update_user_profile/"); // URL to'g'rilandi
    try {
      final request = http.MultipartRequest('PATCH', url); // Metodni POST dan PATCH ga qaytardik
      request.headers['Authorization'] = "Bearer $token";
      // Content-Type sarlavhasini olib tashlaymiz, http paketi o'zi avtomatik qo'yadi

      // Matnli ma'lumotlarni so'rovga qo'shish
      if (otherData != null) {
        request.fields.addAll(otherData);
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_pic', // Backend kutayotgan fayl maydonining nomi
          imagePath,
        ),
      );
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("--- Update Picture Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");
      return response;
    } catch (e) {
      print("Update Profile Picture Error: $e");
      return null;
    }
  }
}
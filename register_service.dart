import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  static Future<bool> register({
    required String phone,
    required String email,
    required String address,
  }) async {
    final url = Uri.parse('http://16.16.199.60:8000/accounts/register/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'email': email,
        'address': address,
      }),
    );

    // --- DEBUG UCHUN ---
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    // --- DEBUG UCHUN TUGADI ---

    return response.statusCode == 200; // Backend 200 OK qaytargani uchun o'zgartirildi
  }
}
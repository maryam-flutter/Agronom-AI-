import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsService {
  static const String _baseUrl = 'http://16.16.199.60:8000/accounts';

  // Kodni tekshirish uchun
  static Future<bool> verifyCode({
    required String phone,
    required String code,
  }) async {
    final url = Uri.parse('$_baseUrl/verify/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );
      print('Verify Response Status: ${response.statusCode}');
      print('Verify Response Body: ${response.body}');
      // Backend muvaffaqiyatli javob uchun 200 OK qaytaradi deb taxmin qilamiz
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }
}
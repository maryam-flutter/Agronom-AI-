import 'package:http/http.dart' as http;

class AiDoctorService {
  static const String _baseUrl = "https://agroai.duckdns.org/ai_modul";

  Future<http.Response?> predictDisease({
    required String imagePath,
    required String category,
    required String token,
  }) async {
    // Kategoriya asosida to'g'ri endpointni tanlash
    String endpoint;
    if (category.toLowerCase() == 'uzum') {
      endpoint = 'predict_grape'; // Uzum uchun
    } else if (category.toLowerCase() == 'olma') {
      endpoint = 'predict_apple';
    } else {
      endpoint = 'predict_apple'; // Standart holat, agar noma'lum kategoriya kelsa (masalan, olma)
    }
    final url = Uri.parse("$_baseUrl/$endpoint/");

    print("--- Sending AI Prediction Request ---");
    print("URL: $url");
    print("Image Path: $imagePath");
    print("Category: $category");

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = "Bearer $token";
      
      // 'image' - bu backend kutayotgan fayl maydonining nomi
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          imagePath,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("--- AI Prediction Response ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response;
    } catch (e) {
      print("AI Prediction Error: $e");
      return null;
    }
  }
}
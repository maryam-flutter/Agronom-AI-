import 'dart:convert';

import 'package:agronom_ai/pages/ai_doctor_service.dart';
import 'package:agronom_ai/service/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiDoctorResult {
  final bool isLeaf;
  final bool isHealthy;
  final String diseaseName;
  final String description;
  final String treatment;
  final double? confidence; // Ishonch darajasini saqlash uchun

  AiDoctorResult({
    required this.isLeaf,
    required this.isHealthy,
    required this.diseaseName,
    required this.description,
    required this.treatment,
    this.confidence,
  });
}

/// `compute` funksiyasi uchun ma'lumotlarni o'tkazish uchun yordamchi klass
class _ParseData {
  final String responseBody;
  final String category;

  _ParseData(this.responseBody, this.category);
}

/// JSON parse qilishni fon oqimida bajaradigan top-level funksiya
AiDoctorResult _parseAiDoctorResult(_ParseData data) {
  final json = jsonDecode(data.responseBody);
  final category = data.category;

  // Backenddan keladigan javob `prediction` kaliti ichida joylashgan.
  final predictionData = json['prediction'] as Map<String, dynamic>?;
  final confidenceValue = (predictionData?['confidence'] as num?)?.toDouble();

  if (predictionData == null) {
    // Agar `prediction` kaliti bo'lmasa, xatolik holati
    return AiDoctorResult(
      isLeaf: false,
      isHealthy: false,
      diseaseName: "Noma'lum javob",
      description: "Serverdan kutilmagan javob formati keldi.",
      treatment: "",
      confidence: null,
    );
  }

  bool isLeaf = predictionData['is_leaf'] ?? false;
  bool healthy = false;
  String diseaseName = "Noma'lum";
  String description = "Tahlil qilishda xatolik.";

  // Serverdan kelishi mumkin bo'lgan ziddiyatli javobni to'g'rilash: is_leaf: false, lekin class_name mavjud bo'lsa.
  final rawClassNameForCheck = predictionData['class_name'] as String? ?? '';
  final isHealthyForCheck = predictionData['is_healthy'] as bool?;

  // Agar `is_leaf` false bo'lsa ham, `class_name` mavjud bo'lsa yoki `is_healthy` true bo'lsa, buni barg deb qabul qilamiz.
  if (!isLeaf && (rawClassNameForCheck.isNotEmpty || (isHealthyForCheck != null && isHealthyForCheck == true))) {
    isLeaf = true; // Mantiqan to'g'rilaymiz, chunki sog'lom barg aniqlangan.
  }

  if (!isLeaf) {
    // Agar rasmda barg aniqlanmasa, serverdan kelgan qo'shimcha xabarni tekshiramiz.
    // Ba'zan server "ishonch past" degan xabar yuboradi.
    final serverMessage = predictionData['message'] as String? ?? '';
    String finalDiseaseName = "Barg aniqlanmadi";
    String finalDescription = "Iltimos, o'simlik bargini aniq va yorug' joyda rasmga olib, qayta urinib ko'ring.";

    if (serverMessage.toLowerCase().contains('ishonch darajasi juda past')) {
      finalDiseaseName = "Natija aniq emas";
      finalDescription = "AI model bu rasm bo'yicha aniq xulosaga kela olmadi. Iltimos, sifatliroq rasm bilan qayta urinib ko'ring.";
    }

    return AiDoctorResult(
      isLeaf: false,
      isHealthy: false,
      diseaseName: finalDiseaseName,
      description: finalDescription,
      treatment: "",
      confidence: confidenceValue,
    );
  } else {
    // Agar barg aniqlansa, kasallikni tekshiramiz
    final rawClassName = predictionData['class_name'] as String? ?? '';
    // `is_healthy` maydoniga ustunlik beramiz. Agar u yo'q bo'lsa, `class_name`ni tekshiramiz.
    healthy = predictionData['is_healthy'] ?? (rawClassName.toLowerCase().contains('healthy') || rawClassName.toLowerCase().contains('healty'));
    diseaseName = _getDisplayDiseaseName(rawClassName, category); // Maxsus metod orqali chiroyli nom olamiz

    // Agar barg sog'lom bo'lsa, serverdan kelgan 'message'ni e'tiborsiz qoldirib, standart sog'lom xabarini ko'rsatamiz.
    if (healthy) {
      description = "Bargingiz sog'lom ko'rinadi. Yaxshi parvarishda davom eting.";
    } else {
      // Agar kasal bo'lsa, 'description' yoki 'message' maydonidan foydalanamiz.
      description = predictionData['description'] ?? predictionData['message'] ?? "Kasallik haqida qo'shimcha ma'lumot topilmadi.";
    }
  }

  return AiDoctorResult(
    isLeaf: isLeaf,
    isHealthy: healthy,
    diseaseName: diseaseName,
    description: description,
    treatment: predictionData['treatment'] ?? "",
    confidence: confidenceValue,
  );
}

// Backenddan kelgan texnik nomni foydalanuvchiga tushunarli nomga o'giradi
String _getDisplayDiseaseName(String rawClassName, String category) {
  final classNameLower = rawClassName.toLowerCase();

  if (category.toLowerCase() == 'olma') {
    switch (classNameLower) {
      case 'apple_rust': return "Olma zang kasalligi";
      case 'apple_scab': return "Olma qo'tir kasalligi (parsha)";
      case 'black_rot': return "Qora chirish";
      case 'healthy':
      case 'healty': return "Barg sog'lom";
      default: return rawClassName;
    }
  } else if (category.toLowerCase() == 'uzum') {

    switch (classNameLower) {
      case 'black_rot': return "Qora chirish";
      case 'esca_(black_measles)': return "Esca (Qora qizamiq)";
      case 'healthy':
      case 'healty': return "Barg sog'lom";
      case 'leaf_blight_(isariopsis_leaf_spot)': return "Barg kuyishi (Isariopsis)";
      default: return rawClassName;
    }
  }

  // Agar kategoriya noma'lum bo'lsa
  if (classNameLower.contains('healthy') || classNameLower.contains('healty')) return "Barg sog'lom";
  return rawClassName.isNotEmpty ? rawClassName : "Noma'lum kasallik";
}

class AiDoctorProvider with ChangeNotifier {
  final AiDoctorService _aiDoctorService = AiDoctorService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AiDoctorResult? _result;
  AiDoctorResult? get result => _result;

  Future<bool> analyzeImage({
    required String imagePath,
    required String category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    final token = await _storageService.getAuthToken();
    if (token == null) {
      _errorMessage = "Avtorizatsiya qilinmagan. Iltimos, qayta kiring.";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final response = await _aiDoctorService.predictDisease(
      imagePath: imagePath,
      category: category,
      token: token,
    );

    // --- DEBUG UCHUN QO'SHILDI ---
    // Serverdan kelgan javobni to'liq konsolga chiqarish
    print("--- AI Doctor API Response ---");
    if (response != null) {
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${utf8.decode(response.bodyBytes)}");
    } else {
      print("Response is null. AiDoctorService'da xatolik yuz bergan bo'lishi mumkin.");
    }
    print("--- End of API Response ---");
    // --- DEBUG TUGADI ---

    if (response != null && response.statusCode == 200) {
      try {
        // JSON parse qilishni fon oqimiga o'tkazamiz
        _result = await compute(_parseAiDoctorResult, _ParseData(utf8.decode(response.bodyBytes), category));

        // Eski kod:
        // final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        // _result = AiDoctorResult.fromJson(responseBody, category: category);
        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = "Server javobini o'qishda xatolik: $e";
      }
    } else {
      _errorMessage = "Tahlil qilishda xatolik yuz berdi. Status kodi: ${response?.statusCode}";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Logout paytida holatni tozalash uchun metod
  void clearState() {
    _isLoading = false;
    _errorMessage = null;
    _result = null;
    // Bu metod ProfileProvider ichidan chaqirilgani uchun, o'sha yerda notifyListeners()
    // chaqiriladi, shuning uchun bu yerda qayta chaqirish shart emas.
  }
}
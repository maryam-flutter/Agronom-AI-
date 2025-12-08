import 'dart:convert';
import 'package:agronom_ai/service/auth_service.dart';
import 'package:agronom_ai/service/storage_service.dart';
import 'package:agronom_ai/registerProvider/ai_doctor_provider.dart';
import 'package:agronom_ai/registerProvider/login_provider.dart';
import 'package:agronom_ai/registerProvider/registerProvider.dart';
import 'package:agronom_ai/registerProvider/verify_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfileProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  Profile? _userProfile;
  Profile? get userProfile => _userProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ProfileProvider() {
  //   fetchProfile();
  // }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final token = await _storageService.getAuthToken();
    if (token == null) {
      _errorMessage = "Foydalanuvchi avtorizatsiyadan o'tmagan.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    http.Response? response = await _authService.getMyProfile(token);

    // Agar token eskirgan bo'lsa (401), uni yangilab, so'rovni qayta urinib ko'ramiz
    if (response != null && response.statusCode == 401) {
      print("Access token expired. Attempting to refresh...");
      final newAccessToken = await _refreshToken();
      if (newAccessToken != null) {
        // Yangi token bilan so'rovni qayta yuboramiz
        print("Retrying getMyProfile with new token.");
        response = await _authService.getMyProfile(newAccessToken);
      } else {
        // Tokenni yangilab bo'lmadi, foydalanuvchini tizimdan chiqaramiz
        _errorMessage = "Sessiya muddati tugadi. Iltimos, qayta kiring.";
        // await logout(); // Bu yerda context yo'q, shuning uchun to'g'ridan-to'g'ri chaqira olmaymiz.
      }
    }

    if (response != null && response.statusCode == 200) {
      try {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        _userProfile = Profile.fromJson(responseBody);
        _errorMessage = null; // Muvaffaqiyatli bo'lsa xatoni tozalash
      } catch (e) {
        _errorMessage = "Profil ma'lumotlarini o'qishda xatolik: $e";
      }
    } else if (_errorMessage == null) { // Agar yuqorida xato o'rnatilmagan bo'lsa
      if (response != null) {
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          _errorMessage = errorBody['error'] ?? errorBody['detail'] ?? "Profilni yuklashda noma'lum xatolik.";
        } catch (e) {
          _errorMessage = "Serverdan noto'g'ri javob keldi.";
        }
      } else {
        _errorMessage = "Profilni yuklashda xatolik yuz berdi.";
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Tokenni yangilaydigan yordamchi metod
  Future<String?> _refreshToken() async {
    final refreshToken = await _storageService.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await _authService.refreshToken(refreshToken);
    if (response != null && response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final newAccessToken = responseBody['access'];
      await _storageService.saveAuthToken(newAccessToken);
      return newAccessToken;
    }

    return null;
  }

  Future<bool> updateProfile({
    String? username,
    String? phone,
    String? email,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final token = await _storageService.getAuthToken();
    if (token == null) {
      _errorMessage = "Avtorizatsiya tokeni topilmadi.";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final response = await _authService.updateUserProfile(
      token: token,
      username: username,
      phone: phone,
      email: email,
      address: address,
    );

    if (response != null && response.statusCode == 200) {
      // Ortiqcha so'rov yubormaslik uchun javobdan ma'lumotlarni olib, UI'ni yangilaymiz
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      _userProfile = Profile.fromJson(responseBody);

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      // Serverdan kelgan aniq xato xabarini olish
      if (response != null && response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          _errorMessage = errorBody['error'] ?? errorBody['detail'] ?? "Profilni yangilashda noma'lum xatolik.";
        } catch (e) {
          _errorMessage = "Serverdan noto'g'ri javob keldi.";
        }
      } else {
        _errorMessage = "Profilni yangilashda xatolik yuz berdi.";
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final token = await _storageService.getAuthToken();
    if (token == null) {
      _errorMessage = "Avtorizatsiya tokeni topilmadi.";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Mavjud profil ma'lumotlarini so'rovga qo'shish uchun tayyorlaymiz
    final Map<String, String> fields = {};
    if (_userProfile != null) {
      if (_userProfile!.username != null) fields['username'] = _userProfile!.username!;
      if (_userProfile!.phone != null) fields['phone'] = _userProfile!.phone!;
      if (_userProfile!.email != null) fields['email'] = _userProfile!.email!;
      if (_userProfile!.address != null) fields['address'] = _userProfile!.address!;
    }

    final response = await _authService.updateProfilePicture(
      token: token,
      imagePath: imagePath,
      // Boshqa ma'lumotlarni ham birga yuboramiz
      // Bu serverda boshqa maydonlar null bo'lib qolishining oldini oladi
      otherData: fields,
    );

    if (response != null && response.statusCode == 200) {
      // Muvaffaqiyatli yangilangandan so'ng, profil ma'lumotlarini qayta yuklash o'rniga,
      // javobdan olingan yangi ma'lumotlar bilan providerni to'g'ridan-to'g'ri yangilaymiz.
      // Bu UI'ning darhol yangilanishini ta'minlaydi.
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      _userProfile = Profile.fromJson(responseBody);
      // await fetchProfile(); // Bu qatorni olib tashlaymiz

      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Profil rasmini yangilashda xatolik yuz berdi.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    // Provider'larni 'await'dan oldin o'zgaruvchiga olamiz.
    // Bu 'use_build_context_synchronously' ogohlantirishini bartaraf etadi.
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final verifyProvider = Provider.of<VerifyProvider>(context, listen: false);
    final registerProvider = Provider.of<RegisterProvider>(context, listen: false);
    final aiDoctorProvider = Provider.of<AiDoctorProvider>(context, listen: false);

    await _storageService.clearAll();
    _userProfile = null;
    _errorMessage = null;
    _isLoading = false;

    // Boshqa bog'liq provider'larning holatini ham tozalaymiz
    loginProvider.clearState();
    verifyProvider.clearState();
    registerProvider.clearState();
    aiDoctorProvider.clearState();

    notifyListeners();
  }
}

class Profile {
  final String? username;
  final String? email;
  final String? phone; // Nullable
  final String? address; // Nullable
  final String? profile_pic;

  Profile({
    this.username,
    this.email,
    this.phone, // Nullable
    this.address,
    this.profile_pic,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    String? picUrl = json['profile_pic'];
    // Agar rasm manzili to'liq URL bo'lmasa, unga server manzilini qo'shamiz
    if (picUrl != null && !picUrl.startsWith('http')) {
      // Serverning yangi asosiy manzili
      const String baseUrl = "https://agroai.duckdns.org"; 
      picUrl = baseUrl + picUrl;
    }

    return Profile(
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      profile_pic: picUrl,
    );
  }
}
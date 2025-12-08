import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _authTokenKey = 'authToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _onboardingKey = 'hasCompletedOnboarding';
  static const _registrationKey = 'hasRegistered';

  static StorageService? _instance;
  static late SharedPreferences _prefs;

  // Singleton pattern: faqat bitta nusxa yaratilishini ta'minlaydi
  factory StorageService() => _instance ??= StorageService._();

  StorageService._();

  // Ilova ishga tushganda bir marta chaqiriladi
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Tokenni saqlash
  Future<void> saveAuthToken(String token) async {
    await _prefs.setString(_authTokenKey, token);
  }

  // Tokenni o'qish
  Future<String?> getAuthToken() async {
    return _prefs.getString(_authTokenKey);
  }

  // Tokenni o'chirish (chiqishda kerak bo'ladi)
  Future<void> clearAll() async {
    await _prefs.remove(_authTokenKey);
    await _prefs.remove(_refreshTokenKey);
    // Logout qilganda ro'yxatdan o'tganlik holati o'chirilmaydi
  }

  // Refresh Tokenni saqlash
  Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(_refreshTokenKey, token);
  }

  // Refresh Tokenni o'qish
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  // Onboarding holatini saqlash va tekshirish
  Future<void> saveOnboardingCompletion() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<bool> hasCompletedOnboarding() async {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  // Ro'yxatdan o'tish holatini saqlash va tekshirish
  Future<void> saveRegistrationCompletion() async {
    await _prefs.setBool(_registrationKey, true);
  }

  Future<bool> hasCompletedRegistration() async {
    return _prefs.getBool(_registrationKey) ?? false;
  }
}
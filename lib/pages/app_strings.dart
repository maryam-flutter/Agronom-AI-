class AppStrings {
  // General
  static const String appNamePart1 = 'Agronom';
  static const String appNamePart2 = 'AI';
  static const String comingSoon = 'Tez orada ishga tushadi';
  static const String comingSoonDescription = 'Bu bo\'lim hozirda ishlab chiqilmoqda. Tez orada siz uchun tayyor bo\'ladi.';
  static const String save = 'Saqlash';
  static const String cancel = 'Bekor qilish';
  static const String error = 'Xatolik';

  // Onboarding & Auth
  static const String register = "Kirish";
  static const String login = "Tizimga kirish";
  static const String logout = 'Chiqish';
  static const String logoutConfirmation = 'Haqiqatan ham ilovadan chiqmoqchimisiz?';
  static const String enterCode = "Kodni kiriting";
  static const String enterPhone = 'Telefon raqamingizni kiriting';
  static const String enterEmail = 'E-mailingizni kiriting.';
  static const String region = 'Viloyat';
  static const String resendCode = "Kodni qayta yuborish";
  static const String codeResent = "Kod qayta yuborildi";
  static const String codeSentToPhone = "Telefon raqamingizga faollashtirish kodini yubordik.";
  static const String codeSentToEmail = "Emailingizga faollashtirish kodini SMS qilib yubordik.";
  static const String incorrectPassword = "Parol noto'g'ri";
  static const String registrationError = "Ro'yxatdan o'tishda xatolik!";
  static const String attemptsFinished = "Urinishlar soni tugadi. Iltimos, keyinroq qayta urinib ko'ring.";
  static String attemptsLeft(int count) => "Parol noto'g'ri. Qolgan urinishlar soni: $count";
  static String resendCodeIn(int seconds) => "Kodni qayta yuborish ($seconds)";

  // Home
  static const String usefulTips = 'Foydali tavsiyalar';
  static const String categories = 'Kategoriyalar';
  static const String search = 'Qidirish';

  // AI Doctor
  static const String aiDoctor = 'AI doktor';
  static const String selectCategoryAndDiagnose = "Kategoriyani tanlang va AI bilan kasalliklarni aniqlang";
  static const String start = "Boshlash";

  // Agro Market
  static const String searchProduct = "Mahsulotni qidirish";
  static const String recommendations = "Tavsiya qilamiz";

  // Profile
  static const String myDetails = 'Ma\'lumotlarim';
  static const String favorites = 'Savatim';
  static const String notifications = 'Bildirishnomalar';
  static const String aboutApp = 'Ilova haqida';
  static const String support = "Qo'llab-quvvatlash";
}
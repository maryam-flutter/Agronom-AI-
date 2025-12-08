import 'package:flutter/material.dart';
import 'package:agronom_ai/pages/login_page.dart';
import 'package:provider/provider.dart';


import '../registerProvider/registerProvider.dart';
import '../registemodel/model.dart';
import '../pages/app_assets.dart';
import '../pages/app_strings.dart';
import '../registerProvider/smspage.dart'; // yuqoriga import qiling

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedRegion = 'Toshkent';

  final List<String> _regions = [
    'Toshkent',
    'Andijon',
    'Farg\'ona',
    'Namangan',
    'Samarqand',
    'Buxoro',
    'Xorazm',
    'Qashqadaryo',
    'Surxondaryo',
    'Jizzax',
    'Sirdaryo',
    'Navoiy',
    'Qoraqalpog\'iston'
  ];

  bool get _isFormValid =>
      _phoneController.text.trim().replaceAll(' ', '').length == 9 &&
      _emailController.text.trim().contains('@') &&
      _selectedRegion != null && _selectedRegion!.isNotEmpty;

  void _register(BuildContext context) async {
    final provider = Provider.of<RegisterProvider>(context, listen: false);
    if (!_isFormValid || provider.isLoading) return;
    
    // Raqamdagi barcha bo'sh joylarni olib tashlaymiz
    final cleanedPhone = _phoneController.text.trim().replaceAll(' ', '');
    // To'liq 9 xonali raqamni (operator kodi bilan) serverga yuboramiz
    final model = RegisterModel(
      phone: cleanedPhone, 
      email: _emailController.text.trim(),
      address: _selectedRegion!,
    );

    await provider.register(model);

    // `mounted` tekshiruvi `context` ishlatishdan oldin muhim
    if (!mounted) return;

    if (provider.isSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SmsPage( // SmsPage'ga ham to'g'ri formatda yuboramiz
            phone: model.phone,
            email: model.email,
            address: model.address,
          ),
        ),
      );
    } else {
      // Xatolikni ko'rsatish
      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.redAccent, // O'zgartirildi
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // `Consumer` yordamida `RegisterProvider`'dagi o'zgarishlarni kuzatib boramiz
          child: Consumer<RegisterProvider>(builder: (context, provider, child) { return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Logo
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        AppAssets.logo,
                        width: 100,
                        height: 100,
                      ),
                     
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  AppStrings.register,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 32),
                // Phone input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.enterPhone,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _buildPhoneField(),
                const SizedBox(height: 20),
                // Email input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.enterEmail,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '@email.com',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                // Region dropdown
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppStrings.region,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  items: _regions
                      .map((region) => DropdownMenuItem(
                            value: region,
                            child: Text(
                              region,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black, size: 28),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                // Kirish button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: GestureDetector(
                    onTap: _isFormValid && !provider.isLoading ? () => _register(context) : null,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: _isFormValid
                            ? const LinearGradient(
                                colors: [Color(0xFF00E1D4), Color(0xFF23C96C)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : null,
                        color: _isFormValid ? null : Colors.grey[300],
                        boxShadow: _isFormValid
                            ? [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),
                            ) : const Text(AppStrings.register,
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Tizimga kirish uchun havola
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Hisobingiz bormi? ",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    GestureDetector(
                      onTap: () {
                        // RegisterPage o'rniga LoginPage'ni ochamiz
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Tizimga kirish",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ); }),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          // Country code part (static)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Image.asset(
                  AppAssets.uzbekistanFlag,
                  width: 24,
                  height: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  '+998',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Phone number input
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                hintText: '97 123 45 67',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }
}
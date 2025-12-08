


import 'package:agronom_ai/pages/uzbekistan_regions.dart';
import 'package:agronom_ai/registerProvider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'app_colors.dart';

class EditProfilePage extends StatefulWidget {
  final Profile profile;

  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  String? _selectedRegion;
  String? _selectedDistrict;
  List<String> _districtsForSelectedRegion = [];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username ?? '');
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _emailController = TextEditingController(text: widget.profile.email ?? '');
    _addressController = TextEditingController(text: widget.profile.address ?? '');

    _initializeLocation();
  }

  void _initializeLocation() {
    final currentAddress = widget.profile.address;
    if (currentAddress != null && currentAddress.isNotEmpty) {
      for (var entry in UzbekistanRegions.regionsAndDistricts.entries) {
        final region = entry.key;
        final districts = entry.value;
        if (districts.contains(currentAddress)) {
          _selectedRegion = region;
          _districtsForSelectedRegion = List<String>.from(districts)..sort();
          _selectedDistrict = currentAddress;
          _addressController.text = currentAddress;
          
          return; 
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      final success = await provider.updateProfile(
        username: _usernameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil muvaffaqiyatli yangilandi!"),              
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? "Xatolik yuz berdi"),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      final success = await provider.updateProfilePicture(image.path);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil rasmi muvaffaqiyatli yangilandi!"),              
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? "Rasmni yangilashda xatolik"),              
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // Viloyat uchun Dropdown
  Widget _buildRegionDropdown() {
    final sortedRegions = UzbekistanRegions.regionsAndDistricts.keys.toList()..sort();
    return DropdownButtonFormField<String>(
      value: _selectedRegion,
      hint: const Text("Viloyatni tanlang"),
      isExpanded: true,
      items: sortedRegions.map((String region) {
        return DropdownMenuItem<String>(
          value: region,
          child: Text(region, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRegion = newValue;
          _selectedDistrict = null; // Viloyat o'zgarganda tumanni tozalash
          _addressController.clear();
          if (newValue != null) {
            _districtsForSelectedRegion = List<String>.from(UzbekistanRegions.regionsAndDistricts[newValue]!)..sort();
          } else {
            _districtsForSelectedRegion = [];
          }
        });
      },
      decoration: _dropdownDecoration("Viloyatni tanlang"),
      validator: (value) => value == null ? 'Iltimos, viloyatni tanlang' : null,
    );
  }

  // Shahar/Tuman uchun Dropdown
  Widget _buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDistrict,
      hint: const Text("Shahar yoki tumanni tanlang"),
      isExpanded: true,
      // Agar viloyat tanlanmagan bo'lsa, bu dropdown o'chirilgan bo'ladi
      onChanged: _selectedRegion == null ? null : (String? newValue) {
        setState(() {
          _selectedDistrict = newValue;
          _addressController.text = newValue ?? '';
        });
      },
      items: _districtsForSelectedRegion.map((String district) {
        return DropdownMenuItem<String>(
          value: district,
          child: Text(district, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      decoration: _dropdownDecoration("Shahar yoki tumanni tanlang").copyWith(
        fillColor: _selectedRegion == null ? Colors.grey[200] : Colors.white,
      ),
      validator: (value) => value == null ? 'Iltimos, shahar yoki tumanni tanlang' : null,
    );
  }

  // Dropdownlar uchun umumiy dekoratsiya
  InputDecoration _dropdownDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: _outlineBorder(),
      enabledBorder: _outlineBorder(),
      focusedBorder: _outlineBorder(color: AppColors.primaryGreen, width: 1.5),
      disabledBorder: _outlineBorder(color: Colors.grey[300]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Ma'lumotlarim",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Section
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryGreen, width: 2),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  widget.profile.profile_pic ?? 'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const CircleAvatar(
                                      backgroundColor: AppColors.lightGreen,
                                      child: Icon(Icons.person, size: 50, color: AppColors.primaryGreen),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Foydalanuvchi nomi
                    _buildLabel("Foydalanuvchi nomi"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _usernameController,
                      hintText: "Foydalanuvchi nomini kiriting",
                      validator: (value) => value!.isEmpty ? "Foydalanuvchi nomini kiriting" : null,
                    ),
                    const SizedBox(height: 16),

                    // Telefon raqam
                    _buildLabel("Telefon raqam"),
                    const SizedBox(height: 8),
                    _buildPhoneField(),
                    const SizedBox(height: 16),

                    // Email
                    _buildLabel("Email"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Email manzilingizni kiriting",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Manzil
                    _buildLabel("Manzil"),
                    const SizedBox(height: 8),
                    _buildRegionDropdown(),
                    const SizedBox(height: 12),
                    _buildDistrictDropdown(),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Ob-havo ma'lumotini to'g'ri olish uchun viloyat nomini emas, aniq shahar yoki tuman nomini kiriting (masalan, Qo'qon).",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Saqlash tugmasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    offset: Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: InkWell(
                onTap: Provider.of<ProfileProvider>(context).isLoading
                    ? null
                    : _saveProfile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accentGreen, AppColors.primaryGreenDark],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Provider.of<ProfileProvider>(context).isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Saqlash",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF757575),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  OutlineInputBorder _outlineBorder({Color color = const Color(0xFFE8E8E8), double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    // Bu metod endi faqat username va email uchun ishlatiladi.
    // Manzil uchun _buildAddressField() ishlatiladi.
    return TextFormField(controller: controller, keyboardType: keyboardType, validator: validator, style: const TextStyle(fontSize: 16, color: Colors.black), decoration: InputDecoration(hintText: hintText, hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), border: _outlineBorder(), enabledBorder: _outlineBorder(), focusedBorder: _outlineBorder(color: AppColors.primaryGreen, width: 1.5)));
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      validator: (value) => value!.isEmpty ? "Telefon raqamini kiriting" : null,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: "+998 97 123 45 67",
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 16,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 0.5),
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://flagcdn.com/w40/uz.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0099CC),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'UZ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF9E9E9E),
                size: 20,
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00C896),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
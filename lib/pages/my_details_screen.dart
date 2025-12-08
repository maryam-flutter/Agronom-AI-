import 'package:flutter/material.dart';
// import 'package:country_code_picker/country_code_picker.dart';

class MyDetailsScreen extends StatefulWidget {
  const MyDetailsScreen({Key? key}) : super(key: key);

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  String _selectedDate = 'Sanani tanlang';
  String _countryCode = '+998';
  String _flagUrl = 'https://flagcdn.com/w20/uz.png';

  // Country data with flags
  final Map<String, Map<String, String>> _countries = {
    '+998': {'name': '🇺🇿 O\'zbekiston', 'flag': 'https://flagcdn.com/w20/uz.png'},
    '+7': {'name': '🇷🇺 Rossiya', 'flag': 'https://flagcdn.com/w20/ru.png'},
    '+1': {'name': '🇺🇸 AQSh', 'flag': 'https://flagcdn.com/w20/us.png'},
    '+44': {'name': '🇬🇧 Buyuk Britaniya', 'flag': 'https://flagcdn.com/w20/gb.png'},
    '+49': {'name': '🇩🇪 Germaniya', 'flag': 'https://flagcdn.com/w20/de.png'},
    '+33': {'name': '🇫🇷 Fransiya', 'flag': 'https://flagcdn.com/w20/fr.png'},
    '+81': {'name': '🇯🇵 Yaponiya', 'flag': 'https://flagcdn.com/w20/jp.png'},
    '+86': {'name': '🇨🇳 Xitoy', 'flag': 'https://flagcdn.com/w20/cn.png'},
    '+91': {'name': '🇮🇳 Hindiston', 'flag': 'https://flagcdn.com/w20/in.png'},
    '+90': {'name': '🇹🇷 Turkiya', 'flag': 'https://flagcdn.com/w20/tr.png'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Malumotlarim',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    
                    // Familiya
                    _buildLabel('Familiya'),
                    const SizedBox(height: 8),
                    _buildTextField(_familyNameController, 'Familiya'),
                    const SizedBox(height: 20),

                    // Ism
                    _buildLabel('Ism'),
                    const SizedBox(height: 8),
                    _buildTextField(_nameController, 'Ism'),
                    const SizedBox(height: 20),

                    // Otasining ismi
                    _buildLabel('Otasining ismi'),
                    const SizedBox(height: 8),
                    _buildTextField(_fatherNameController, 'Otasining ismi'),
                    const SizedBox(height: 20),

                    // Tug'ilgan kun
                    _buildLabel('Tug\'ilgan kun'),
                    const SizedBox(height: 8),
                    _buildDateField(),
                    const SizedBox(height: 20),

                    // Telefon raqam
                    _buildLabel('Telefon raqam'),
                    const SizedBox(height: 8),
                    _buildPhoneField(),
                    const SizedBox(height: 20),

                    // Email
                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    _buildTextField(_emailController, 'Email'),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            
            // Saqlash tugmasi (fixed at bottom) with gradient
            Container(
              height: 48,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color.fromARGB(255, 26, 240, 186),
                    const Color.fromARGB(255, 38, 234, 77),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4AA).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ma\'lumotlar saqlandi!'),
                      backgroundColor: Color.fromARGB(255, 73, 73, 73),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  'Saqlash',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Label widget
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // TextField widget with gradient
  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  //  date picker with gradient
  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF00D4AA),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            _selectedDate = '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFF8F9FA),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate,
              style: TextStyle(
                color: _selectedDate == 'Sanani tanlang' ? Colors.grey : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // Telefon raqami uchun field with gradient and working dropdown
  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FA),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Country code dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Image.network(
                  _flagUrl,
                  width: 20,
                  height: 15,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 20,
                      height: 15,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Icon(Icons.flag, size: 12),
                    );
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _showCountryPicker();
                  },
                  child: Row(
                    children: [
                      Text(
                        _countryCode,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Vertical divider
          Container(
            width: 1,
            height: 24,
            color: Colors.grey[300],
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
                border: InputBorder.none, // Paddingni olib tashlaymiz, chunki tashqi Containerda bor
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Vertikal paddingni biroz kamaytiramiz
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Country picker function
  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Davlatni tanlang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final code = _countries.keys.elementAt(index);
                    final countryData = _countries[code]!;
                    
                    return ListTile(
                      leading: Image.network(
                        countryData['flag']!,
                        width: 32,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 32,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.flag, size: 16),
                          );
                        },
                      ),
                      title: Text(countryData['name']!.substring(3)), // Country name without emoji
                      trailing: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _countryCode = code;
                          _flagUrl = countryData['flag']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
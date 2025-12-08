import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color(0xFF00C96B); // Rasmga mos yashil rang
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: selectedColor,
      unselectedItemColor: Colors.grey[400],
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: selectedColor,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      ),
      selectedIconTheme: const IconThemeData(
        color: selectedColor,
        size: 32,
      ),
      unselectedIconTheme: const IconThemeData(
        color: Colors.grey,
        size: 28,
      ),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Bosh sahifa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome), // AI doktor uchun mos icon
          label: 'AI doktor',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monitor_heart_outlined), // Agro Market uchun mos icon
          label: 'Agro Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}
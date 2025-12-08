
import 'package:agronom_ai/pages/ai_doctor_screen.dart';
import 'package:agronom_ai/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';


import 'agro_market_screen.dart';
import 'profile_screen.dart';


class HomePageNav extends StatefulWidget {
  const HomePageNav({Key? key}) : super(key: key);

  @override
  State<HomePageNav> createState() => _HomePageNavState();
}

class _HomePageNavState extends State<HomePageNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      HomeScreen(),
      AiDoctorScreen(), // AI doktor
      AgroMarketScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
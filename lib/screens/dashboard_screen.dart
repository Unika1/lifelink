import 'package:flutter/material.dart';
import 'package:lifelink/screens/bottom_screen/home_screen.dart';
import 'package:lifelink/screens/bottom_screen/profile_screen.dart';
import 'package:lifelink/screens/bottom_screen/request_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen> {
  int _selectedIndex=0;
  List<Widget>lstBottomScreen=[
    const HomeScreen(),
    const RequestScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items:[
          BottomNavigationBarItem(
            icon:Image.asset(
              'assets/icons/home.png',
              width: 24,
              height: 24,
            ),
            label: 'Home'
            ),
          BottomNavigationBarItem(
            icon:Image.asset(
              'assets/icons/request.png',
              width: 24,
              height: 24,
            ),
            label:'Request'
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/profile.png',
              width: 24,
              height: 24,
            ),
            label:'Profile'
          ),
      ],
      currentIndex: _selectedIndex,
      onTap: (index){
        setState(() {
          _selectedIndex=index;
        });
      },
      ),
    );
  }
}
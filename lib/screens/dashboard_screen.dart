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
      appBar: AppBar(title: const Text("Dashboard Screen"),
      centerTitle: true,
      ),
      body: lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
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
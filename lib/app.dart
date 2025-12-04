import 'package:flutter/material.dart';
import 'package:lifelink/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:SplashScreen()
      );
  }
}
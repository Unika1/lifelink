import 'package:flutter/material.dart';
import 'package:lifelink/screens/splash_screen.dart';
import 'package:lifelink/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:AppTheme.lightTheme,
      home:SplashScreen()
      );
  }
}
import 'package:flutter/material.dart';
import 'package:lifelink/feature/onboarding/presentation/pages/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Future.delayed(const Duration(seconds:4),(){
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder:(_)=>const OnboardingScreen()),
    );
    }); 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:Center(
            child:Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Image.asset("assets/images/lifelink_logo1.jpg"),
                    SizedBox(height: 16),
                ],
                
            )
        )
    );
  }
}
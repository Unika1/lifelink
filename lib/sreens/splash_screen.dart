import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    /*Future.delayed(const Duration(seconds:2),(){
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder:(_)=>const LoginScreen()),
    );
    }); */
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:Center(
            child:Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Image.asset("assets/images/LifeLink.png"),
                    SizedBox(height: 16),
                ],
                
            )
        )
    );
  }
}
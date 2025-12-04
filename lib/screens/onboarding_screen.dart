import 'package:flutter/material.dart';
import 'package:lifelink/models/onboard_item.dart';
import 'package:lifelink/widgets/my_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController=PageController();
  int _currentPage=0;

  final List<OnboardItem>pages=const[
    OnboardItem(
      title:"You Can Be Someone's Lifeline", 
      icon: Icons.favorite, 
      subtitle: "Your small act of kindness can save someone's life."
    ),
    OnboardItem(
      title: "Find Donors Nearby",
      subtitle: "Quickly connect with trusted local donors.",
      icon: Icons.location_on,
    ),
    OnboardItem(
      icon: Icons.emergency_share,
      title: "Emergency Request",
      subtitle: "Request instantly and get urgent help faster."
    ),
  ];
   void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }
  void _finishOnboarding(){
        // later: navigate to LoginScreen()
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (_) => const LoginScreen()),
        // );
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finishOnboarding, child: const Text(
                "Skip",
                style:TextStyle(color:Colors.redAccent),
                ),
              ),
            ),
            Expanded(
              flex:4,
              child:PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index){
                setState(() {
                  _currentPage=index;
                });
              }, 
              itemBuilder: (context,index) {
                final item=pages[index];
                return Padding(padding: const EdgeInsets.symmetric(horizontal:30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 120,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 35),
                      Text(
                        item.title,
                        textAlign: TextAlign.center,
                        style:const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(item.subtitle,
                      textAlign:TextAlign.center,
                      style:TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        ),
                      ),
                      ],
                    ),
                  );
                },
              ),
            ),  
             Padding(
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 30),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 14 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.red
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              const Spacer(),
              SizedBox(
                width: 180,
                child: MyButton(
                  text: _currentPage==pages.length-1 ? "Get Started":"Next",
                  color: Colors.redAccent,
                onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
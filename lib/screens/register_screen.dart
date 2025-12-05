import 'package:flutter/material.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/screens/login_screen.dart';
import 'package:lifelink/widgets/my_button.dart';
import 'package:lifelink/widgets/my_textformfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController=TextEditingController();
  final emailController=TextEditingController();
  final passwordController=TextEditingController();

  @override
  void dispose(){
  nameController.dispose();
  emailController.dispose();
  passwordController.dispose();
  super.dispose();
}
  void _registerUser() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showMySnackBar(
        context: context,
        message: "All fields required",
        color: Colors.redAccent,
      );
    } else {
      showMySnackBar(
        context: context,
        message: "Account created successfully",
        color: Colors.green,
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                IconButton(onPressed: (){
          
                }, icon: const Icon(Icons.arrow_back,color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Register",
                  style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                MyTextformfield(
                  labelText: "Email", 
                  hintText: "Enter your email", 
                  controller: emailController
                ),
                const SizedBox(height:20),
          
                MyTextformfield(
                  labelText: "Password", 
                  hintText: "Create Password", 
                  controller: passwordController,
                ),
                MyButton(
                  text: "Create Account", 
                  color: Colors.redAccent,
                  onPressed: _registerUser,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
      
    );
  }
}
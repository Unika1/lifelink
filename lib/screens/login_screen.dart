import 'package:flutter/material.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/widgets/my_button.dart';
import 'package:lifelink/widgets/my_textformfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController=TextEditingController();
  final TextEditingController passwordController=TextEditingController();

@override
void dispose(){
  emailController.dispose();
  passwordController.dispose();
  super.dispose();
}

  void _handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMySnackBar(
        context: context,
        message: "Please fill all fields",
        color: Colors.redAccent,
      );
    } else {
      showMySnackBar(
        context: context,
        message: "Login Successful",
        color: Colors.green,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                "Login",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              MyTextformfield(
                labelText: "Email", 
                hintText: "Enter your email", 
                controller: emailController,
              ),
              const SizedBox(height: 20),

              MyTextformfield(
                labelText: "Password", 
                hintText: "Enter your password", 
                controller: passwordController,
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (){}, 
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              MyButton(
                text: "Login", 
                color: Colors.redAccent,
                onPressed:_handleLogin,
              ),
              const SizedBox(height: 25),
              Row(
                children: const[
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text("Continue with Google"),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to RegisterScreen
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ), 
              const SizedBox(height:20),             
            ],
          )
        ),
      ),
    );
  }
}
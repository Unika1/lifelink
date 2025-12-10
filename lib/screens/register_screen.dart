import 'package:flutter/material.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/screens/dashboard_screen.dart';
import 'package:lifelink/screens/login_screen.dart';
import 'package:lifelink/widgets/my_button.dart';
import 'package:lifelink/widgets/my_textformfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _registerUser() {
    if (firstnameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create An Account",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B001B),
                        ),
                      ),
                      const SizedBox(height: 24),

                      MyTextformfield(
                        labelText: "First name",
                        hintText: "Enter your first name",
                        controller: firstnameController,
                      ),
                      const SizedBox(height: 16),

                      MyTextformfield(
                        labelText: "Last name",
                        hintText: "Enter your last name",
                        controller: lastnameController,
                      ),
                      const SizedBox(height: 16),

                      MyTextformfield(
                        labelText: "Email",
                        hintText: "Enter your email",
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),

                      MyTextformfield(
                        labelText: "Password",
                        hintText: "Create password",
                        controller: passwordController,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: MyButton(
                          text: "Create Account",
                          color: const Color(0xFFE4153B),
                          onPressed: _registerUser,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 0.8)),
                          const SizedBox(width: 8),
                          Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(child: Divider(thickness: 0.8)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            showMySnackBar(
                              context: context,
                              message: "Google sign in pressed",
                              color: Colors.redAccent,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.g_mobiledata, size: 28),
                              SizedBox(width: 8),
                              Text(
                                "Sign in with Google",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Color(0xFFE4153B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/feature/auth/presentation/pages/login_screen.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/widgets/my_button.dart';
import 'package:lifelink/widgets/my_textformfield.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    await ref.read(authViewModelProvider.notifier).register(
          firstName: firstnameController.text.trim(),
          lastName: lastnameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          confirmPassword: confirmPasswordController.text.trim(),
        );
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<bool> _handleBackNavigation() async {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
    } else {
      _goToLogin();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showMySnackBar(
            context: context,
            message: next.errorMessage ?? "Registration failed",
            color: Colors.redAccent,
          );
        });
      }

      if (next.status == AuthStatus.registered) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showMySnackBar(
            context: context,
            message: "Account created successfully",
            color: Colors.green,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        });
      }
    });

    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF4F7),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                children: [
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: _goToLogin,
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
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),

                        MyTextformfield(
                          labelText: "Confirm Password",
                          hintText: "Re-enter password",
                          controller: confirmPasswordController,
                          obscureText: true,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: MyButton(
                            text: authState.status == AuthStatus.loading
                                ? "Creating..."
                                : "Create Account",
                            color: const Color(0xFFE4153B),
                            onPressed: authState.status == AuthStatus.loading
                                ? null
                                : _registerUser,
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
                      ],
                    ),
                  ),

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
        ),
      ),
    );
  }
}

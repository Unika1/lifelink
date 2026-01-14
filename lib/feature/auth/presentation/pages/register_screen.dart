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

  final _formKey = GlobalKey<FormState>();

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
          confirmPassword: confirmPasswordController.text.trim(), // ✅ send this
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Registration failed",
          color: Colors.redAccent,
        );
      }

      if (next.status == AuthStatus.registered) {
        showMySnackBar(
          context: context,
          message: "Account created successfully",
          color: Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/widgets/my_button.dart';
import 'package:lifelink/widgets/my_textformfield.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    oldController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final oldPass = oldController.text.trim();
    final newPass = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (newPass != confirm) {
      showMySnackBar(
        context: context,
        message: "New password and confirm password do not match",
        color: Colors.redAccent,
      );
      return;
    }

    if (oldPass == newPass) {
      showMySnackBar(
        context: context,
        message: 'New password must be different from old password',
        color: Colors.redAccent,
      );
      return;
    }

    final success = await ref
        .read(authViewModelProvider.notifier)
        .changePassword(
          currentPassword: oldPass,
          newPassword: newPass,
        );

    if (!mounted) return;

    if (success) {
      showMySnackBar(
        context: context,
        message: 'Password changed successfully',
        color: Colors.green,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (!mounted) return;
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        showMySnackBar(
          context: context,
          message: next.errorMessage!,
          color: Colors.redAccent,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              MyTextformfield(
                labelText: "Old Password",
                hintText: "Enter old password",
                controller: oldController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Old password is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              MyTextformfield(
                labelText: "New Password",
                hintText: "Enter new password",
                controller: newController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'New password is required';
                  }
                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              MyTextformfield(
                labelText: "Confirm Password",
                hintText: "Re-enter new password",
                controller: confirmController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Confirm password is required';
                  }
                  if (value.trim() != newController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: MyButton(
                  text: authState.status == AuthStatus.loading
                      ? 'Updating...'
                      : "Update Password",
                  color: Colors.redAccent,
                  onPressed:
                      authState.status == AuthStatus.loading ? null : _updatePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
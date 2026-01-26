import 'package:flutter/material.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/widgets/my_button.dart';
import 'package:lifelink/widgets/my_textformfield.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
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

  void _updatePassword() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

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

    // For this sprint: UI only
    showMySnackBar(
      context: context,
      message: "Password updated (UI only). API will be added next sprint.",
      color: Colors.green,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
              ),
              const SizedBox(height: 14),
              MyTextformfield(
                labelText: "New Password",
                hintText: "Enter new password",
                controller: newController,
                obscureText: true,
              ),
              const SizedBox(height: 14),
              MyTextformfield(
                labelText: "Confirm Password",
                hintText: "Re-enter new password",
                controller: confirmController,
                obscureText: true,
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: MyButton(
                  text: "Update Password",
                  color: Colors.redAccent,
                  onPressed: _updatePassword,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

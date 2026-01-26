import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/feature/auth/presentation/pages/login_screen.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/profile/change_password_screen.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    // If user not logged in (safety)
    if (authState.authEntity == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final user = authState.authEntity!;
    final fullName = "${user.firstName} ${user.lastName}".trim();
    final email = user.email;

    // If you don't have username in backend yet, show fallback:
    final username = user.email.split('@').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.person, size: 44, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullName.isEmpty ? "User" : fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Info Card
            _SectionCard(
              title: "Basic Information",
              children: [
                _InfoTile(label: "Full Name", value: fullName),
                _InfoTile(label: "Email", value: email),
                _InfoTile(label: "Username", value: username),
              ],
            ),

            const SizedBox(height: 14),

            // Health & Emergency
            _SectionCard(
              title: "Health & Emergency",
              children: const [
                _InfoTile(label: "Blood Group", value: "O+"),
                _InfoTile(label: "Phone Number", value: "98XXXXXXXX"),
                _InfoTile(label: "Emergency Contact", value: "97XXXXXXXX"),
              ],
            ),

            const SizedBox(height: 14),

            // Actions
            _SectionCard(
              title: "Security & Actions",
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("Change Password"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Logout"),
                  onTap: () async {
                    await ref.read(authViewModelProvider.notifier).logout();

                    if (context.mounted) {
                      showMySnackBar(
                        context: context,
                        message: "Logged out successfully",
                        color: Colors.green,
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/auth/presentation/pages/login_screen.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/profile/change_password_screen.dart';
import 'package:lifelink/feature/profile/presentation/state/profile_state.dart';
import 'package:lifelink/feature/profile/presentation/view_model/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _pickAndUpload(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    await ref
        .read(profileViewModelProvider.notifier)
        .uploadProfileImage(File(picked.path));
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickAndUpload(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBloodGroup(String? current) async {
    final controller = TextEditingController(text: current ?? "");

    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Blood Group"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "e.g. O+, A-, B+",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      ref.read(profileViewModelProvider.notifier).setBloodGroup(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final profileState = ref.watch(profileViewModelProvider);

    ref.listen(profileViewModelProvider, (prev, next) {
      if (next.status == ProfileStatus.error &&
          prev?.status != ProfileStatus.error) {
        showMySnackBar(
          context: context,
          message: next.errorMessage ?? "Something went wrong",
          color: Colors.red,
        );
      }

      if (next.status == ProfileStatus.loaded &&
          prev?.status == ProfileStatus.loading) {
        showMySnackBar(
          context: context,
          message: "Updated successfully",
          color: Colors.green,
        );
      }
    });

    if (authState.authEntity == null) {
      return const Scaffold(body: Center(child: Text("No user logged in")));
    }

    final user = authState.authEntity!;
    final fullName = "${user.firstName} ${user.lastName}".trim();
    final email = user.email;
    final username = user.email.split('@').first;

    // Priority: profileImageUrl (uploaded) > authEntity.imageUrl (from backend) > null
    final imagePath = profileState.profileImageUrl ?? user.imageUrl;
    final fullImageUrl = (imagePath == null || imagePath.isEmpty)
        ? null
        : '${ApiEndpoints.fullImageUrl(imagePath)}?t=${DateTime.now().millisecondsSinceEpoch}';

    final isUploading = profileState.status == ProfileStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        key: ValueKey(fullImageUrl),
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: fullImageUrl == null
                              ? const Icon(Icons.person, size: 50, color: Colors.grey)
                              : Image.network(
                                  fullImageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) {
                                    return const Icon(Icons.person, size: 50, color: Colors.red);
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: isUploading ? null : _showPickOptions,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: isUploading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
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

            _SectionCard(
              title: "Basic Information",
              children: [
                _InfoTile(label: "Full Name", value: fullName),
                _InfoTile(label: "Email", value: email),
                _InfoTile(label: "Username", value: username),
              ],
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: "Health & Emergency",
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Blood Group"),
                  subtitle: Text(profileState.bloodGroup ?? "Tap to set"),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editBloodGroup(profileState.bloodGroup),
                ),
                const Divider(height: 1),
                const _InfoTile(label: "Phone Number", value: "98XXXXXXXX"),
                const _InfoTile(label: "Emergency Contact", value: "97XXXXXXXX"),
              ],
            ),

            const SizedBox(height: 14),

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
                    if (!mounted) return;

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
          SizedBox(width: 130, child: Text(label, style: TextStyle(color: Colors.grey.shade700))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

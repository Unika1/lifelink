import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lifelink/common/my_snackbar.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/auth/presentation/pages/login_screen.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/profile/presentation/state/profile_state.dart';
import 'package:lifelink/feature/profile/presentation/view_model/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();
  final List<XFile> _selectedMedia = [];

  /// Request permission with proper status handling
  Future<bool> _askUserForPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      if (!mounted) return false;
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  /// Show dialog when permission is permanently denied
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Please enable permission from Settings to use this feature.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Pick from camera with permission handling
  Future<void> _pickFromCamera() async {
    final hasPermission = await _askUserForPermission(Permission.camera);
    if (!hasPermission) return;

    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      _selectedMedia.clear();
      _selectedMedia.add(picked);
    });
  }

  /// Pick from gallery with permission handling
  Future<void> _pickFromGallery({bool allowMultiple = false}) async {
    try {
      if (allowMultiple) {
        final List<XFile> images = await _picker.pickMultiImage(
          imageQuality: 80,
        );
        if (images.isNotEmpty) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.addAll(images);
          });
        }
      } else {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) {
          setState(() {
            _selectedMedia.clear();
            _selectedMedia.add(image);
          });
        }
      }
    } catch (e) {
      debugPrint('Gallery Error $e');
      if (mounted) {
        showMySnackBar(
          context: context,
          message: 'Cannot access your gallery',
          color: Colors.red,
        );
      }
    }
  }

  /// Upload selected media
  Future<void> _uploadSelectedMedia() async {
    if (_selectedMedia.isEmpty) {
      showMySnackBar(
        context: context,
        message: 'Please select an image first',
        color: Colors.orange,
      );
      return;
    }

    await ref
        .read(profileViewModelProvider.notifier)
        .uploadProfileImage(File(_selectedMedia[0].path));

    setState(() {
      _selectedMedia.clear();
    });
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
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editBloodGroup(String? current) async {
    const bloodTypes = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];

    final result = await showDialog<String?>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text("Select Blood Group"),
        children: bloodTypes.map((type) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, type),
            child: Row(
              children: [
                Icon(
                  current == type ? Icons.check_circle : Icons.circle_outlined,
                  color: current == type ? Colors.redAccent : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: current == type
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      ref.read(profileViewModelProvider.notifier).setBloodGroup(result);
    }
  }

  Future<void> _editPhoneNumber(String? current) async {
    final controller = TextEditingController(text: current ?? "");

    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Phone Number"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "e.g. 98XXXXXXXX"),
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
      ref.read(profileViewModelProvider.notifier).setPhoneNumber(result);
    }
  }

  Future<void> _editEmergencyContact(String? current) async {
    final controller = TextEditingController(text: current ?? "");

    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Emergency Contact"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "e.g. 97XXXXXXXX"),
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
      ref.read(profileViewModelProvider.notifier).setEmergencyContact(result);
    }
  }

  Future<void> _editBasicInfo({
    required String currentFirstName,
    required String currentLastName,
    required String currentEmail,
  }) async {
    final firstNameController = TextEditingController(text: currentFirstName);
    final lastNameController = TextEditingController(text: currentLastName);
    final emailController = TextEditingController(text: currentEmail);

    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Basic Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final firstName = firstNameController.text.trim();
              final lastName = lastNameController.text.trim();
              final email = emailController.text.trim();

              if (firstName.isEmpty ||
                  lastName.isEmpty ||
                  !email.contains('@')) {
                return;
              }

              Navigator.pop(context, {
                'firstName': firstName,
                'lastName': lastName,
                'email': email,
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref
          .read(profileViewModelProvider.notifier)
          .setBasicInfo(
            firstName: result['firstName']!,
            lastName: result['lastName']!,
            email: result['email']!,
          );
    }
  }

  Future<void> _showChangePasswordBottomSheet() async {
    final formKey = GlobalKey<FormState>();
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Change Password",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Old Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Old password is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "New password is required";
                      }
                      if (value.trim().length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm New Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Confirm password is required";
                      }
                      if (value.trim() != newPasswordController.text.trim()) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final isValid =
                            formKey.currentState?.validate() ?? false;
                        if (!isValid) return;

                        final oldPassword = oldPasswordController.text.trim();
                        final newPassword = newPasswordController.text.trim();

                        if (oldPassword == newPassword) {
                          showMySnackBar(
                            context: context,
                            message:
                                "New password must be different from old password",
                            color: Colors.red,
                          );
                          return;
                        }

                        final isChanged = await ref
                            .read(authViewModelProvider.notifier)
                            .changePassword(
                              currentPassword: oldPassword,
                              newPassword: newPassword,
                            );

                        if (!mounted) return;

                        if (isChanged) {
                          Navigator.pop(bottomSheetContext);
                          showMySnackBar(
                            context: context,
                            message: "Password changed successfully",
                            color: Colors.green,
                          );
                        }
                      },
                      child: const Text("Update Password"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
      final isLoading =
          profileState.status == ProfileStatus.initial ||
          profileState.status == ProfileStatus.loading;

      if (isLoading) {
        return Scaffold(
          appBar: AppBar(title: const Text("Profile"), centerTitle: true),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        appBar: AppBar(title: const Text("Profile"), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(profileState.errorMessage ?? "No user logged in"),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    final user = authState.authEntity!;
    final firstName = profileState.firstName ?? user.firstName;
    final lastName = profileState.lastName ?? user.lastName;
    final email = profileState.email ?? user.email;
    final fullName = "$firstName $lastName".trim();
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
                          child: _selectedMedia.isNotEmpty
                              ? Image.file(
                                  File(_selectedMedia[0].path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : (fullImageUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      )
                                    : Image.network(
                                        fullImageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) {
                                          return const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.red,
                                          );
                                        },
                                      )),
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
                                : const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullName.isEmpty ? "User" : fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(email, style: TextStyle(color: Colors.grey.shade700)),
                  if (_selectedMedia.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: isUploading ? null : _uploadSelectedMedia,
                          icon: const Icon(Icons.upload),
                          label: const Text("Upload"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedMedia.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                          label: const Text("Cancel"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 18),

            _SectionCard(
              title: "Basic Information",
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editBasicInfo(
                  currentFirstName: firstName,
                  currentLastName: lastName,
                  currentEmail: email,
                ),
              ),
              children: [
                _InfoTile(label: "Full Name", value: fullName),
                _InfoTile(label: "Email", value: email),
                _InfoTile(label: "Username", value: username),
                _InfoTile(
                  label: "Role",
                  value: user.role.isEmpty
                      ? "User"
                      : user.role[0].toUpperCase() + user.role.substring(1),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Builder(
              builder: (context) {
                final bloodGroup = profileState.bloodGroup ?? user.bloodGroup;
                final phoneNumber =
                    profileState.phoneNumber ?? user.phoneNumber;
                return _SectionCard(
                  title: "Health & Emergency",
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Blood Group"),
                      subtitle: Text(bloodGroup ?? "Tap to set"),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _editBloodGroup(bloodGroup),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Phone Number"),
                      subtitle: Text(phoneNumber ?? "Tap to set"),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _editPhoneNumber(phoneNumber),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Emergency Contact"),
                      subtitle: Text(
                        profileState.emergencyContact ?? "Tap to set",
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () =>
                          _editEmergencyContact(profileState.emergencyContact),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: "Security & Actions",
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text("Change Password"),
                  trailing: const Icon(Icons.keyboard_arrow_up),
                  onTap: _showChangePasswordBottomSheet,
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
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.trailing,
    required this.children,
  });

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
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
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

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/feature/home/presentation/pages/dashboard_screen.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';
import 'package:lifelink/feature/profile/presentation/view_model/profile_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class CreateOrganRequestScreen extends ConsumerStatefulWidget {
  final String? hospitalId;
  final String? hospitalName;

  const CreateOrganRequestScreen({
    super.key,
    this.hospitalId,
    this.hospitalName,
  });

  @override
  ConsumerState<CreateOrganRequestScreen> createState() =>
      _CreateOrganRequestScreenState();
}

class _CreateOrganRequestScreenState
    extends ConsumerState<CreateOrganRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  HospitalEntity? _selectedHospital;
  File? _reportFile;
  String? _reportFileName;

  bool get _hasPreselectedHospital =>
      widget.hospitalId != null && widget.hospitalName != null;

  @override
  void initState() {
    super.initState();
    // Fetch hospitals for dropdown if none pre-selected
    if (!_hasPreselectedHospital) {
      Future.microtask(
        () => ref.read(hospitalViewModelProvider.notifier).getAllHospitals(),
      );
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickHealthReport() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _reportFile = File(result.files.single.path!);
          _reportFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_reportFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your health report (PDF or image)'),
        ),
      );
      return;
    }

    // Determine hospital name and id
    final String hospitalName;
    final String hospitalId;
    if (_hasPreselectedHospital) {
      hospitalName = widget.hospitalName!.trim();
      hospitalId = widget.hospitalId!.trim();
    } else if (_selectedHospital != null) {
      hospitalName = _selectedHospital!.name.trim();
      hospitalId = _selectedHospital!.id!.trim();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a hospital')));
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final profileState = ref.read(profileViewModelProvider);
    final user = authState.authEntity;
    final profileName =
        '${profileState.firstName ?? ''} ${profileState.lastName ?? ''}'.trim();
    final authName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final donorName = profileName.isNotEmpty ? profileName : authName;

    final success = await ref
        .read(organRequestViewModelProvider.notifier)
        .createRequest(
          hospitalId: hospitalId,
          hospitalName: hospitalName,
          donorName: donorName.trim().isNotEmpty ? donorName.trim() : 'Donor',
          reportFile: _reportFile!,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          requestedBy: user?.authId,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Organ donation request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(organRequestViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final hospitalState = ref.watch(hospitalViewModelProvider);
    final hospitals = hospitalState.hospitals;
    final isHospitalLoading = hospitalState.status == HospitalStatus.loading;
    final user = authState.authEntity;
    final isSubmitting = requestState.status == OrganRequestStatus.loading;

    ref.listen<OrganRequestState>(organRequestViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == OrganRequestStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organ Donation Request'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxContentWidth = constraints.maxWidth > 860
              ? 860.0
              : constraints.maxWidth;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.purple.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Upload your health report. The hospital will review and contact you for further procedures.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Donor Information
                      Text(
                        'Donor Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Name',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ': ',
                                  style: TextStyle(fontSize: 13),
                                ),
                                Expanded(
                                  child: Text(
                                    '${user?.firstName ?? ''} ${user?.lastName ?? 'Not available'}'
                                        .trim(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ': ',
                                  style: TextStyle(fontSize: 13),
                                ),
                                Expanded(
                                  child: Text(
                                    user?.email ?? 'Not available',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Text(
                                    'Phone',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ': ',
                                  style: TextStyle(fontSize: 13),
                                ),
                                Expanded(
                                  child: Text(
                                    user?.phoneNumber ?? 'Not available',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Hospital Selection (if not pre-selected)
                      if (!_hasPreselectedHospital) ...[
                        Text(
                          'Select Hospital',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isHospitalLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (hospitals.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('No hospitals available'),
                          )
                        else
                          Builder(
                            builder: (context) {
                              final List<DropdownMenuItem<HospitalEntity>>
                              hospitalItems = [];

                              for (final hospital in hospitals) {
                                hospitalItems.add(
                                  DropdownMenuItem<HospitalEntity>(
                                    value: hospital,
                                    child: Text(
                                      hospital.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return DropdownButtonFormField<HospitalEntity>(
                                initialValue: _selectedHospital,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                hint: const Text('Choose a hospital'),
                                items: hospitalItems,
                                onChanged: (value) {
                                  setState(() => _selectedHospital = value);
                                },
                                validator: (value) {
                                  if (value == null)
                                    return 'Please select a hospital';
                                  return null;
                                },
                              );
                            },
                          ),
                        if (_selectedHospital != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _selectedHospital!.address.fullAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 24),
                      ] else ...[
                        Text(
                          'Hospital',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            widget.hospitalName!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Health Report Upload
                      Text(
                        'Health Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_reportFile != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'File uploaded successfully',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _reportFileName ?? 'health_report',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _reportFile = null;
                                        _reportFileName = null;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Remove file',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _pickHealthReport,
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                _reportFile == null
                                    ? 'Upload Health Report (PDF or Image)'
                                    : 'Change File',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Accepted formats: PDF, JPG, JPEG, PNG (Max 10MB)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Notes
                      Text(
                        'Additional Notes (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Any additional information...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Submit Request',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

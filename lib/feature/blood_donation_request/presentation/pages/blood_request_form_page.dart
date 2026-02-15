import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/view_model/blood_request_view_model.dart';
import 'package:lifelink/feature/home/presentation/pages/dashboard_screen.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/feature/profile/presentation/view_model/profile_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class BloodRequestFormPage extends ConsumerStatefulWidget {
  final BloodRequestEntity? request;
  final String? hospitalId;
  final String? hospitalName;

  const BloodRequestFormPage({
    super.key,
    this.request,
    this.hospitalId,
    this.hospitalName,
  });

  @override
  ConsumerState<BloodRequestFormPage> createState() =>
      _BloodRequestFormPageState();
}

class _BloodRequestFormPageState extends ConsumerState<BloodRequestFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  String? _selectedBloodType;
  DateTime? _preferredDate;
  HospitalEntity? _selectedHospital;
  bool _isEditing = false;

  bool get _isUpdate => widget.request != null;

  bool get _canUpdate => widget.request?.status == 'pending';

  bool get _hasPreselectedHospital =>
      widget.hospitalId != null && widget.hospitalName != null;

  @override
  void initState() {
    super.initState();

    if (_isUpdate) {
      final request = widget.request!;
      _selectedBloodType = request.bloodType;
      _preferredDate = request.neededBy;
      _notesController.text = request.notes ?? '';
      _isEditing = false;
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final userBloodGroup = authState.authEntity?.bloodGroup;
    if (userBloodGroup != null && _bloodTypes.contains(userBloodGroup)) {
      _selectedBloodType = userBloodGroup;
    }
    _isEditing = true;

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

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'fulfilled':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'fulfilled':
        return Icons.task_alt;
      case 'pending':
      default:
        return Icons.hourglass_top;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'Not set';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year}  $hour:$minute $period';
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _preferredDate = picked);
    }
  }

  Future<void> _saveOrCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBloodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your blood type')),
      );
      return;
    }

    if (_isUpdate) {
      final current = widget.request!;
      final updated = BloodRequestEntity(
        id: current.id,
        hospitalId: current.hospitalId,
        hospitalName: current.hospitalName,
        patientName: current.patientName,
        bloodType: _selectedBloodType!,
        unitsRequested: current.unitsRequested,
        status: current.status,
        requestedBy: current.requestedBy,
        contactPhone: current.contactPhone,
        neededBy: _preferredDate,
        scheduledAt: current.scheduledAt,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final success = await ref
          .read(bloodRequestViewModelProvider.notifier)
          .updateRequest(current.id!, updated);

      if (success && mounted) {
        Navigator.pop(context, true);
      }
      return;
    }

    final String hospitalName;
    final String hospitalId;

    if (_hasPreselectedHospital) {
      hospitalName = widget.hospitalName!.trim();
      hospitalId = widget.hospitalId!.trim();
    } else if (_selectedHospital != null) {
      final selectedId = _selectedHospital!.id;
      if (selectedId == null || selectedId.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected hospital is invalid. Please choose again.')),
        );
        return;
      }
      hospitalName = _selectedHospital!.name.trim();
      hospitalId = selectedId.trim();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a hospital')),
      );
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final profileState = ref.read(profileViewModelProvider);
    final user = authState.authEntity;
    final profileName =
      '${profileState.firstName ?? ''} ${profileState.lastName ?? ''}'.trim();
    final authName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();
    final donorName = profileName.isNotEmpty ? profileName : authName;

    final request = BloodRequestEntity(
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      patientName: donorName.isNotEmpty ? donorName : 'Donor',
      bloodType: _selectedBloodType!,
      unitsRequested: 1,
      requestedBy: user?.authId,
      neededBy: _preferredDate,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
    );

    final success =
        await ref.read(bloodRequestViewModelProvider.notifier).createRequest(request);

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  void _confirmDelete() {
    final request = widget.request;
    if (request?.id == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this donation request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(bloodRequestViewModelProvider.notifier)
                  .deleteRequest(request!.id!);
              if (success && mounted) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(bloodRequestViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;
    final isSubmitting = requestState.status == BloodRequestStatus.creating ||
        requestState.status == BloodRequestStatus.loading;

    ref.listen<BloodRequestState>(bloodRequestViewModelProvider, (previous, next) {
      if (next.status == BloodRequestStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    final currentRequest = widget.request;
    final statusColor = _statusColor(currentRequest?.status ?? 'pending');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isUpdate
              ? 'Blood Donation Request Details'
              : 'Create Blood Donation Request',
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        actions: [
          if (_isUpdate && _canUpdate && !_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            ),
          if (_isUpdate && _canUpdate)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isUpdate) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(_statusIcon(currentRequest!.status), color: statusColor, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        currentRequest.status[0].toUpperCase() + currentRequest.status.substring(1),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              _buildSectionTitle('Hospital'),
              const SizedBox(height: 8),
              _buildHospitalSection(currentRequest),
              const SizedBox(height: 16),

              _buildSectionTitle('Donor'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  _isUpdate
                      ? currentRequest!.patientName
                      : '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                  style: const TextStyle(fontSize: 15, color: AppTheme.textColor),
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Blood Type'),
              const SizedBox(height: 10),
              Builder(
                builder: (context) {
                  final List<Widget> bloodTypeItems = [];

                  for (final type in _bloodTypes) {
                    final isSelected = _selectedBloodType == type;
                    bloodTypeItems.add(
                      GestureDetector(
                        onTap: (_isEditing || !_isUpdate)
                            ? () => setState(() => _selectedBloodType = type)
                            : null,
                        child: Container(
                          width: 56,
                          height: 38,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? AppTheme.primaryColor : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.white : AppTheme.textColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: bloodTypeItems,
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Preferred Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: (_isEditing || !_isUpdate) ? _selectDate : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    _formatDate(_preferredDate),
                    style: TextStyle(
                      fontSize: 15,
                      color: _preferredDate != null
                          ? AppTheme.textColor
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),

              if (_isUpdate && currentRequest?.scheduledAt != null) ...[
                const SizedBox(height: 12),
                _buildSectionTitle('Scheduled Date'),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(currentRequest!.scheduledAt),
                  style: const TextStyle(fontSize: 14, color: AppTheme.textColor),
                ),
              ],

              const SizedBox(height: 16),
              _buildSectionTitle('Notes'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                readOnly: _isUpdate && !_isEditing,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional notes (optional)',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (!_isUpdate || _isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _saveOrCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isUpdate ? 'Save Changes' : 'Submit Donation Request',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalSection(BloodRequestEntity? currentRequest) {
    if (_isUpdate) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          currentRequest!.hospitalName,
          style: const TextStyle(fontSize: 15, color: AppTheme.textColor),
        ),
      );
    }

    if (_hasPreselectedHospital) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          widget.hospitalName!,
          style: const TextStyle(fontSize: 15, color: AppTheme.textColor),
        ),
      );
    }

    final hospitalState = ref.watch(hospitalViewModelProvider);

    if (hospitalState.status == HospitalStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    final List<DropdownMenuItem<HospitalEntity>> hospitalItems = [];
    for (final hospital in hospitalState.hospitals) {
      hospitalItems.add(
        DropdownMenuItem<HospitalEntity>(
          value: hospital,
          child: Text(hospital.name, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return DropdownButtonFormField<HospitalEntity>(
      value: _selectedHospital,
      decoration: InputDecoration(
        hintText: 'Select a hospital',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      isExpanded: true,
      items: hospitalItems,
      onChanged: (hospital) => setState(() => _selectedHospital = hospital),
      validator: (value) {
        if (value == null) return 'Please select a hospital';
        return null;
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }
}

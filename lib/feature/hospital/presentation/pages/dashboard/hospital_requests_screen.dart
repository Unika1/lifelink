import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/view_model/blood_request_view_model.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/feature/profile/presentation/pages/profile_screen.dart';
import 'package:lifelink/theme/app_theme.dart';

class HospitalRequestsScreen extends ConsumerStatefulWidget {
  const HospitalRequestsScreen({super.key});

  @override
  ConsumerState<HospitalRequestsScreen> createState() =>
      _HospitalRequestsScreenState();
}

class _HospitalRequestsScreenState
    extends ConsumerState<HospitalRequestsScreen> {
  String? _statusFilter;
  String _requestType = 'blood';
  HospitalEntity? _currentHospital;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadRequests());
  }

  Future<HospitalEntity?> _resolveCurrentHospital() async {
    final auth = ref.read(authViewModelProvider).authEntity;
    await ref.read(hospitalViewModelProvider.notifier).getAllHospitals();
    final hospitals = ref.read(hospitalViewModelProvider).hospitals;

    if (hospitals.isEmpty) return null;

    final matchedByUserId = hospitals.where(
      (hospital) =>
          auth?.authId != null &&
          hospital.userId != null &&
          hospital.userId == auth!.authId,
    );

    if (matchedByUserId.isNotEmpty) {
      return matchedByUserId.first;
    }

    final matchedByEmail = hospitals.where(
      (hospital) =>
          auth?.email != null &&
          hospital.email.toLowerCase() == auth!.email.toLowerCase(),
    );

    if (matchedByEmail.isNotEmpty) {
      return matchedByEmail.first;
    }

    final fallbackName =
        '${auth?.firstName ?? ''} ${auth?.lastName ?? ''}'.trim().toLowerCase();
    final matchedByName = hospitals.where(
      (hospital) => hospital.name.toLowerCase() == fallbackName,
    );

    if (matchedByName.isNotEmpty) {
      return matchedByName.first;
    }

    return null;
  }

  Future<void> _loadRequests() async {
    final auth = ref.read(authViewModelProvider).authEntity;
    final currentHospital = await _resolveCurrentHospital();
    if (mounted) {
      setState(() {
        _currentHospital = currentHospital;
      });
    }
    final hospitalId = currentHospital?.id;
    final hospitalName = currentHospital?.name.trim().isNotEmpty == true
        ? currentHospital!.name.trim()
        : '${auth?.firstName ?? ''} ${auth?.lastName ?? ''}'.trim();

    ref.read(bloodRequestViewModelProvider.notifier).getAllRequests(
          hospitalId: hospitalId,
          hospitalName: hospitalName.isEmpty ? null : hospitalName,
        );

    ref.read(organRequestViewModelProvider.notifier).getAllRequests(
          hospitalId: hospitalId,
          hospitalName: hospitalName.isEmpty ? null : hospitalName,
        );
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
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  List<BloodRequestEntity> _filterRequests(List<BloodRequestEntity> requests) {
    if (_statusFilter == null) return requests;
    return requests.where((r) => r.status == _statusFilter).toList();
  }

  int _countByStatus(List<BloodRequestEntity> requests, String status) {
    return requests.where((r) => r.status == status).length;
  }

  List<OrganRequestEntity> _filterOrganRequests(
    List<OrganRequestEntity> requests,
  ) {
    if (_statusFilter == null) return requests;
    return requests.where((r) => r.status == _statusFilter).toList();
  }

  int _countOrganByStatus(List<OrganRequestEntity> requests, String status) {
    return requests.where((r) => r.status == status).length;
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year}  $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(bloodRequestViewModelProvider);
    final organState = ref.watch(organRequestViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final hospitalName = _currentHospital?.name ??
      '${authState.authEntity?.firstName ?? ''} ${authState.authEntity?.lastName ?? ''}'
        .trim();

    ref.listen<BloodRequestState>(bloodRequestViewModelProvider, (
      previous,
      next,
    ) {
      if (next.successMessage != null && next.successMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(bloodRequestViewModelProvider.notifier).clearMessages();
      }
      if (next.status == BloodRequestStatus.error &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

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
        title: Text(
          hospitalName.isEmpty ? 'Donation Requests' : hospitalName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Blood'),
                    selected: _requestType == 'blood',
                    onSelected: (_) => setState(() => _requestType = 'blood'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Organ'),
                    selected: _requestType == 'organ',
                    onSelected: (_) => setState(() => _requestType = 'organ'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _buildFilterChip('All', null),
                _buildFilterChip('Pending', 'pending'),
                _buildFilterChip('Approved', 'approved'),
                _buildFilterChip('Fulfilled', 'fulfilled'),
                _buildFilterChip('Rejected', 'rejected'),
              ],
            ),
          ),
          Expanded(
            child: _requestType == 'blood'
                ? _buildBody(requestState)
                : _buildOrganBody(organState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _requestType == 'blood'
            ? _showCreateBloodRequestDialog
            : _showCreateOrganRequestDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsRow(List<BloodRequestEntity> requests) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          _buildStatCard(
            'Pending',
            _countByStatus(requests, 'pending'),
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Approved',
            _countByStatus(requests, 'approved'),
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Fulfilled',
            _countByStatus(requests, 'fulfilled'),
            Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Rejected',
            _countByStatus(requests, 'rejected'),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganStatsRow(List<OrganRequestEntity> requests) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          _buildStatCard(
            'Pending',
            _countOrganByStatus(requests, 'pending'),
            Colors.orange,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Approved',
            _countOrganByStatus(requests, 'approved'),
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Fulfilled',
            _countOrganByStatus(requests, 'fulfilled'),
            Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            'Rejected',
            _countOrganByStatus(requests, 'rejected'),
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _statusFilter = isSelected ? null : status);
        },
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildBody(BloodRequestState requestState) {
    if (requestState.status == BloodRequestStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (requestState.status == BloodRequestStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              requestState.errorMessage ?? 'Failed to load requests',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filterRequests(requestState.requests);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              _statusFilter != null
                  ? 'No $_statusFilter requests'
                  : 'No donation requests yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              'Donation requests from donors will appear here',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () async => _loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildRequestCard(filtered[index]),
      ),
    );
  }

  Widget _buildRequestCard(BloodRequestEntity request) {
    final statusColor = _statusColor(request.status);

    return GestureDetector(
      onTap: () => _showRequestSummary(request),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      request.bloodType,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.patientName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request.unitsRequested} unit(s) requested',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(request.status),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        request.status[0].toUpperCase() +
                            request.status.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildInfoChip(
                  Icons.calendar_today,
                  'Created: ${_formatDate(request.createdAt)}',
                ),
                if (request.scheduledAt != null) ...[
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.event,
                    'Scheduled: ${_formatDate(request.scheduledAt)}',
                  ),
                ],
              ],
            ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.notes!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (request.status == 'pending') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 4,
                  children: [
                  TextButton.icon(
                    onPressed: () => _quickApprove(request),
                    icon: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.green,
                    ),
                    label: const Text(
                      'Approve',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _quickReject(request),
                    icon: const Icon(Icons.close, size: 16, color: Colors.red),
                    label: const Text(
                      'Reject',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _deleteBloodRequest(request),
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ],
              ),
              ),
            ] else if (request.status == 'approved') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showScheduleDatePicker(request),
                      icon: const Icon(
                        Icons.edit_calendar,
                        size: 16,
                        color: Colors.blue,
                      ),
                      label: const Text(
                        'Edit Date',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _markBloodAsFulfilled(request),
                      icon: const Icon(Icons.task_alt,
                          size: 16, color: Colors.teal),
                      label: const Text(
                        'Fulfilled',
                        style: TextStyle(fontSize: 12, color: Colors.teal),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteBloodRequest(request),
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _deleteBloodRequest(request),
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  void _showRequestSummary(BloodRequestEntity request) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _detailRow('Donor', request.patientName),
              _detailRow('Hospital', request.hospitalName),
              _detailRow('Blood Type', request.bloodType),
              _detailRow('Units', '${request.unitsRequested} unit(s)'),
              _detailRow(
                'Status',
                request.status[0].toUpperCase() + request.status.substring(1),
              ),
              _detailRow('Created', _formatDate(request.createdAt)),
              _detailRow('Scheduled', _formatDate(request.scheduledAt)),
              if (request.contactPhone != null && request.contactPhone!.isNotEmpty)
                _detailRow('Phone', request.contactPhone!),
              if (request.notes != null && request.notes!.isNotEmpty)
                _detailRow('Notes', request.notes!),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<HospitalEntity?> _resolveHospitalForActions() async {
    if (_currentHospital != null) return _currentHospital;
    final resolved = await _resolveCurrentHospital();
    if (mounted) {
      setState(() {
        _currentHospital = resolved;
      });
    }
    return resolved;
  }

  Future<void> _openReport(String reportUrl) async {
    final lower = reportUrl.toLowerCase();
    final isImage = lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');

    if (isImage) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Uploaded Report'),
            content: SizedBox(
              width: 320,
              height: 420,
              child: InteractiveViewer(
                child: Image.network(
                  reportUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return const Center(
                      child: Text('Unable to load image preview'),
                    );
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => _copyReportLink(reportUrl),
                child: const Text('Copy Link'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Report Link'),
          content: Text(reportUrl),
          actions: [
            TextButton(
              onPressed: () => _copyReportLink(reportUrl),
              child: const Text('Copy Link'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyReportLink(String reportUrl) async {
    await Clipboard.setData(ClipboardData(text: reportUrl));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report link copied')),
      );
    }
  }

  Future<void> _showCreateBloodRequestDialog() async {
    final auth = ref.read(authViewModelProvider).authEntity;
    final hospital = await _resolveHospitalForActions();

    if (!mounted) return;
    if (hospital?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hospital profile not found for this account')),
      );
      return;
    }

    final donorController = TextEditingController();
    final unitController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();
    String bloodType = 'A+';
    final List<DropdownMenuItem<String>> bloodTypeItems = [];
    const bloodTypeOptions = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    for (final type in bloodTypeOptions) {
      bloodTypeItems.add(
        DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Blood Request'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: donorController,
                      decoration: const InputDecoration(labelText: 'Donor Name'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: bloodType,
                      decoration: const InputDecoration(labelText: 'Blood Type'),
                      items: bloodTypeItems,
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          bloodType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: unitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Units'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration:
                          const InputDecoration(labelText: 'Contact Phone (optional)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final donorName = donorController.text.trim();
                    final units = int.tryParse(unitController.text.trim());
                    if (donorName.isEmpty || units == null || units <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter donor name and a valid unit count'),
                        ),
                      );
                      return;
                    }

                    final request = BloodRequestEntity(
                      hospitalId: hospital!.id,
                      hospitalName: hospital.name,
                      patientName: donorName,
                      bloodType: bloodType,
                      unitsRequested: units,
                      requestedBy: auth?.authId,
                      contactPhone: phoneController.text.trim().isEmpty
                          ? null
                          : phoneController.text.trim(),
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                    );

                    final success = await ref
                        .read(bloodRequestViewModelProvider.notifier)
                        .createRequest(request);

                    if (!mounted) return;
                    if (success) {
                      Navigator.pop(dialogContext);
                      await _loadRequests();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateOrganRequestDialog() async {
    final auth = ref.read(authViewModelProvider).authEntity;
    final hospital = await _resolveHospitalForActions();

    if (!mounted) return;
    if (hospital?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hospital profile not found for this account')),
      );
      return;
    }

    final donorController = TextEditingController();
    final notesController = TextEditingController();
    File? selectedReport;
    String? selectedReportName;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Organ Request'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: donorController,
                      decoration: const InputDecoration(labelText: 'Donor Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        );

                        if (result == null || result.files.single.path == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedReport = File(result.files.single.path!);
                          selectedReportName = result.files.single.name;
                        });
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(selectedReportName ?? 'Upload Report'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final donorName = donorController.text.trim();
                    if (donorName.isEmpty || selectedReport == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter donor name and upload report file'),
                        ),
                      );
                      return;
                    }

                    final success = await ref
                        .read(organRequestViewModelProvider.notifier)
                        .createRequest(
                          hospitalId: hospital!.id!,
                          hospitalName: hospital.name,
                          donorName: donorName,
                          reportFile: selectedReport!,
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                          requestedBy: auth?.authId,
                        );

                    if (!mounted) return;
                    if (success) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Organ donation request created successfully'),
                        ),
                      );
                      await _loadRequests();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteBloodRequest(BloodRequestEntity request) async {
    if (request.id == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text('Delete donation request for ${request.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final success = await ref
        .read(bloodRequestViewModelProvider.notifier)
        .deleteRequest(request.id!);

    if (success && mounted) {
      await _loadRequests();
    }
  }

  Future<void> _markBloodAsFulfilled(BloodRequestEntity request) async {
    if (request.id == null) return;
    final updated = BloodRequestEntity(
      id: request.id,
      hospitalId: request.hospitalId,
      hospitalName: request.hospitalName,
      patientName: request.patientName,
      bloodType: request.bloodType,
      unitsRequested: request.unitsRequested,
      status: 'fulfilled',
      requestedBy: request.requestedBy,
      contactPhone: request.contactPhone,
      neededBy: request.neededBy,
      scheduledAt: request.scheduledAt,
      notes: request.notes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );

    await ref
        .read(bloodRequestViewModelProvider.notifier)
        .updateRequest(request.id!, updated);
    if (mounted) {
      await _loadRequests();
    }
  }

  void _showOrganRequestSummary(OrganRequestEntity request) {
    final reportUrl = request.reportUrl == null
        ? null
        : ApiEndpoints.fullImageUrl(request.reportUrl!);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Organ Request Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _detailRow('Donor', request.donorName),
              _detailRow('Hospital', request.hospitalName),
              _detailRow(
                'Status',
                request.status[0].toUpperCase() + request.status.substring(1),
              ),
              _detailRow('Created', _formatDate(request.createdAt)),
              _detailRow('Scheduled', _formatDateTime(request.scheduledAt)),
              if (request.notes != null && request.notes!.isNotEmpty)
                _detailRow('Notes', request.notes!),
              if (reportUrl != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _openReport(reportUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Uploaded Report'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _quickApprove(BloodRequestEntity request) {
    _showScheduleDatePicker(request);
  }

  void _quickReject(BloodRequestEntity request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Request'),
        content: Text('Reject donation request from ${request.patientName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final updated = BloodRequestEntity(
                id: request.id,
                hospitalId: request.hospitalId,
                hospitalName: request.hospitalName,
                patientName: request.patientName,
                bloodType: request.bloodType,
                unitsRequested: request.unitsRequested,
                status: 'rejected',
                requestedBy: request.requestedBy,
                contactPhone: request.contactPhone,
                neededBy: request.neededBy,
                scheduledAt: request.scheduledAt,
                notes: request.notes,
              );
              await ref
                  .read(bloodRequestViewModelProvider.notifier)
                  .updateRequest(request.id!, updated);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showScheduleDatePicker(BloodRequestEntity request) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          request.scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'Select donation date for ${request.patientName}',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final initialTime = request.scheduledAt != null
          ? TimeOfDay(
              hour: request.scheduledAt!.hour,
              minute: request.scheduledAt!.minute,
            )
          : const TimeOfDay(hour: 10, minute: 0);

      final time = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (time == null) return;

      final scheduledAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time.hour,
        time.minute,
      );

      final updated = BloodRequestEntity(
        id: request.id,
        hospitalId: request.hospitalId,
        hospitalName: request.hospitalName,
        patientName: request.patientName,
        bloodType: request.bloodType,
        unitsRequested: request.unitsRequested,
        status: 'approved',
        requestedBy: request.requestedBy,
        contactPhone: request.contactPhone,
        neededBy: request.neededBy,
        scheduledAt: scheduledAt,
        notes: request.notes,
      );
      await ref
          .read(bloodRequestViewModelProvider.notifier)
          .updateRequest(request.id!, updated);
    }
  }

  Widget _buildOrganBody(OrganRequestState state) {
    if (state.status == OrganRequestStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (state.status == OrganRequestStatus.error && state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              state.errorMessage ?? 'Failed to load organ requests',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadRequests,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final filtered = _filterOrganRequests(state.requests);
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          _statusFilter != null
              ? 'No $_statusFilter organ requests'
              : 'No organ requests yet',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () async => _loadRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildOrganRequestCard(filtered[index]),
      ),
    );
  }

  Widget _buildOrganRequestCard(OrganRequestEntity request) {
    final statusColor = _statusColor(request.status);
    final reportUrl = request.reportUrl == null
        ? null
        : ApiEndpoints.fullImageUrl(request.reportUrl!);

    return GestureDetector(
      onTap: () => _showOrganRequestSummary(request),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    request.donorName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request.status[0].toUpperCase() + request.status.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildInfoChip(Icons.calendar_today, _formatDate(request.createdAt)),
                _buildInfoChip(
                  Icons.event,
                  request.scheduledAt != null
                      ? 'Scheduled: ${_formatDateTime(request.scheduledAt)}'
                      : 'Not scheduled',
                ),
              ],
            ),
            if (request.reportUrl != null && reportUrl != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _openReport(reportUrl),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  'View uploaded report',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.notes!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (request.status == 'pending') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () => _approveOrganWithDate(request),
                      icon: const Icon(Icons.check, size: 16, color: Colors.green),
                      label: const Text(
                        'Approve',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _rejectOrgan(request),
                      icon: const Icon(Icons.close, size: 16, color: Colors.red),
                      label: const Text(
                        'Reject',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteOrganRequest(request),
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (request.status == 'approved') ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 4,
                  children: [
                    TextButton.icon(
                      onPressed: () => _approveOrganWithDate(request),
                      icon:
                          const Icon(Icons.edit_calendar, size: 16, color: Colors.blue),
                      label: const Text(
                        'Edit Date',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _markOrganAsFulfilled(request),
                      icon:
                          const Icon(Icons.task_alt, size: 16, color: Colors.teal),
                      label: const Text(
                        'Fulfilled',
                        style: TextStyle(fontSize: 12, color: Colors.teal),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteOrganRequest(request),
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _deleteOrganRequest(request),
                  icon: const Icon(Icons.delete_outline,
                      size: 16, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _approveOrganWithDate(OrganRequestEntity request) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate:
          request.scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate == null) return;

    final initialTime = request.scheduledAt != null
        ? TimeOfDay(
            hour: request.scheduledAt!.hour,
            minute: request.scheduledAt!.minute,
          )
        : const TimeOfDay(hour: 10, minute: 0);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) return;

    final scheduledAt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    final updated = OrganRequestEntity(
      id: request.id,
      hospitalId: request.hospitalId,
      hospitalName: request.hospitalName,
      donorName: request.donorName,
      requestedBy: request.requestedBy,
      reportUrl: request.reportUrl,
      status: 'approved',
      scheduledAt: scheduledAt,
      notes: request.notes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );

    await ref
        .read(organRequestViewModelProvider.notifier)
        .updateRequest(request.id!, updated);
  }

  Future<void> _rejectOrgan(OrganRequestEntity request) async {
    final updated = OrganRequestEntity(
      id: request.id,
      hospitalId: request.hospitalId,
      hospitalName: request.hospitalName,
      donorName: request.donorName,
      requestedBy: request.requestedBy,
      reportUrl: request.reportUrl,
      status: 'rejected',
      scheduledAt: request.scheduledAt,
      notes: request.notes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );

    await ref
        .read(organRequestViewModelProvider.notifier)
        .updateRequest(request.id!, updated);
  }

  Future<void> _markOrganAsFulfilled(OrganRequestEntity request) async {
    if (request.id == null) return;

    final updated = OrganRequestEntity(
      id: request.id,
      hospitalId: request.hospitalId,
      hospitalName: request.hospitalName,
      donorName: request.donorName,
      requestedBy: request.requestedBy,
      reportUrl: request.reportUrl,
      status: 'fulfilled',
      scheduledAt: request.scheduledAt,
      notes: request.notes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );

    await ref
        .read(organRequestViewModelProvider.notifier)
        .updateRequest(request.id!, updated);
    if (mounted) {
      await _loadRequests();
    }
  }

  Future<void> _deleteOrganRequest(OrganRequestEntity request) async {
    if (request.id == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text('Delete organ request for ${request.donorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final success = await ref
        .read(organRequestViewModelProvider.notifier)
        .deleteRequest(request.id!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organ request deleted successfully')),
      );
      await _loadRequests();
    }
  }
}

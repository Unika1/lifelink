import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/pages/create_organ_request_screen.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class MyOrganRequestsScreen extends ConsumerStatefulWidget {
  const MyOrganRequestsScreen({super.key});

  @override
  ConsumerState<MyOrganRequestsScreen> createState() =>
      _MyOrganRequestsScreenState();
}

class _MyOrganRequestsScreenState extends ConsumerState<MyOrganRequestsScreen> {
  String? _statusFilter;
  static const List<String> _statusFilters = [
    'pending',
    'approved',
    'rejected',
    'fulfilled',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _refreshRequests());
  }

  Future<void> _editRequest(OrganRequestEntity request) async {
    if (request.id == null) return;

    final notesController = TextEditingController(text: request.notes ?? '');
    File? updatedReportFile;
    String? updatedReportFileName;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Edit Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Update your notes',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        allowMultiple: false,
                      );

                      if (result != null && result.files.single.path != null) {
                        setDialogState(() {
                          updatedReportFile = File(result.files.single.path!);
                          updatedReportFileName = result.files.single.name;
                        });
                      }
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      updatedReportFileName == null
                          ? 'Replace report file (optional)'
                          : 'Selected: $updatedReportFileName',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (shouldSave != true) return;

    final updated = OrganRequestEntity(
      id: request.id,
      hospitalId: request.hospitalId,
      hospitalName: request.hospitalName,
      donorName: request.donorName,
      requestedBy: request.requestedBy,
      reportUrl: request.reportUrl,
      status: request.status,
      scheduledAt: request.scheduledAt,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );

    final success = await ref
        .read(organRequestViewModelProvider.notifier)
        .updateRequest(request.id!, updated, reportFile: updatedReportFile);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Organ request updated')));
      _refreshRequests();
    }
  }

  Future<void> _deleteRequest(OrganRequestEntity request) async {
    if (request.id == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text(
          'Are you sure you want to delete this organ request?',
        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Organ request deleted')));
      _refreshRequests();
    }
  }

  void _refreshRequests() {
    final userId = ref.read(authViewModelProvider).authEntity?.authId;
    ref
        .read(organRequestViewModelProvider.notifier)
        .getAllRequests(requestedBy: userId);
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
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year}  $hour:$minute $period';
  }

  List<OrganRequestEntity> _filterRequests(List<OrganRequestEntity> requests) {
    if (_statusFilter == null) return requests;
    return requests.where((r) => r.status == _statusFilter).toList();
  }

  Future<void> _openReport(String reportUrl) async {
    final lower = reportUrl.toLowerCase();
    final isImage =
        lower.endsWith('.png') ||
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
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Report link copied')));
  }

  Widget _buildStatusFilterChips() {
    final List<Widget> chips = [];

    chips.add(
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: const Text('All'),
          selected: _statusFilter == null,
          onSelected: (_) {
            setState(() => _statusFilter = null);
          },
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.primaryColor,
        ),
      ),
    );

    for (final status in _statusFilters) {
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            label: Text(status[0].toUpperCase() + status.substring(1)),
            selected: _statusFilter == status,
            onSelected: (_) {
              setState(() {
                _statusFilter = _statusFilter == status ? null : status;
              });
            },
            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.primaryColor,
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: chips,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(organRequestViewModelProvider);

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
        title: const Text('My Organ Donation Requests'),
        elevation: 2,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusFilterChips(),
          Expanded(child: _buildBody(requestState)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateOrganRequestScreen()),
          );
          _refreshRequests();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(OrganRequestState requestState) {
    if (requestState.status == OrganRequestStatus.loading &&
        requestState.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (requestState.status == OrganRequestStatus.error &&
        requestState.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load requests'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _refreshRequests,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredRequests = _filterRequests(requestState.requests);

    if (filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              _statusFilter == null
                  ? 'No organ donation requests yet'
                  : 'No $_statusFilter organ donation requests',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first organ donation request',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshRequests(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRequests.length,
        itemBuilder: (context, index) {
          final request = filteredRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(OrganRequestEntity request) {
    final statusColor = _statusColor(request.status);
    final statusIcon = _statusIcon(request.status);
    final reportUrl = request.reportUrl == null
        ? null
        : ApiEndpoints.fullImageUrl(request.reportUrl!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to detail screen
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Hospital name and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.hospitalName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Donor: ${request.donorName}',
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
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          request.status.toUpperCase(),
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
              if (request.notes != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Footer: Created date and report indicator
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (request.scheduledAt != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.event, size: 14, color: Colors.green.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Scheduled: ${_formatDateTime(request.scheduledAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (request.reportUrl != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Report Uploaded',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
              if (request.status == 'pending') ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _editRequest(request),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: () => _deleteRequest(request),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/eligibility/presentation/pages/eligibility_questionnaire_screen.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/theme/app_theme.dart';

class HospitalDetailScreen extends ConsumerStatefulWidget {
  final String hospitalId;

  const HospitalDetailScreen({super.key, required this.hospitalId});

  @override
  ConsumerState<HospitalDetailScreen> createState() =>
      _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends ConsumerState<HospitalDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(hospitalViewModelProvider.notifier)
          .getHospitalById(widget.hospitalId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hospitalState = ref.watch(hospitalViewModelProvider);
    final hospital = hospitalState.selectedHospital;

    return Scaffold(
      appBar: AppBar(
        title: Text(hospital?.name ?? 'Hospital Details'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: _buildBody(hospitalState, hospital),
    );
  }

  Widget _buildBody(HospitalState hospitalState, HospitalEntity? hospital) {
    if (hospitalState.status == HospitalStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (hospitalState.status == HospitalStatus.error || hospital == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              hospitalState.errorMessage ?? 'Hospital not found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(hospitalViewModelProvider.notifier)
                    .getHospitalById(widget.hospitalId);
              },
              icon: const Icon(Icons.refresh),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxContentWidth = constraints.maxWidth > 900
            ? 900.0
            : constraints.maxWidth;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(hospital),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Contact Information'),
                  const SizedBox(height: 10),
                  _buildInfoCard(hospital),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Blood Inventory'),
                  const SizedBox(height: 10),
                  _buildBloodInventoryGrid(hospital.bloodInventory),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EligibilityQuestionnaireScreen(
                              hospitalId: hospital.id,
                              hospitalName: hospital.name,
                              requestType: 'blood',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bloodtype),
                      label: const Text(
                        'Request Donation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(HospitalEntity hospital) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: hospital.imageUrl != null && hospital.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      ApiEndpoints.fullImageUrl(hospital.imageUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_hospital,
                        color: AppTheme.primaryColor,
                        size: 40,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.local_hospital,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            hospital.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hospital.address.fullAddress,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: hospital.isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hospital.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hospital.isActive ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(HospitalEntity hospital) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Email', hospital.email),
          const Divider(height: 20),
          _buildInfoRow(Icons.phone, 'Phone', hospital.phoneNumber),
          if (hospital.licenseNumber != null &&
              hospital.licenseNumber!.isNotEmpty) ...[
            const Divider(height: 20),
            _buildInfoRow(Icons.badge, 'License', hospital.licenseNumber!),
          ],
          const Divider(height: 20),
          _buildInfoRow(
            Icons.location_city,
            'Address',
            hospital.address.fullAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textColor,
      ),
    );
  }

  Widget _buildBloodInventoryGrid(List<BloodInventoryEntity> inventory) {
    if (inventory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No blood inventory data available',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth >= 780) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth < 460) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: inventory.length,
          itemBuilder: (context, index) {
            final blood = inventory[index];
            final hasStock = blood.unitsAvailable > 0;

            return Container(
              decoration: BoxDecoration(
                color: hasStock
                    ? AppTheme.primaryColor.withValues(alpha: 0.08)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasStock
                      ? AppTheme.primaryColor.withValues(alpha: 0.3)
                      : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bloodtype,
                    color: hasStock
                        ? AppTheme.primaryColor
                        : Colors.grey.shade400,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blood.bloodType,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: hasStock
                          ? AppTheme.primaryColor
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${blood.unitsAvailable} units',
                    style: TextStyle(
                      fontSize: 11,
                      color: hasStock
                          ? AppTheme.textColor
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

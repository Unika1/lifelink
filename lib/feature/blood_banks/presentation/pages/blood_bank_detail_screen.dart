import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/presentation/state/blood_bank_state.dart';
import 'package:lifelink/feature/blood_banks/presentation/view_model/blood_bank_viewmodel.dart';
import 'package:lifelink/feature/eligibility/presentation/pages/eligibility_questionnaire_screen.dart';
import 'package:lifelink/theme/app_theme.dart';

class BloodBankDetailScreen extends ConsumerStatefulWidget {
  final String bloodBankId;

  const BloodBankDetailScreen({super.key, required this.bloodBankId});

  @override
  ConsumerState<BloodBankDetailScreen> createState() =>
      _BloodBankDetailScreenState();
}

class _BloodBankDetailScreenState extends ConsumerState<BloodBankDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(bloodBankViewModelProvider.notifier)
          .getBloodBankById(widget.bloodBankId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bloodBankState = ref.watch(bloodBankViewModelProvider);
    final bloodBank = bloodBankState.selectedBloodBank;

    return Scaffold(
      appBar: AppBar(
        title: Text(bloodBank?.name ?? 'Blood Bank Details'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: _buildBody(bloodBankState, bloodBank),
    );
  }

  Widget _buildBody(BloodBankState bloodBankState, BloodBankEntity? bloodBank) {
    if (bloodBankState.status == BloodBankStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (bloodBankState.status == BloodBankStatus.error || bloodBank == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              bloodBankState.errorMessage ?? 'Blood bank not found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(bloodBankViewModelProvider.notifier)
                    .getBloodBankById(widget.bloodBankId);
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

    final isExternalSource = bloodBank.id?.startsWith('osm_') ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(bloodBank),
          const SizedBox(height: 20),
          _buildSectionTitle('Contact Information'),
          const SizedBox(height: 10),
          _buildInfoCard(bloodBank),
          const SizedBox(height: 20),
          _buildSectionTitle('Blood Inventory'),
          const SizedBox(height: 10),
          _buildBloodInventoryGrid(bloodBank.bloodInventory),
          const SizedBox(height: 24),
          if (!isExternalSource)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EligibilityQuestionnaireScreen(
                        hospitalId: bloodBank.id,
                        hospitalName: bloodBank.name,
                        requestType: 'blood',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.bloodtype),
                label: const Text(
                  'Request Blood',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Text(
                'This is a real map location. Request blood is available only for registered LifeLink hospitals.',
                style: TextStyle(fontSize: 13, color: Colors.blueGrey),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BloodBankEntity bloodBank) {
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
            child: bloodBank.imageUrl != null && bloodBank.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      ApiEndpoints.fullImageUrl(bloodBank.imageUrl!),
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
            bloodBank.name,
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
                  bloodBank.address.fullAddress,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BloodBankEntity bloodBank) {
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
          _buildInfoRow(Icons.email, 'Email', bloodBank.email),
          const Divider(height: 20),
          _buildInfoRow(Icons.phone, 'Phone', bloodBank.phoneNumber),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.location_city,
            'Address',
            bloodBank.address.fullAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final safeValue = value.trim().isEmpty ? 'Not available' : value;

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
                safeValue,
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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
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
                color:
                    hasStock ? AppTheme.primaryColor : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                blood.bloodType,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: hasStock ? AppTheme.primaryColor : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${blood.unitsAvailable} units',
                style: TextStyle(
                  fontSize: 11,
                  color: hasStock ? AppTheme.textColor : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

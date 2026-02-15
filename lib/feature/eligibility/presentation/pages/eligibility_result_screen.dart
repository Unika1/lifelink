import 'package:flutter/material.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/pages/blood_request_form_page.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/pages/create_organ_request_screen.dart';
import 'package:lifelink/theme/app_theme.dart';

class EligibilityResultScreen extends StatelessWidget {
  final EligibilityResultEntity? result;
  final bool isEligible;
  final String? hospitalId;
  final String? hospitalName;
  final String requestType;

  const EligibilityResultScreen({
    super.key,
    required this.result,
    required this.isEligible,
    this.hospitalId,
    this.hospitalName,
    this.requestType = 'blood',
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eligibility Result'),
        elevation: 2,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Result icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isEligible
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEligible ? Icons.check_circle : Icons.cancel,
                size: 60,
                color: isEligible ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              isEligible ? 'You are Eligible!' : 'Not Eligible',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isEligible ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEligible
                  ? 'You can proceed to submit a donation request.'
                  : 'You cannot donate blood at this time.',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (result != null) ...[
              const SizedBox(height: 24),
              // Score card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                  children: [
                    Text('Eligibility Score',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500)),
                    const SizedBox(height: 8),
                    Text(
                      '${result!.score}/100',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: result!.score >= 70
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: result!.score / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          result!.score >= 70 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Reasons (if not eligible)
              if (result!.reasons.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber,
                              size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Reasons',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...result!.reasons.map((reason) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14)),
                                Expanded(
                                  child: Text(reason,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.red.shade700)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
              // Next eligible date
              if (result!.nextEligibleDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'You may be eligible after ${_formatDate(result!.nextEligibleDate)}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 32),
            // Action button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  if (isEligible) {
                    if (requestType == 'organ') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateOrganRequestScreen(
                            hospitalId: hospitalId,
                            hospitalName: hospitalName,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BloodRequestFormPage(
                            hospitalId: hospitalId,
                            hospitalName: hospitalName,
                          ),
                        ),
                      );
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isEligible ? AppTheme.primaryColor : Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isEligible ? 'Proceed to Request' : 'Go Back',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

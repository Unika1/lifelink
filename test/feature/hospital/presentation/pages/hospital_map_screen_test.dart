import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/hospital/presentation/pages/hospital_map_screen.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';

void main() {
  testWidgets('BloodDonationRequestsUi shows empty-state message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BloodDonationRequestsUi(
            state: BloodRequestState(status: BloodRequestStatus.initial),
            requests: [],
            statusFilter: null,
          ),
        ),
      ),
    );

    expect(find.text('No blood requests yet'), findsOneWidget);
  });

  testWidgets('OrganDonationRequestsUi renders request details', (
    tester,
  ) async {
    final requests = [
      OrganRequestEntity(
        id: 'organ-1',
        hospitalId: 'hospital-1',
        hospitalName: 'City Hospital',
        donorName: 'Sita Sharma',
        requestedBy: 'Admin',
        status: 'pending',
        scheduledAt: DateTime(2026, 2, 20),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrganDonationRequestsUi(
            state: const OrganRequestState(status: OrganRequestStatus.loaded),
            requests: requests,
            statusFilter: null,
          ),
        ),
      ),
    );

    expect(find.text('Sita Sharma'), findsOneWidget);
    expect(find.textContaining('Requested by: Admin'), findsOneWidget);
    expect(find.textContaining('Scheduled at:'), findsOneWidget);
  });

  testWidgets('BloodDonationRequestsUi renders blood request details', (
    tester,
  ) async {
    final requests = [
      BloodRequestEntity(
        id: 'blood-1',
        hospitalId: 'hospital-1',
        hospitalName: 'City Hospital',
        patientName: 'Ram Kumar',
        bloodType: 'A+',
        unitsRequested: 2,
        status: 'approved',
        neededBy: DateTime(2026, 2, 18),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BloodDonationRequestsUi(
            state: const BloodRequestState(status: BloodRequestStatus.loaded),
            requests: requests,
            statusFilter: null,
          ),
        ),
      ),
    );

    expect(find.text('Ram Kumar'), findsOneWidget);
    expect(find.text('Blood Type: A+'), findsOneWidget);
    expect(find.text('Units: 2'), findsOneWidget);
  });

  testWidgets('BloodDonationRequestsUi shows loading indicator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BloodDonationRequestsUi(
            state: BloodRequestState(status: BloodRequestStatus.loading),
            requests: [],
            statusFilter: null,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('OrganDonationRequestsUi shows empty filtered state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrganDonationRequestsUi(
            state: OrganRequestState(status: OrganRequestStatus.loaded),
            requests: [],
            statusFilter: 'approved',
          ),
        ),
      ),
    );

    expect(find.text('No matching organ requests'), findsOneWidget);
  });
}
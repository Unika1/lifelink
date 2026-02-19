import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/view_model/blood_request_view_model.dart';
import 'package:lifelink/feature/home/presentation/pages/dashboard_screen.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';

Widget _buildTestApp() {
  return ProviderScope(
    overrides: [
      bloodRequestViewModelProvider.overrideWith(
        _FakeBloodRequestViewModel.new,
      ),
      organRequestViewModelProvider.overrideWith(
        _FakeOrganRequestViewModel.new,
      ),
    ],
    child: const MaterialApp(home: DashboardScreen()),
  );
}

class _FakeBloodRequestViewModel extends BloodRequestViewModel {
  @override
  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? filterStatus,
  }) async {}

  @override
  BloodRequestState build() {
    return BloodRequestState(
      status: BloodRequestStatus.loaded,
      requests: [
        BloodRequestEntity(
          id: 'blood-1',
          hospitalName: 'City Hospital',
          patientName: 'Patient A',
          bloodType: 'A+',
          unitsRequested: 2,
          status: 'approved',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ],
    );
  }
}

class _FakeOrganRequestViewModel extends OrganRequestViewModel {
  @override
  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {}

  @override
  OrganRequestState build() {
    return OrganRequestState(
      status: OrganRequestStatus.loaded,
      requests: [
        OrganRequestEntity(
          id: 'organ-1',
          hospitalName: 'Metro Hospital',
          donorName: 'Donor B',
          status: 'pending',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    );
  }
}

void main() {
  testWidgets('renders dashboard with sidebar navigation', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.text('LifeLink Donor'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Request'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });

  testWidgets('renders scaffold', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('has navigation labels visible', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Request'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });

  testWidgets('dashboard remains stable after pumpAndSettle', (tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('opens notifications dialog from bell icon', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}

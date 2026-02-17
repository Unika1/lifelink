import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/view_model/blood_request_view_model.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/pages/hospital_requests_screen.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';

class FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      authEntity: AuthEntity(
        authId: 'user-1',
        firstName: 'City',
        lastName: 'Hospital',
        email: 'city@hospital.com',
        role: 'hospital',
      ),
    );
  }
}

class FakeHospitalViewModel extends HospitalViewModel {
  @override
  HospitalState build() {
    return HospitalState(
      status: HospitalStatus.loaded,
      hospitals: [
        HospitalEntity(
          id: 'hospital-1',
          userId: 'user-1',
          name: 'City Hospital',
          email: 'city@hospital.com',
          phoneNumber: '9800000000',
          address: const HospitalAddressEntity(
            street: 'Main St',
            city: 'Kathmandu',
            state: 'Bagmati',
            zipCode: '44600',
          ),
        ),
      ],
    );
  }

  @override
  Future<void> getAllHospitals({
    String? city,
    String? filterState,
    String? bloodType,
    bool? isActive,
  }) async {}
}

class FakeBloodRequestViewModel extends BloodRequestViewModel {
  @override
  BloodRequestState build() => const BloodRequestState(status: BloodRequestStatus.loaded);

  @override
  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? filterStatus,
  }) async {}
}

class FakeOrganRequestViewModel extends OrganRequestViewModel {
  @override
  OrganRequestState build() => const OrganRequestState(status: OrganRequestStatus.loaded);

  @override
  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {}
}

void main() {
  testWidgets('HospitalRequestsScreen renders type chips and app title', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          bloodRequestViewModelProvider.overrideWith(
            () => FakeBloodRequestViewModel(),
          ),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: HospitalRequestsScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('City Hospital'), findsOneWidget);
    expect(find.text('Blood'), findsOneWidget);
    expect(find.text('Organ'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('HospitalRequestsScreen switches to organ empty-state view', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          bloodRequestViewModelProvider.overrideWith(
            () => FakeBloodRequestViewModel(),
          ),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: HospitalRequestsScreen()),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Organ'));
    await tester.pumpAndSettle();

    expect(find.text('No organ requests yet'), findsOneWidget);
  });

  testWidgets('HospitalRequestsScreen shows filter chips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          bloodRequestViewModelProvider.overrideWith(
            () => FakeBloodRequestViewModel(),
          ),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: HospitalRequestsScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Fulfilled'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets('HospitalRequestsScreen has add floating action button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          bloodRequestViewModelProvider.overrideWith(
            () => FakeBloodRequestViewModel(),
          ),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: HospitalRequestsScreen()),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('HospitalRequestsScreen contains app bar action icon', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          bloodRequestViewModelProvider.overrideWith(
            () => FakeBloodRequestViewModel(),
          ),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: HospitalRequestsScreen()),
      ),
    );

    await tester.pump();

    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}
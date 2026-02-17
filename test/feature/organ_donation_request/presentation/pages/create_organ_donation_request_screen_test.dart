import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/pages/create_organ_donation_request_screen.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';
import 'package:lifelink/feature/profile/presentation/state/profile_state.dart';
import 'package:lifelink/feature/profile/presentation/view_model/profile_view_model.dart';

class FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState(
      status: AuthStatus.authenticated,
      authEntity: AuthEntity(
        authId: 'user-1',
        firstName: 'Sita',
        lastName: 'Sharma',
        email: 'sita@mail.com',
      ),
    );
  }
}

class FakeProfileViewModel extends ProfileViewModel {
  @override
  ProfileState build() {
    return const ProfileState(
      status: ProfileStatus.loaded,
      firstName: 'Sita',
      lastName: 'Sharma',
      email: 'sita@mail.com',
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

class FakeOrganRequestViewModel extends OrganRequestViewModel {
  @override
  OrganRequestState build() {
    return const OrganRequestState(status: OrganRequestStatus.initial);
  }
}

void main() {
  testWidgets('CreateOrganRequestScreen renders core form UI', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: CreateOrganRequestScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Create Organ Donation Request'), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('CreateOrganRequestScreen shows app bar title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: CreateOrganRequestScreen()),
      ),
    );

    await tester.pump();
    expect(find.text('Create Organ Donation Request'), findsOneWidget);
  });

  testWidgets('CreateOrganRequestScreen renders scaffold', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: CreateOrganRequestScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('CreateOrganRequestScreen includes informational text', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: CreateOrganRequestScreen()),
      ),
    );

    await tester.pump();
    expect(find.textContaining('Upload your health report'), findsOneWidget);
  });

  testWidgets('CreateOrganRequestScreen stays stable after pumpAndSettle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
          hospitalViewModelProvider.overrideWith(() => FakeHospitalViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: CreateOrganRequestScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(Form), findsOneWidget);
  });
}
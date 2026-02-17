import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/pages/blood_request_form_page.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/view_model/blood_request_view_model.dart';
import 'package:lifelink/feature/profile/presentation/state/profile_state.dart';
import 'package:lifelink/feature/profile/presentation/view_model/profile_view_model.dart';

class FakeAuthViewModel extends AuthViewModel {
  final AuthState _state;
  FakeAuthViewModel(this._state);

  @override
  AuthState build() => _state;
}

class FakeProfileViewModel extends ProfileViewModel {
  final ProfileState _state;
  FakeProfileViewModel(this._state);

  @override
  ProfileState build() => _state;
}

class FakeBloodRequestViewModel extends BloodRequestViewModel {
  final BloodRequestState _state;
  FakeBloodRequestViewModel(this._state);

  @override
  BloodRequestState build() => _state;

  @override
  Future<bool> createRequest(BloodRequestEntity request) async => true;

  @override
  Future<bool> updateRequest(String id, BloodRequestEntity request) async => true;

  @override
  Future<bool> deleteRequest(String id) async => true;
}

void main() {
  Widget createWidget({BloodRequestEntity? request}) {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith(
          () => FakeAuthViewModel(
            AuthState(
              status: AuthStatus.authenticated,
              authEntity: AuthEntity(
                authId: 'u-1',
                firstName: 'Donor',
                lastName: 'One',
                email: 'donor@test.com',
              ),
            ),
          ),
        ),
        profileViewModelProvider.overrideWith(
          () => FakeProfileViewModel(
            const ProfileState(
              firstName: 'Donor',
              lastName: 'One',
            ),
          ),
        ),
        bloodRequestViewModelProvider.overrideWith(
          () => FakeBloodRequestViewModel(const BloodRequestState()),
        ),
      ],
      child: MaterialApp(
        home: BloodRequestFormPage(
          request: request,
          hospitalId: 'h-1',
          hospitalName: 'City Hospital',
        ),
      ),
    );
  }

  testWidgets('shows create title when request is null', (tester) async {
    await tester.pumpWidget(createWidget());
    await tester.pump();

    expect(find.text('Create Blood Donation Request'), findsOneWidget);
    expect(find.text('City Hospital'), findsOneWidget);
  });

  testWidgets('shows details title when request is provided', (tester) async {
    final request = BloodRequestEntity(
      id: 'req-1',
      hospitalId: 'h-1',
      hospitalName: 'City Hospital',
      patientName: 'Donor One',
      bloodType: 'A+',
      unitsRequested: 1,
    );

    await tester.pumpWidget(createWidget(request: request));
    await tester.pump();

    expect(find.text('Blood Donation Request Details'), findsOneWidget);
    expect(find.text('Donor One'), findsOneWidget);
  });
}
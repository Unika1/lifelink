import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/pages/my_organ_donation_requests_screen.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';

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

class FakeOrganRequestViewModel extends OrganRequestViewModel {
  @override
  OrganRequestState build() {
    return OrganRequestState(
      status: OrganRequestStatus.loaded,
      requests: const [
        OrganRequestEntity(
          id: 'organ-1',
          hospitalId: 'hospital-1',
          hospitalName: 'City Hospital',
          donorName: 'Sita Sharma',
          requestedBy: 'user-1',
          status: 'pending',
        ),
      ],
    );
  }

  @override
  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {}
}

void main() {
  testWidgets('MyOrganRequestsScreen renders title and request item', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: MyOrganRequestsScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('My Organ Donation Requests'), findsOneWidget);
    expect(find.text('Donor: Sita Sharma'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
  });

  testWidgets('MyOrganRequestsScreen renders scaffold and fab', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: MyOrganRequestsScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('MyOrganRequestsScreen shows status filter chips', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: MyOrganRequestsScreen()),
      ),
    );

    await tester.pump();
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });

  testWidgets('MyOrganRequestsScreen contains refresh icon', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: MyOrganRequestsScreen()),
      ),
    );

    await tester.pump();
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('MyOrganRequestsScreen shows hospital name in card', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          organRequestViewModelProvider.overrideWith(
            () => FakeOrganRequestViewModel(),
          ),
        ],
        child: const MaterialApp(home: MyOrganRequestsScreen()),
      ),
    );

    await tester.pump();
    expect(find.text('City Hospital'), findsOneWidget);
  });
}
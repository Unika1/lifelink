import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/pages/my_requests_screen.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/view_model/blood_request_view_model.dart';
import 'package:mocktail/mocktail.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class FakeAuthViewModel extends AuthViewModel {
  final AuthState _state;
  FakeAuthViewModel(this._state);

  @override
  AuthState build() => _state;
}

class FakeBloodRequestViewModel extends BloodRequestViewModel {
  final BloodRequestState _state;
  FakeBloodRequestViewModel(this._state);

  @override
  BloodRequestState build() => _state;

  @override
  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? filterStatus,
  }) async {}

  @override
  void clearMessages() {}
}

void main() {
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockUserSessionService = MockUserSessionService();
    when(() => mockUserSessionService.getUserId()).thenReturn('u-1');
  });

  Widget createWidget(BloodRequestState state) {
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
        bloodRequestViewModelProvider.overrideWith(
          () => FakeBloodRequestViewModel(state),
        ),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
      child: const MaterialApp(home: MyRequestsScreen()),
    );
  }

  testWidgets('renders title and filter chips', (tester) async {
    await tester.pumpWidget(createWidget(const BloodRequestState()));
    await tester.pump();

    expect(find.text('My Blood Donation Requests'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets('shows request card when data exists', (tester) async {
    final request = BloodRequestEntity(
      id: 'req-1',
      hospitalId: 'h-1',
      hospitalName: 'City Hospital',
      patientName: 'Donor One',
      bloodType: 'A+',
      unitsRequested: 1,
      status: 'pending',
    );

    await tester.pumpWidget(
      createWidget(
        BloodRequestState(
          status: BloodRequestStatus.loaded,
          requests: [request],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('City Hospital'), findsOneWidget);
    expect(find.text('A+'), findsOneWidget);
  });
}
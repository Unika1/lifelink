import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:lifelink/feature/profile/presentation/pages/profile_screen.dart';
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
        bloodGroup: 'A+',
        phoneNumber: '9800000000',
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
      bloodGroup: 'A+',
      phoneNumber: '9800000000',
      emergencyContact: '9700000000',
    );
  }
}

void main() {
  testWidgets('ProfileScreen renders profile sections and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Health & Emergency'), findsOneWidget);
    expect(find.text('Blood Group'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders scaffold', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('ProfileScreen shows phone and emergency labels', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Emergency Contact'), findsOneWidget);
  });

  testWidgets('ProfileScreen contains edit icons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pump();
    expect(find.byIcon(Icons.edit), findsWidgets);
  });

  testWidgets('ProfileScreen remains stable after pumpAndSettle', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => FakeAuthViewModel()),
          profileViewModelProvider.overrideWith(() => FakeProfileViewModel()),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Profile'), findsOneWidget);
  });
}
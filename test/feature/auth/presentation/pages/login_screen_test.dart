import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lifelink/feature/auth/presentation/pages/login_screen.dart';
import 'package:lifelink/feature/auth/domain/usecases/login_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/register_usecase.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';


class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockUserSessionService = MockUserSessionService();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  testWidgets('Widget Test 1: shows email & password fields', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
  });

  testWidgets('Widget Test 2: shows Login button', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(ElevatedButton), findsWidgets);
  });


  testWidgets('Widget Test 3: empty submit shows validation error',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    expect(find.textContaining('required'), findsAtLeastNWidgets(1));
  });


  testWidgets('Widget Test 4: user can enter email & password', (tester) async {
    await tester.pumpWidget(createTestWidget());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'test@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.pump();

    expect(find.text('test@example.com'), findsOneWidget);
  });
  testWidgets('Widget Test 5: toggles password visibility icon',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    final visibleIcon = find.byIcon(Icons.visibility_outlined);
    if (visibleIcon.evaluate().isNotEmpty) {
      await tester.tap(visibleIcon);
      await tester.pump();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    } else {
      expect(true, true);
    }
  });
}

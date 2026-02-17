import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/domain/usecases/change_password_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/login_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/register_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/reset_password_usecase.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:lifelink/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockRequestPasswordResetUsecase extends Mock
    implements RequestPasswordResetUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class MockChangePasswordUsecase extends Mock implements ChangePasswordUsecase {}

class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockRequestPasswordResetUsecase mockRequestPasswordResetUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late MockChangePasswordUsecase mockChangePasswordUsecase;
  late MockUserSessionService mockUserSessionService;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        firstName: 'fallback',
        lastName: 'fallback',
        email: 'fallback@email.com',
        password: 'fallback',
        confirmPassword: 'fallback',
      ),
    );
    registerFallbackValue(
      const LoginUsecaseParams(email: 'fallback@email.com', password: 'fallback'),
    );
    registerFallbackValue(
      const RequestPasswordResetUsecaseParams(email: 'fallback@email.com'),
    );
    registerFallbackValue(
      const ResetPasswordUsecaseParams(token: 'fallbackToken', newPassword: 'fallback'),
    );
    registerFallbackValue(
      const ChangePasswordUsecaseParams(
        currentPassword: 'fallbackCurrent',
        newPassword: 'fallbackNew',
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockRequestPasswordResetUsecase = MockRequestPasswordResetUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
    mockChangePasswordUsecase = MockChangePasswordUsecase();
    mockUserSessionService = MockUserSessionService();

    when(() => mockUserSessionService.setLoggedIn(any(), role: any(named: 'role')))
        .thenAnswer((_) async {});
    when(() => mockUserSessionService.logout()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        requestPasswordResetUsecaseProvider.overrideWithValue(
          mockRequestPasswordResetUsecase,
        ),
        resetPasswordUsecaseProvider.overrideWithValue(mockResetPasswordUsecase),
        changePasswordUsecaseProvider.overrideWithValue(mockChangePasswordUsecase),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final tUser = AuthEntity(
    authId: '1',
    firstName: 'Test',
    lastName: 'User',
    email: 'test@example.com',
  );

  group('AuthViewModel', () {
    test('initial state is correct', () {
      final state = container.read(authViewModelProvider);

      expect(state.status, AuthStatus.initial);
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
      expect(state.message, isNull);
    });

    test('register succeeds and emits registered', () async {
      when(() => mockRegisterUsecase(any())).thenAnswer((_) async => const Right(true));

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.register(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.registered);
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('register fails when passwords do not match', () async {
      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.register(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'differentPassword',
      );

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Passwords do not match');
      verifyNever(() => mockRegisterUsecase(any()));
    });

    test('register failure from usecase emits error', () async {
      const failure = ApiFailure(message: 'Email already exists', statusCode: 409);
      when(() => mockRegisterUsecase(any())).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.register(
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Email already exists');
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('login success stores user and session', () async {
      when(() => mockLoginUsecase(any())).thenAnswer((_) async => Right(tUser));

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: 'test@example.com', password: 'password123');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.authEntity, tUser);
      verify(() => mockLoginUsecase(any())).called(1);
      verify(() => mockUserSessionService.setLoggedIn('1', role: 'donor')).called(1);
    });

    test('login failure emits error and does not save session', () async {
      const failure = ApiFailure(message: 'Invalid credentials', statusCode: 401);
      when(() => mockLoginUsecase(any())).thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: 'test@example.com', password: 'wrong-password');

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid credentials');
      verify(() => mockLoginUsecase(any())).called(1);
      verifyNever(() => mockUserSessionService.setLoggedIn(any(), role: any(named: 'role')));
    });

    test('logout resets auth state and calls session logout', () async {
      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.logout();

      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
      verify(() => mockUserSessionService.logout()).called(1);
    });

    test('requestPasswordReset success emits message state', () async {
      when(() => mockRequestPasswordResetUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      final viewModel = container.read(authViewModelProvider.notifier);
      final result = await viewModel.requestPasswordReset(email: 'test@example.com');

      final state = container.read(authViewModelProvider);
      expect(result, isTrue);
      expect(state.status, AuthStatus.message);
      expect(state.message, 'If the email is registered, a reset link has been sent.');
      verify(() => mockRequestPasswordResetUsecase(any())).called(1);
    });

    test('requestPasswordReset failure emits error state', () async {
      const failure = ApiFailure(message: 'Request failed', statusCode: 500);
      when(() => mockRequestPasswordResetUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(authViewModelProvider.notifier);
      final result = await viewModel.requestPasswordReset(email: 'test@example.com');

      final state = container.read(authViewModelProvider);
      expect(result, isFalse);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Request failed');
      verify(() => mockRequestPasswordResetUsecase(any())).called(1);
    });

    test('resetPassword success emits success message', () async {
      when(() => mockResetPasswordUsecase(any())).thenAnswer((_) async => const Right(true));

      final viewModel = container.read(authViewModelProvider.notifier);
      final result = await viewModel.resetPassword(
        token: 'token-123',
        newPassword: 'newPassword123',
      );

      final state = container.read(authViewModelProvider);
      expect(result, isTrue);
      expect(state.status, AuthStatus.message);
      expect(state.message, 'Password reset successful');
      verify(() => mockResetPasswordUsecase(any())).called(1);
    });

    test('changePassword success emits success message', () async {
      when(() => mockChangePasswordUsecase(any()))
          .thenAnswer((_) async => const Right(true));

      final viewModel = container.read(authViewModelProvider.notifier);
      final result = await viewModel.changePassword(
        currentPassword: 'oldPassword123',
        newPassword: 'newPassword123',
      );

      final state = container.read(authViewModelProvider);
      expect(result, isTrue);
      expect(state.status, AuthStatus.message);
      expect(state.message, 'Password changed successfully');
      verify(() => mockChangePasswordUsecase(any())).called(1);
    });

    test('changePassword failure emits error state', () async {
      const failure = ApiFailure(message: 'Invalid current password', statusCode: 400);
      when(() => mockChangePasswordUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(authViewModelProvider.notifier);
      final result = await viewModel.changePassword(
        currentPassword: 'wrongCurrent',
        newPassword: 'newPassword123',
      );

      final state = container.read(authViewModelProvider);
      expect(result, isFalse);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid current password');
      verify(() => mockChangePasswordUsecase(any())).called(1);
    });
  });

  group('AuthState', () {
    test('copyWith updates only provided fields', () {
      const state = AuthState();

      final updated = state.copyWith(status: AuthStatus.authenticated, authEntity: tUser);

      expect(updated.status, AuthStatus.authenticated);
      expect(updated.authEntity, tUser);
      expect(updated.errorMessage, isNull);
      expect(updated.message, isNull);
    });

    test('equality works with same values', () {
      final state1 = AuthState(status: AuthStatus.authenticated, authEntity: tUser);
      final state2 = AuthState(status: AuthStatus.authenticated, authEntity: tUser);

      expect(state1, state2);
    });
  });
}
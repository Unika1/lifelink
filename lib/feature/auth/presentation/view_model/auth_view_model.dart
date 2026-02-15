import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/auth/domain/usecases/login_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/register_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/reset_password_usecase.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:riverpod/riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final RequestPasswordResetUsecase _requestPasswordResetUsecase;
  late final ResetPasswordUsecase _resetPasswordUsecase;
  late final UserSessionService _userSessionService;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _requestPasswordResetUsecase = ref.read(requestPasswordResetUsecaseProvider);
    _resetPasswordUsecase = ref.read(resetPasswordUsecaseProvider);
    _userSessionService = ref.read(userSessionServiceProvider);
    return AuthState();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Passwords do not match',
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = RegisterUsecaseParams(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    final result = await _registerUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copyWith(status: AuthStatus.registered);
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Registration failed',
          );
        }
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );

    final id = state.authEntity?.authId;
    final role = state.authEntity?.role ?? 'donor';
    if (state.status == AuthStatus.authenticated && id != null && id.isNotEmpty) {
      await _userSessionService.setLoggedIn(id, role: role);
    }
  }

  Future<void> logout() async {
    await _userSessionService.logout();
    state = state.copyWith(
      status: AuthStatus.initial,
      authEntity: null,
      errorMessage: null,
    );
  }

  Future<bool> requestPasswordReset({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, message: null);

    final params = RequestPasswordResetUsecaseParams(email: email);
    final result = await _requestPasswordResetUsecase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.message,
          message: 'If the email is registered, a reset link has been sent.',
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, message: null);

    final params = ResetPasswordUsecaseParams(
      token: token,
      newPassword: newPassword,
    );
    final result = await _resetPasswordUsecase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.message,
          message: 'Password reset successful',
          errorMessage: null,
        );
        return true;
      },
    );
  }
}

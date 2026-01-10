import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/auth/domain/usecases/login_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/register_usecase.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:riverpod/riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final UserSessionService _userSessionService;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _userSessionService = ref.read(userSessionServiceProvider);
    return AuthState();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = state.copywith(status: AuthStatus.loading);

    final params = RegisterUsecaseParams(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    final result = await _registerUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copywith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        if (isRegistered) {
          state = state.copywith(status: AuthStatus.registered);
        } else {
          state = state.copywith(
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
    state = state.copywith(status: AuthStatus.loading);

    final params = LoginUsecaseParams(email: email, password: password);
    final result = await _loginUsecase(params);

    result.fold(
      (failure) {
        state = state.copywith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) async {
        final id = authEntity.authId;
        if (id != null && id.isNotEmpty) {
          await _userSessionService.setLoggedIn(id);
        }

        state = state.copywith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  Future<void> logout() async {
    await _userSessionService.logout();
    state = state.copywith(
      status: AuthStatus.initial,
      authEntity: null,
      errorMessage: null,
    );
  }
}

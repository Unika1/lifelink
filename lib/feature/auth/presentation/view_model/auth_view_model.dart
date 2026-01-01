import 'package:lifelink/feature/auth/domain/usecases/login_usecase.dart';
import 'package:lifelink/feature/auth/domain/usecases/register_usecase.dart';
import 'package:lifelink/feature/auth/presentation/state/auth_state.dart';
import 'package:riverpod/riverpod.dart';

//provider
final authViewModelProvider=NotifierProvider<AuthViewModel,AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState>{
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  @override
  AuthState build() {
    _registerUsecase=ref.read(registerUsecaseProvider);
    _loginUsecase=ref.read(loginUsecaseProvider);
    return AuthState();
  }

  Future<void>register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  })async{
    state=state.copywith(status:AuthStatus.loading);
    final params=RegisterUsecaseParams(
      firstName: firstName, 
      lastName: lastName, 
      email: email, 
      password: password
    );
    final result =await _registerUsecase.call(params);
    result.fold(
      (failure){
        state=state.copywith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered){
        if(isRegistered){
          state=state.copywith(status:AuthStatus.registered);
        }else{
          state=state.copywith(
            status:AuthStatus.error,
            errorMessage: 'Registration failed',
          );
        }
      }
    );
  }
  //login
  Future<void>login({
    required String email,
    required String password,
  })async{
    state=state.copywith(status:AuthStatus.loading);
    final params=LoginUsecaseParams(email: email, password: password);
    final result=await _loginUsecase(params);

    result.fold(
      (failure){
        state=state.copywith(
          status:AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity){
        state=state.copywith(
          status:AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

}
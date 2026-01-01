import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/auth/data/repositories/auth_repository.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:riverpod/riverpod.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({
    required this.email, 
    required this.password,
  });
  @override
  List<Object?> get props => [email,password];
}
//provider 
final loginUsecaseProvider=Provider<LoginUsecase>((ref){
  final authRepository=ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});
class LoginUsecase implements UsecaseWithParams<AuthEntity,LoginUsecaseParams>{
   final IAuthRepository _authReposiory;

   LoginUsecase({required IAuthRepository authRepository})
  :_authReposiory=authRepository;

  @override
  Future<Either<Failure, AuthEntity>>call(LoginUsecaseParams params) {
    return _authReposiory.login(params.email, params.password);
  }
}
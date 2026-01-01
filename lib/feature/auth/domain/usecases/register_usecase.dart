import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/auth/data/repositories/auth_repository.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:riverpod/riverpod.dart';

class RegisterUsecaseParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const RegisterUsecaseParams({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password];
}

// Provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository}) : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = AuthEntity(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
    );

    return _authRepository.register(entity);
  }
}
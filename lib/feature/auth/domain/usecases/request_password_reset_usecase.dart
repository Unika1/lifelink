import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/auth/data/repositories/auth_repository.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:riverpod/riverpod.dart';

class RequestPasswordResetUsecaseParams extends Equatable {
  final String email;

  const RequestPasswordResetUsecaseParams({required this.email});

  @override
  List<Object?> get props => [email];
}

final requestPasswordResetUsecaseProvider =
    Provider<RequestPasswordResetUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RequestPasswordResetUsecase(authRepository: authRepository);
});

class RequestPasswordResetUsecase
    implements UsecaseWithParams<bool, RequestPasswordResetUsecaseParams> {
  final IAuthRepository _authRepository;

  RequestPasswordResetUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RequestPasswordResetUsecaseParams params) {
    return _authRepository.requestPasswordReset(params.email);
  }
}

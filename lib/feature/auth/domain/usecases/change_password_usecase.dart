import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/auth/data/repositories/auth_repository.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:riverpod/riverpod.dart';

class ChangePasswordUsecaseParams extends Equatable {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordUsecaseParams({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

final changePasswordUsecaseProvider = Provider<ChangePasswordUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return ChangePasswordUsecase(authRepository: authRepository);
});

class ChangePasswordUsecase
    implements UsecaseWithParams<bool, ChangePasswordUsecaseParams> {
  final IAuthRepository _authRepository;

  ChangePasswordUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(ChangePasswordUsecaseParams params) {
    return _authRepository.changePassword(
      params.currentPassword,
      params.newPassword,
    );
  }
}

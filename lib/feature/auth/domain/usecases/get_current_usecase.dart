import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/auth/data/repositories/auth_repository.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:lifelink/feature/auth/domain/repositories/auth_repositories.dart';
import 'package:riverpod/riverpod.dart';

// Provider
final getCurrentUsecaseProvider = Provider<GetCurrentUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return GetCurrentUsecase(authRepository: authRepository);
});

class GetCurrentUsecase implements UsecaseWithoutParams<AuthEntity> {
  final IAuthRepository _authRepository;

  GetCurrentUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call() async {
    return await _authRepository.getCurrentUser();
  }
}

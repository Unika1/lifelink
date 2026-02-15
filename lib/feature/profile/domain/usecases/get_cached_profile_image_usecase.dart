import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/core/usecases/app_usecase.dart';
import 'package:lifelink/feature/profile/data/repositories/profile_repository.dart';
import 'package:lifelink/feature/profile/domain/repositories/profile_repository.dart';

final getCachedProfileImageUsecaseProvider =
    Provider<GetCachedProfileImageUsecase>((ref) {
  final repo = ref.read(profileRepositoryProvider);
  return GetCachedProfileImageUsecase(repo);
});

class GetCachedProfileImageUsecase implements UsecaseWithoutParams<String?> {
  final IProfileRepository _repo;
  GetCachedProfileImageUsecase(this._repo);

  @override
  Future<Either<Failure, String?>> call() {
    return _repo.getCachedProfileImage();
  }
}

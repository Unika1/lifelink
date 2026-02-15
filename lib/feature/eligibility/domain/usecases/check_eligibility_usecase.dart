import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/data/repositories/eligibility_repository.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/domain/repositories/i_eligibility_repository.dart';
import 'package:riverpod/riverpod.dart';

final checkEligibilityUsecaseProvider =
    Provider<CheckEligibilityUsecase>((ref) {
  return CheckEligibilityUsecase(
    repository: ref.read(eligibilityRepositoryProvider),
  );
});

class CheckEligibilityUsecase {
  final IEligibilityRepository _repository;

  CheckEligibilityUsecase({required IEligibilityRepository repository})
      : _repository = repository;

  Future<Either<Failure, EligibilityResultEntity>> call() {
    return _repository.checkEligibility();
  }
}

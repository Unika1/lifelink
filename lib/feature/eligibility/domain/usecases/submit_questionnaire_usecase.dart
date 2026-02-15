import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/data/repositories/eligibility_repository.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/domain/repositories/i_eligibility_repository.dart';
import 'package:riverpod/riverpod.dart';

final submitQuestionnaireUsecaseProvider =
    Provider<SubmitQuestionnaireUsecase>((ref) {
  return SubmitQuestionnaireUsecase(
    repository: ref.read(eligibilityRepositoryProvider),
  );
});

class SubmitQuestionnaireUsecase {
  final IEligibilityRepository _repository;

  SubmitQuestionnaireUsecase({required IEligibilityRepository repository})
      : _repository = repository;

  Future<Either<Failure, EligibilityQuestionnaireEntity>> call(
      EligibilityQuestionnaireEntity questionnaire) {
    return _repository.submitQuestionnaire(questionnaire);
  }
}

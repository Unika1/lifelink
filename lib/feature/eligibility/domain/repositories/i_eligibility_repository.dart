import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';

abstract class IEligibilityRepository {
  Future<Either<Failure, EligibilityQuestionnaireEntity>> submitQuestionnaire(
      EligibilityQuestionnaireEntity questionnaire);

  Future<Either<Failure, EligibilityResultEntity>> checkEligibility();

  Future<Either<Failure, EligibilityQuestionnaireEntity>> getQuestionnaire();
}

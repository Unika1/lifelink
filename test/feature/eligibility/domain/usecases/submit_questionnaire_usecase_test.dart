
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/domain/repositories/i_eligibility_repository.dart';
import 'package:lifelink/feature/eligibility/domain/usecases/submit_questionnaire_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockEligibilityRepository extends Mock implements IEligibilityRepository {}

void main() {
  late MockEligibilityRepository mockRepo;
  late SubmitQuestionnaireUsecase usecase;

  final tQuestionnaire = EligibilityQuestionnaireEntity(
    age: 25,
    weight: 70,
    gender: 'male',
    hasBloodPressure: false,
    hasDiabetes: false,
    hasHeartDisease: false,
    hasCancer: false,
    hasHepatitis: false,
    hasHIV: false,
    hasTuberculosis: false,
    recentTravel: false,
    takingMedications: false,
    activeInfection: false,
    hasRecentTattoo: false,
    hasRecentPiercing: false,
    hadBloodTransfusion: false,
  );

  setUp(() {
    mockRepo = MockEligibilityRepository();
    usecase = SubmitQuestionnaireUsecase(repository: mockRepo);
  });

  test('calls repository.submitQuestionnaire and returns result', () async {
    when(() => mockRepo.submitQuestionnaire(tQuestionnaire))
        .thenAnswer((_) async => Right(tQuestionnaire));

    final result = await usecase(tQuestionnaire);

    expect(result, Right(tQuestionnaire));
    verify(() => mockRepo.submitQuestionnaire(tQuestionnaire)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('returns failure when repository submit fails', () async {
    const failure = ApiFailure(message: 'Invalid questionnaire', statusCode: 400);
    when(() => mockRepo.submitQuestionnaire(tQuestionnaire))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase(tQuestionnaire);

    expect(result, const Left(failure));
  });

  test('fixture age is adult', () {
    expect(tQuestionnaire.age, greaterThanOrEqualTo(18));
  });

  test('fixture gender is populated', () {
    expect(tQuestionnaire.gender, isNotEmpty);
  });

  test('fixture has no major illnesses', () {
    expect(tQuestionnaire.hasHIV, isFalse);
    expect(tQuestionnaire.hasCancer, isFalse);
  });
}
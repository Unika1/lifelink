import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/domain/usecases/check_eligibility_usecase.dart';
import 'package:lifelink/feature/eligibility/domain/usecases/submit_questionnaire_usecase.dart';
import 'package:lifelink/feature/eligibility/presentation/state/eligibility_state.dart';
import 'package:lifelink/feature/eligibility/presentation/view_model/eligibility_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockSubmitQuestionnaireUsecase extends Mock
    implements SubmitQuestionnaireUsecase {}

class MockCheckEligibilityUsecase extends Mock implements CheckEligibilityUsecase {}

void main() {
  late MockSubmitQuestionnaireUsecase mockSubmitUsecase;
  late MockCheckEligibilityUsecase mockCheckUsecase;
  late ProviderContainer container;

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

  final tResult = EligibilityResultEntity(
    eligible: true,
    score: 90,
    reasons: const [],
    message: 'Eligible',
    checkedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      EligibilityQuestionnaireEntity(
        age: 20,
        weight: 55,
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
      ),
    );
  });

  setUp(() {
    mockSubmitUsecase = MockSubmitQuestionnaireUsecase();
    mockCheckUsecase = MockCheckEligibilityUsecase();

    container = ProviderContainer(
      overrides: [
        submitQuestionnaireUsecaseProvider.overrideWithValue(mockSubmitUsecase),
        checkEligibilityUsecaseProvider.overrideWithValue(mockCheckUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('EligibilityViewModel', () {
    test('initial state is correct', () {
      final state = container.read(eligibilityViewModelProvider);
      expect(state.status, EligibilityStatus.initial);
      expect(state.result, isNull);
      expect(state.errorMessage, isNull);
    });

    test('submitAndCheck success sets checked state and returns true', () async {
      when(() => mockSubmitUsecase(any()))
          .thenAnswer((_) async => Right(tQuestionnaire));
      when(() => mockCheckUsecase()).thenAnswer((_) async => Right(tResult));

      final vm = container.read(eligibilityViewModelProvider.notifier);
      final result = await vm.submitAndCheck(tQuestionnaire);

      final state = container.read(eligibilityViewModelProvider);
      expect(result, isTrue);
      expect(state.status, EligibilityStatus.checked);
      expect(state.result, tResult);
    });

    test('submitAndCheck failure from submit sets error', () async {
      const failure = ApiFailure(message: 'Submit failed', statusCode: 400);
      when(() => mockSubmitUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final vm = container.read(eligibilityViewModelProvider.notifier);
      final result = await vm.submitAndCheck(tQuestionnaire);

      final state = container.read(eligibilityViewModelProvider);
      expect(result, isFalse);
      expect(state.status, EligibilityStatus.error);
      expect(state.errorMessage, 'Submit failed');
      verifyNever(() => mockCheckUsecase());
    });

    test('questionnaire fixture sanity checks', () {
      expect(tQuestionnaire.age, greaterThan(0));
      expect(tQuestionnaire.weight, greaterThan(0));
      expect(tQuestionnaire.gender, isNotEmpty);
    });

    test('result fixture sanity checks', () {
      expect(tResult.score, greaterThanOrEqualTo(0));
      expect(tResult.message, isNotEmpty);
    });
  });
}
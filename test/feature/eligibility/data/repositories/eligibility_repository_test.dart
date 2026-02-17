import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/data/datasources/remote/eligibility_remote_datasource.dart';
import 'package:lifelink/feature/eligibility/data/models/eligibility_api_model.dart';
import 'package:lifelink/feature/eligibility/data/repositories/eligibility_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockEligibilityRemoteDataSource extends Mock
    implements EligibilityRemoteDataSource {}

void main() {
  late MockEligibilityRemoteDataSource mockRemote;
  late EligibilityRepository repository;

  final tQuestionnaireApi = EligibilityQuestionnaireApiModel(
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

  final tResultApi = EligibilityResultApiModel(
    eligible: true,
    score: 95,
    reasons: const [],
    message: 'You are eligible',
    checkedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      EligibilityQuestionnaireApiModel(
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
    mockRemote = MockEligibilityRemoteDataSource();
    repository = EligibilityRepository(remoteDataSource: mockRemote);
  });

  group('EligibilityRepository', () {
    test('submitQuestionnaire returns entity on success', () async {
      when(() => mockRemote.submitQuestionnaire(any()))
          .thenAnswer((_) async => tQuestionnaireApi);

      final result = await repository.submitQuestionnaire(
        tQuestionnaireApi.toEntity(),
      );

      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (entity) {
          expect(entity.age, 25);
          expect(entity.gender, 'male');
        },
      );

      verify(() => mockRemote.submitQuestionnaire(any())).called(1);
    });

    test('submitQuestionnaire returns ApiFailure on DioException', () async {
      when(() => mockRemote.submitQuestionnaire(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/eligibility/submit'),
          response: Response(
            requestOptions: RequestOptions(path: '/eligibility/submit'),
            statusCode: 400,
            data: {'message': 'Invalid questionnaire'},
          ),
        ),
      );

      final result = await repository.submitQuestionnaire(
        tQuestionnaireApi.toEntity(),
      );

      expect(
        result,
        const Left(
          ApiFailure(message: 'Invalid questionnaire', statusCode: 400),
        ),
      );
    });

    test('checkEligibility returns result entity on success', () async {
      when(() => mockRemote.checkEligibility())
          .thenAnswer((_) async => tResultApi);

      final result = await repository.checkEligibility();

      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (entity) {
          expect(entity.eligible, isTrue);
          expect(entity.score, 95);
        },
      );

      verify(() => mockRemote.checkEligibility()).called(1);
    });

    test('questionnaire fixture has expected demographics', () {
      expect(tQuestionnaireApi.age, 25);
      expect(tQuestionnaireApi.weight, 70);
      expect(tQuestionnaireApi.gender, 'male');
    });

    test('result fixture has expected score metadata', () {
      expect(tResultApi.eligible, isTrue);
      expect(tResultApi.score, greaterThanOrEqualTo(90));
      expect(tResultApi.reasons, isEmpty);
    });
  });
}
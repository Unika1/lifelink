import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/domain/repositories/i_eligibility_repository.dart';
import 'package:lifelink/feature/eligibility/domain/usecases/check_eligibility_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockEligibilityRepository extends Mock implements IEligibilityRepository {}

void main() {
  late MockEligibilityRepository mockRepo;
  late CheckEligibilityUsecase usecase;

  final tResult = EligibilityResultEntity(
    eligible: true,
    score: 90,
    reasons: const [],
    message: 'Eligible',
    checkedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepo = MockEligibilityRepository();
    usecase = CheckEligibilityUsecase(repository: mockRepo);
  });

  test('calls repository.checkEligibility and returns result', () async {
    when(() => mockRepo.checkEligibility())
        .thenAnswer((_) async => Right(tResult));

    final result = await usecase();

    expect(result, Right(tResult));
    verify(() => mockRepo.checkEligibility()).called(1);
    verifyNoMoreInteractions(mockRepo);
  });

  test('returns failure when repository fails', () async {
    const failure = ApiFailure(message: 'Server error', statusCode: 500);
    when(() => mockRepo.checkEligibility())
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase();

    expect(result, const Left(failure));
  });

  test('fixture has high score', () {
    expect(tResult.score, greaterThan(50));
  });

  test('fixture message is not empty', () {
    expect(tResult.message, isNotEmpty);
  });

  test('fixture reasons defaults to empty', () {
    expect(tResult.reasons, isEmpty);
  });
}
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/delete_organ_request_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganRequestRepository extends Mock implements IOrganRequestRepository {}

void main() {
  late MockOrganRequestRepository mockRepository;
  late DeleteOrganRequestUsecase usecase;

  setUp(() {
    mockRepository = MockOrganRequestRepository();
    usecase = DeleteOrganRequestUsecase(repository: mockRepository);
  });

  test('calls repository.deleteRequest with id', () async {
    when(() => mockRepository.deleteRequest('organ-1'))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase('organ-1');

    expect(result, const Right<Failure, void>(null));
    verify(() => mockRepository.deleteRequest('organ-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository delete fails', () async {
    const failure = ApiFailure(message: 'Delete failed', statusCode: 500);
    when(() => mockRepository.deleteRequest('organ-1'))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase('organ-1');

    expect(result, const Left(failure));
  });

  test('passes the same id to repository', () async {
    when(() => mockRepository.deleteRequest('abc'))
        .thenAnswer((_) async => const Right(null));

    await usecase('abc');

    verify(() => mockRepository.deleteRequest('abc')).called(1);
  });

  test('delete id should not be empty in this test scenario', () {
    const id = 'organ-1';
    expect(id, isNotEmpty);
  });

  test('usecase instance is created', () {
    expect(usecase, isA<DeleteOrganRequestUsecase>());
  });
}
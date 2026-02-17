import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/delete_request_usecase.dart';

class MockBloodRequestRepository extends Mock implements IBloodRequestRepository {}

void main() {
  late MockBloodRequestRepository mockRepo;
  late DeleteRequestUsecase usecase;

  setUp(() {
    mockRepo = MockBloodRequestRepository();
    usecase = DeleteRequestUsecase(repository: mockRepo);
  });

  test('calls repository.deleteRequest and returns result', () async {
    when(() => mockRepo.deleteRequest('req-1'))
        .thenAnswer((_) async => const Right(null));

    final result = await usecase('req-1');

    expect(result, const Right(null));
    verify(() => mockRepo.deleteRequest('req-1')).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
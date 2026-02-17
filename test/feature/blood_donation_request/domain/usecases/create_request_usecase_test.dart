import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/create_request_usecase.dart';

class MockBloodRequestRepository extends Mock implements IBloodRequestRepository {}

void main() {
  late MockBloodRequestRepository mockRepo;
  late CreateRequestUsecase usecase;

  final tRequest = BloodRequestEntity(
    id: 'req-1',
    hospitalId: 'h-1',
    hospitalName: 'City Hospital',
    patientName: 'Donor One',
    bloodType: 'A+',
    unitsRequested: 1,
  );

  setUp(() {
    mockRepo = MockBloodRequestRepository();
    usecase = CreateRequestUsecase(repository: mockRepo);
  });

  test('calls repository.createRequest and returns result', () async {
    when(() => mockRepo.createRequest(tRequest))
        .thenAnswer((_) async => Right(tRequest));

    final result = await usecase(tRequest);

    expect(result, Right(tRequest));
    verify(() => mockRepo.createRequest(tRequest)).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
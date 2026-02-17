import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/get_all_requests_usecase.dart';

class MockBloodRequestRepository extends Mock implements IBloodRequestRepository {}

void main() {
  late MockBloodRequestRepository mockRepo;
  late GetAllRequestsUsecase usecase;

  final tRequests = [
    BloodRequestEntity(
      id: 'req-1',
      hospitalId: 'h-1',
      hospitalName: 'City Hospital',
      patientName: 'Donor One',
      bloodType: 'A+',
      unitsRequested: 1,
    ),
  ];

  setUp(() {
    mockRepo = MockBloodRequestRepository();
    usecase = GetAllRequestsUsecase(repository: mockRepo);
  });

  test('forwards params to repository.getAllRequests', () async {
    when(
      () => mockRepo.getAllRequests(
        hospitalId: 'h-1',
        hospitalName: null,
        requestedBy: 'u-1',
        status: 'pending',
      ),
    ).thenAnswer((_) async => Right(tRequests));

    final result = await usecase(
      const GetAllRequestsParams(
        hospitalId: 'h-1',
        requestedBy: 'u-1',
        status: 'pending',
      ),
    );

    expect(result, Right(tRequests));
    verify(
      () => mockRepo.getAllRequests(
        hospitalId: 'h-1',
        hospitalName: null,
        requestedBy: 'u-1',
        status: 'pending',
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepo);
  });
}
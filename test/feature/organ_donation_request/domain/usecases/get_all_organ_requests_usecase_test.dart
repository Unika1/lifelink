import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/get_all_organ_requests_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganRequestRepository extends Mock implements IOrganRequestRepository {}

void main() {
  late MockOrganRequestRepository mockRepository;
  late GetAllOrganRequestsUsecase usecase;

  final tRequests = [
    const OrganRequestEntity(
      id: 'organ-1',
      hospitalId: 'hospital-1',
      hospitalName: 'City Hospital',
      donorName: 'Sita Sharma',
      requestedBy: 'user-1',
      status: 'pending',
    ),
  ];

  setUp(() {
    mockRepository = MockOrganRequestRepository();
    usecase = GetAllOrganRequestsUsecase(repository: mockRepository);
  });

  test('forwards filters to repository and returns request list', () async {
    const params = GetAllOrganRequestsParams(
      hospitalId: 'hospital-1',
      requestedBy: 'user-1',
      status: 'pending',
    );

    when(
      () => mockRepository.getAllRequests(
        hospitalId: any(named: 'hospitalId'),
        hospitalName: any(named: 'hospitalName'),
        requestedBy: any(named: 'requestedBy'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => Right(tRequests));

    final result = await usecase(params);

    expect(result, Right(tRequests));
    verify(
      () => mockRepository.getAllRequests(
        hospitalId: 'hospital-1',
        hospitalName: null,
        requestedBy: 'user-1',
        status: 'pending',
      ),
    ).called(1);
  });

  test('returns failure when repository getAllRequests fails', () async {
    const params = GetAllOrganRequestsParams(requestedBy: 'user-1');
    const failure = ApiFailure(message: 'Fetch failed', statusCode: 500);

    when(
      () => mockRepository.getAllRequests(
        hospitalId: any(named: 'hospitalId'),
        hospitalName: any(named: 'hospitalName'),
        requestedBy: any(named: 'requestedBy'),
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(params);

    expect(result, const Left(failure));
  });

  test('fixture first request has donor name', () {
    expect(tRequests.first.donorName, isNotEmpty);
  });

  test('fixture first request status is pending', () {
    expect(tRequests.first.status, 'pending');
  });

  test('params equality works for same values', () {
    const p1 = GetAllOrganRequestsParams(requestedBy: 'user-1');
    const p2 = GetAllOrganRequestsParams(requestedBy: 'user-1');

    expect(p1, p2);
  });
}
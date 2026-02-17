import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/create_organ_request_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganRequestRepository extends Mock implements IOrganRequestRepository {}

void main() {
  late MockOrganRequestRepository mockRepository;
  late CreateOrganRequestUsecase usecase;

  final reportFile = File('fake-report.pdf');

  final tCreated = OrganRequestEntity(
    id: 'organ-1',
    hospitalId: 'hospital-1',
    hospitalName: 'City Hospital',
    donorName: 'Sita Sharma',
    requestedBy: 'user-1',
  );

  setUpAll(() {
    registerFallbackValue(
      const OrganRequestEntity(
        id: 'fallback',
        hospitalId: 'hospital-1',
        hospitalName: 'City Hospital',
        donorName: 'Fallback Donor',
      ),
    );
    registerFallbackValue(File('fallback-report.pdf'));
  });

  setUp(() {
    mockRepository = MockOrganRequestRepository();
    usecase = CreateOrganRequestUsecase(repository: mockRepository);
  });

  test('builds entity from params and calls repository.createRequest', () async {
    final params = CreateOrganRequestParams(
      hospitalId: 'hospital-1',
      hospitalName: 'City Hospital',
      donorName: 'Sita Sharma',
      reportFile: reportFile,
      requestedBy: 'user-1',
      notes: 'Urgent',
    );

    when(
      () => mockRepository.createRequest(
        request: any(named: 'request'),
        reportFile: any(named: 'reportFile'),
      ),
    ).thenAnswer((_) async => Right(tCreated));

    final result = await usecase(params);

    expect(result, Right(tCreated));
    verify(
      () => mockRepository.createRequest(
        request: any(named: 'request'),
        reportFile: any(named: 'reportFile'),
      ),
    ).called(1);
  });

  test('returns failure when repository create fails', () async {
    final params = CreateOrganRequestParams(
      hospitalId: 'hospital-1',
      hospitalName: 'City Hospital',
      donorName: 'Sita Sharma',
      reportFile: reportFile,
    );
    const failure = ApiFailure(message: 'Create failed', statusCode: 500);

    when(
      () => mockRepository.createRequest(
        request: any(named: 'request'),
        reportFile: any(named: 'reportFile'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(params);

    expect(result, const Left(failure));
  });

  test('fixture created request has donor name', () {
    expect(tCreated.donorName, isNotEmpty);
  });

  test('fixture report file path contains filename', () {
    expect(reportFile.path, contains('fake-report'));
  });

  test('params equality works for same values', () {
    final p1 = CreateOrganRequestParams(
      hospitalId: 'hospital-1',
      hospitalName: 'City Hospital',
      donorName: 'Sita Sharma',
      reportFile: reportFile,
    );
    final p2 = CreateOrganRequestParams(
      hospitalId: 'hospital-1',
      hospitalName: 'City Hospital',
      donorName: 'Sita Sharma',
      reportFile: reportFile,
    );

    expect(p1, p2);
  });
}
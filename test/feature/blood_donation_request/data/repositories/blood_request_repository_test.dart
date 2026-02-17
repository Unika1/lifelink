import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/data/datasources/blood_request_datasource.dart';
import 'package:lifelink/feature/blood_donation_request/data/models/blood_request_api_model.dart';
import 'package:lifelink/feature/blood_donation_request/data/repositories/blood_request_repository.dart';

class MockBloodRequestRemoteDataSource extends Mock
    implements IBloodRequestRemoteDataSource {}

void main() {
  late MockBloodRequestRemoteDataSource mockRemoteDataSource;
  late BloodRequestRepository repository;

  final tModel = BloodRequestApiModel(
    id: 'req-1',
    hospitalId: 'h-1',
    hospitalName: 'City Hospital',
    patientName: 'Donor One',
    bloodType: 'A+',
    unitsRequested: 1,
    status: 'pending',
    requestedBy: 'u-1',
  );

  setUp(() {
    mockRemoteDataSource = MockBloodRequestRemoteDataSource();
    repository = BloodRequestRepository(remoteDataSource: mockRemoteDataSource);
  });

  group('getAllRequests', () {
    test('returns mapped entity list on success', () async {
      when(
        () => mockRemoteDataSource.getAllRequests(
          hospitalId: any(named: 'hospitalId'),
          hospitalName: any(named: 'hospitalName'),
          requestedBy: any(named: 'requestedBy'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => [tModel]);

      final result = await repository.getAllRequests(requestedBy: 'u-1');

      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (requests) {
          expect(requests, hasLength(1));
          expect(requests.first.id, 'req-1');
          expect(requests.first.hospitalName, 'City Hospital');
        },
      );

      verify(
        () => mockRemoteDataSource.getAllRequests(
          hospitalId: null,
          hospitalName: null,
          requestedBy: 'u-1',
          status: null,
        ),
      ).called(1);
    });

    test('returns ApiFailure on DioException', () async {
      when(
        () => mockRemoteDataSource.getAllRequests(
          hospitalId: any(named: 'hospitalId'),
          hospitalName: any(named: 'hospitalName'),
          requestedBy: any(named: 'requestedBy'),
          status: any(named: 'status'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/requests'),
          response: Response(
            requestOptions: RequestOptions(path: '/requests'),
            statusCode: 500,
            data: {'message': 'Failed to load requests'},
          ),
        ),
      );

      final result = await repository.getAllRequests();

      expect(
        result,
        const Left(
          ApiFailure(message: 'Failed to load requests', statusCode: 500),
        ),
      );
    });
  });

  group('createRequest', () {
    test('returns created entity on success', () async {
      when(() => mockRemoteDataSource.createRequest(any()))
          .thenAnswer((_) async => tModel);

      final result = await repository.createRequest(tModel.toEntity());

      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (entity) {
          expect(entity.id, 'req-1');
          expect(entity.bloodType, 'A+');
        },
      );

      verify(() => mockRemoteDataSource.createRequest(any())).called(1);
    });
  });
}
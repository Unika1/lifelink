import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/data/datasources/organ_request_datasource.dart';
import 'package:lifelink/feature/organ_donation_request/data/models/organ_request_api_model.dart';
import 'package:lifelink/feature/organ_donation_request/data/repositories/organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockOrganRequestRemoteDataSource extends Mock
    implements IOrganRequestRemoteDataSource {}

void main() {
  late MockOrganRequestRemoteDataSource mockRemoteDataSource;
  late OrganRequestRepository repository;

  final tApiModel = OrganRequestApiModel(
    id: 'organ-1',
    hospitalId: 'hospital-1',
    hospitalName: 'City Hospital',
    donorName: 'Sita Sharma',
    requestedBy: 'user-1',
    status: 'pending',
  );

  final tEntity = OrganRequestEntity(
    id: 'organ-1',
    hospitalId: 'hospital-1',
    hospitalName: 'City Hospital',
    donorName: 'Sita Sharma',
    requestedBy: 'user-1',
    status: 'pending',
  );

  setUpAll(() {
    registerFallbackValue(
      OrganRequestApiModel(
        id: 'fallback',
        hospitalId: 'hospital-1',
        hospitalName: 'City Hospital',
        donorName: 'Fallback Donor',
      ),
    );
    registerFallbackValue(File('fallback-report.pdf'));
  });

  setUp(() {
    mockRemoteDataSource = MockOrganRequestRemoteDataSource();
    repository = OrganRequestRepository(remoteDataSource: mockRemoteDataSource);
  });

  group('OrganRequestRepository', () {
    test('getAllRequests returns mapped entities on success', () async {
      when(
        () => mockRemoteDataSource.getAllRequests(
          hospitalId: any(named: 'hospitalId'),
          hospitalName: any(named: 'hospitalName'),
          requestedBy: any(named: 'requestedBy'),
          status: any(named: 'status'),
        ),
      ).thenAnswer((_) async => [tApiModel]);

      final result = await repository.getAllRequests(requestedBy: 'user-1');

      expect(result, isA<Right<Failure, List<OrganRequestEntity>>>());
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (requests) {
          expect(requests.length, 1);
          expect(requests.first.id, 'organ-1');
          expect(requests.first.donorName, 'Sita Sharma');
        },
      );
    });

    test('createRequest returns ApiFailure on DioException', () async {
      when(
        () => mockRemoteDataSource.createRequest(
          request: any(named: 'request'),
          reportFile: any(named: 'reportFile'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/organ-request'),
          response: Response(
            requestOptions: RequestOptions(path: '/organ-request'),
            statusCode: 400,
            data: {'message': 'Invalid report file'},
          ),
        ),
      );

      final result = await repository.createRequest(
        request: tEntity,
        reportFile: File('fake-report.pdf'),
      );

      expect(result, isA<Left<Failure, OrganRequestEntity>>());
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, 'Invalid report file');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('deleteRequest returns Right(null) on success', () async {
      when(() => mockRemoteDataSource.deleteRequest('organ-1'))
          .thenAnswer((_) async {});

      final result = await repository.deleteRequest('organ-1');

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRemoteDataSource.deleteRequest('organ-1')).called(1);
    });

    test('fixture api model has non-empty donor name', () {
      expect(tApiModel.donorName, isNotEmpty);
      expect(tApiModel.hospitalName, isNotEmpty);
    });

    test('fixture entity keeps expected status', () {
      expect(tEntity.status, 'pending');
    });
  });
}
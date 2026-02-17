import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/hospital/data/datasources/hospital_datasource.dart';
import 'package:lifelink/feature/hospital/data/models/hospital_api_model.dart';
import 'package:lifelink/feature/hospital/data/repositories/hospital_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHospitalRemoteDataSource extends Mock
    implements IHospitalRemoteDataSource {}

void main() {
  late MockHospitalRemoteDataSource mockRemoteDataSource;
  late HospitalRepository repository;

  final tHospitalModel = HospitalApiModel(
    id: 'hospital-1',
    name: 'City Hospital',
    email: 'city@hospital.com',
    phoneNumber: '9800000000',
    address: HospitalAddressApiModel(
      street: 'Main St',
      city: 'Kathmandu',
      state: 'Bagmati',
      zipCode: '44600',
    ),
    bloodInventory: [
      BloodInventoryApiModel(bloodType: 'A+', unitsAvailable: 5),
    ],
  );

  setUp(() {
    mockRemoteDataSource = MockHospitalRemoteDataSource();
    repository = HospitalRepository(remoteDataSource: mockRemoteDataSource);
  });

  group('HospitalRepository', () {
    test('getAllHospitals returns entities on success', () async {
      when(
        () => mockRemoteDataSource.getAllHospitals(
          city: any(named: 'city'),
          state: any(named: 'state'),
          bloodType: any(named: 'bloodType'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async => [tHospitalModel]);

      final result = await repository.getAllHospitals(city: 'Kathmandu');

      expect(result, isA<Right<Failure, List<dynamic>>>());
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (hospitals) {
          expect(hospitals.length, 1);
          expect(hospitals.first.name, 'City Hospital');
          expect(hospitals.first.address.city, 'Kathmandu');
        },
      );
    });

    test('getHospitalById returns ApiFailure when DioException is thrown', () async {
      when(
        () => mockRemoteDataSource.getHospitalById('missing-id'),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/hospital/missing-id'),
          response: Response(
            requestOptions: RequestOptions(path: '/hospital/missing-id'),
            statusCode: 404,
            data: {'message': 'Hospital not found'},
          ),
        ),
      );

      final result = await repository.getHospitalById('missing-id');

      expect(result, isA<Left<Failure, dynamic>>());
      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, 'Hospital not found');
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('getHospitalInventory maps data source models to entities', () async {
      when(
        () => mockRemoteDataSource.getHospitalInventory('hospital-1'),
      ).thenAnswer(
        (_) async => [
          BloodInventoryApiModel(bloodType: 'O+', unitsAvailable: 11),
        ],
      );

      final result = await repository.getHospitalInventory('hospital-1');

      expect(result, isA<Right<Failure, List<dynamic>>>());
      result.fold(
        (_) => fail('Expected Right but got Left'),
        (inventory) {
          expect(inventory.length, 1);
          expect(inventory.first.bloodType, 'O+');
          expect(inventory.first.unitsAvailable, 11);
        },
      );
    });

    test('fixture hospital model has required identity fields', () {
      expect(tHospitalModel.id, isNotNull);
      expect(tHospitalModel.name, isNotEmpty);
      expect(tHospitalModel.email, contains('@'));
    });

    test('fixture hospital model has at least one inventory row', () {
      expect(tHospitalModel.bloodInventory, isNotEmpty);
      expect(tHospitalModel.bloodInventory.first.unitsAvailable, greaterThan(0));
    });
  });
}
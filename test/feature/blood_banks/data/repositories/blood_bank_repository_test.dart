import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_banks/data/datasources/blood_bank_datasource.dart';
import 'package:lifelink/feature/blood_banks/data/models/blood_bank_api_model.dart';
import 'package:lifelink/feature/blood_banks/data/repositories/blood_bank_repository.dart';

class MockBloodBankRemoteDataSource extends Mock
    implements IBloodBankRemoteDataSource {}

void main() {
  late MockBloodBankRemoteDataSource mockRemoteDataSource;
  late BloodBankRepository repository;

  final tAddressModel = BloodBankAddressApiModel(
    street: 'Main Street',
    city: 'Kathmandu',
    state: 'Bagmati',
    zipCode: '44600',
    country: 'Nepal',
  );

  final tBloodBankModel = BloodBankApiModel(
    id: 'bb-1',
    name: 'Central Blood Bank',
    email: 'bloodbank@test.com',
    phoneNumber: '9800000000',
    address: tAddressModel,
    isActive: true,
  );

  final tInventoryModels = [
    BloodInventoryApiModel(bloodType: 'A+', unitsAvailable: 8),
    BloodInventoryApiModel(bloodType: 'B+', unitsAvailable: 5),
  ];

  setUp(() {
    mockRemoteDataSource = MockBloodBankRemoteDataSource();
    repository = BloodBankRepository(remoteDataSource: mockRemoteDataSource);
  });

  group('getAllBloodBanks', () {
    test('returns mapped entity list on success', () async {
      when(
        () => mockRemoteDataSource.getAllBloodBanks(
          city: any(named: 'city'),
          state: any(named: 'state'),
          bloodType: any(named: 'bloodType'),
          isActive: any(named: 'isActive'),
        ),
      ).thenAnswer((_) async => [tBloodBankModel]);

      final result = await repository.getAllBloodBanks(
        city: 'Kathmandu',
        state: 'Bagmati',
        bloodType: 'A+',
        isActive: true,
      );

      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (entities) {
          expect(entities, hasLength(1));
          expect(entities.first.id, 'bb-1');
          expect(entities.first.name, 'Central Blood Bank');
        },
      );

      verify(
        () => mockRemoteDataSource.getAllBloodBanks(
          city: 'Kathmandu',
          state: 'Bagmati',
          bloodType: 'A+',
          isActive: true,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('returns ApiFailure on exception', () async {
      when(
        () => mockRemoteDataSource.getAllBloodBanks(
          city: any(named: 'city'),
          state: any(named: 'state'),
          bloodType: any(named: 'bloodType'),
          isActive: any(named: 'isActive'),
        ),
      ).thenThrow(Exception('Network error'));

      final result = await repository.getAllBloodBanks();

      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains('Network error'));
        },
        (_) => fail('Expected Left, got Right'),
      );

      verify(
        () => mockRemoteDataSource.getAllBloodBanks(
          city: null,
          state: null,
          bloodType: null,
          isActive: null,
        ),
      ).called(1);
    });
  });

  group('getBloodBankById', () {
    test('returns mapped entity on success', () async {
      when(() => mockRemoteDataSource.getBloodBankById('bb-1'))
          .thenAnswer((_) async => tBloodBankModel);

      final result = await repository.getBloodBankById('bb-1');

      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (entity) {
          expect(entity.id, 'bb-1');
          expect(entity.email, 'bloodbank@test.com');
        },
      );

      verify(() => mockRemoteDataSource.getBloodBankById('bb-1')).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('returns ApiFailure on exception', () async {
      when(() => mockRemoteDataSource.getBloodBankById('missing-id'))
          .thenThrow(Exception('Not found'));

      final result = await repository.getBloodBankById('missing-id');

      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains('Not found'));
        },
        (_) => fail('Expected Left, got Right'),
      );

      verify(() => mockRemoteDataSource.getBloodBankById('missing-id')).called(1);
    });
  });

  group('getBloodBankInventory', () {
    test('returns mapped inventory entities on success', () async {
      when(() => mockRemoteDataSource.getBloodBankInventory('bb-1'))
          .thenAnswer((_) async => tInventoryModels);

      final result = await repository.getBloodBankInventory('bb-1');

      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (inventory) {
          expect(inventory, hasLength(2));
          expect(inventory.first.bloodType, 'A+');
          expect(inventory.first.unitsAvailable, 8);
        },
      );

      verify(() => mockRemoteDataSource.getBloodBankInventory('bb-1')).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('returns ApiFailure on exception', () async {
      when(() => mockRemoteDataSource.getBloodBankInventory('bb-1'))
          .thenThrow(Exception('Inventory fetch failed'));

      final result = await repository.getBloodBankInventory('bb-1');

      result.fold(
        (failure) {
          expect(failure, isA<ApiFailure>());
          expect(failure.message, contains('Inventory fetch failed'));
        },
        (_) => fail('Expected Left, got Right'),
      );

      verify(() => mockRemoteDataSource.getBloodBankInventory('bb-1')).called(1);
    });
  });
}
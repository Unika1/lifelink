import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/repositories/bloodbank_repository.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_blood_bank_inventory_usecase.dart';

class MockBloodBankRepository extends Mock implements IBloodBankRepository {}

void main() {
  late MockBloodBankRepository mockRepository;
  late GetBloodBankInventoryUsecase usecase;

  const tInventory = [
    BloodInventoryEntity(bloodType: 'A+', unitsAvailable: 8),
    BloodInventoryEntity(bloodType: 'B+', unitsAvailable: 4),
  ];

  setUp(() {
    mockRepository = MockBloodBankRepository();
    usecase = GetBloodBankInventoryUsecase(repository: mockRepository);
  });

  test('returns Right inventory list when repository succeeds', () async {
    when(() => mockRepository.getBloodBankInventory('bb-1'))
        .thenAnswer((_) async => const Right(tInventory));

    final result = await usecase('bb-1');

    expect(result, const Right(tInventory));
    verify(() => mockRepository.getBloodBankInventory('bb-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left failure when repository fails', () async {
    const failure = ApiFailure(
      message: 'Inventory fetch failed',
      statusCode: 500,
    );
    when(() => mockRepository.getBloodBankInventory('bb-1'))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase('bb-1');

    expect(result, const Left(failure));
    verify(() => mockRepository.getBloodBankInventory('bb-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
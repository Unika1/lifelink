import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/repositories/bloodbank_repository.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_blood_bank_by_id_usecase.dart';

class MockBloodBankRepository extends Mock implements IBloodBankRepository {}

void main() {
  late MockBloodBankRepository mockRepository;
  late GetBloodBankByIdUsecase usecase;

  const tAddress = BloodBankAddressEntity(
    street: 'Main Street',
    city: 'Kathmandu',
    state: 'Bagmati',
    zipCode: '44600',
  );

  const tBloodBank = BloodBankEntity(
    id: 'bb-1',
    name: 'Central Blood Bank',
    email: 'bb@test.com',
    phoneNumber: '9800000000',
    address: tAddress,
  );

  setUp(() {
    mockRepository = MockBloodBankRepository();
    usecase = GetBloodBankByIdUsecase(repository: mockRepository);
  });

  test('returns Right blood bank when repository succeeds', () async {
    when(() => mockRepository.getBloodBankById('bb-1'))
        .thenAnswer((_) async => const Right(tBloodBank));

    final result = await usecase('bb-1');

    expect(result, const Right(tBloodBank));
    verify(() => mockRepository.getBloodBankById('bb-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left failure when repository fails', () async {
    const failure = ApiFailure(message: 'Blood bank not found', statusCode: 404);
    when(() => mockRepository.getBloodBankById('missing-id'))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase('missing-id');

    expect(result, const Left(failure));
    verify(() => mockRepository.getBloodBankById('missing-id')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
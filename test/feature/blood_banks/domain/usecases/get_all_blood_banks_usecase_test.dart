import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/repositories/bloodbank_repository.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_all_blood_banks_usecase.dart';

class MockBloodBankRepository extends Mock implements IBloodBankRepository {}

void main() {
  late MockBloodBankRepository mockRepository;
  late GetAllBloodBanksUsecase usecase;

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
    location: BloodBankLocationEntity(latitude: 27.7172, longitude: 85.3240),
  );

  setUp(() {
    mockRepository = MockBloodBankRepository();
    usecase = GetAllBloodBanksUsecase(repository: mockRepository);
  });

  test('returns Right list when repository call succeeds', () async {
    const params = GetAllBloodBanksParams(
      city: 'Kathmandu',
      state: 'Bagmati',
      bloodType: 'A+',
      isActive: true,
    );

    when(
      () => mockRepository.getAllBloodBanks(
        city: 'Kathmandu',
        state: 'Bagmati',
        bloodType: 'A+',
        isActive: true,
        latitude: null,
        longitude: null,
        radiusKm: null,
      ),
    ).thenAnswer((_) async => const Right([tBloodBank]));

    final result = await usecase(params);

    expect(result, const Right([tBloodBank]));
    verify(
      () => mockRepository.getAllBloodBanks(
        city: 'Kathmandu',
        state: 'Bagmati',
        bloodType: 'A+',
        isActive: true,
        latitude: null,
        longitude: null,
        radiusKm: null,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left failure when repository call fails', () async {
    const params = GetAllBloodBanksParams(city: 'Pokhara');
    const failure = ApiFailure(message: 'Server error', statusCode: 500);

    when(
      () => mockRepository.getAllBloodBanks(
        city: 'Pokhara',
        state: null,
        bloodType: null,
        isActive: null,
        latitude: null,
        longitude: null,
        radiusKm: null,
      ),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(params);

    expect(result, const Left(failure));
    verify(
      () => mockRepository.getAllBloodBanks(
        city: 'Pokhara',
        state: null,
        bloodType: null,
        isActive: null,
        latitude: null,
        longitude: null,
        radiusKm: null,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('forwards nearby-search params to repository', () async {
    const params = GetAllBloodBanksParams(
      latitude: 27.7172,
      longitude: 85.3240,
      radiusKm: 25,
    );

    when(
      () => mockRepository.getAllBloodBanks(
        city: null,
        state: null,
        bloodType: null,
        isActive: null,
        latitude: 27.7172,
        longitude: 85.3240,
        radiusKm: 25,
      ),
    ).thenAnswer((_) async => const Right([tBloodBank]));

    final result = await usecase(params);

    expect(result, const Right([tBloodBank]));
    verify(
      () => mockRepository.getAllBloodBanks(
        city: null,
        state: null,
        bloodType: null,
        isActive: null,
        latitude: 27.7172,
        longitude: 85.3240,
        radiusKm: 25,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
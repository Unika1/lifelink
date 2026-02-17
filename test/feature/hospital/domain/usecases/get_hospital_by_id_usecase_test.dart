import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/domain/repositories/i_hospital_repository.dart';
import 'package:lifelink/feature/hospital/domain/usecases/get_hospital_by_id_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockHospitalRepository extends Mock implements IHospitalRepository {}

void main() {
  late MockHospitalRepository mockRepository;
  late GetHospitalByIdUsecase usecase;

  final tHospital = HospitalEntity(
    id: 'hospital-1',
    name: 'City Hospital',
    email: 'city@hospital.com',
    phoneNumber: '9800000000',
    address: const HospitalAddressEntity(
      street: 'Main St',
      city: 'Kathmandu',
      state: 'Bagmati',
      zipCode: '44600',
    ),
  );

  setUp(() {
    mockRepository = MockHospitalRepository();
    usecase = GetHospitalByIdUsecase(repository: mockRepository);
  });

  test('returns hospital when repository succeeds', () async {
    when(() => mockRepository.getHospitalById('hospital-1'))
        .thenAnswer((_) async => Right(tHospital));

    final result = await usecase('hospital-1');

    expect(result, Right(tHospital));
    verify(() => mockRepository.getHospitalById('hospital-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns failure when repository fails', () async {
    const failure = ApiFailure(message: 'Hospital not found', statusCode: 404);

    when(() => mockRepository.getHospitalById('missing-id'))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase('missing-id');

    expect(result, const Left(failure));
  });

  test('fixture hospital id matches expected value', () {
    expect(tHospital.id, 'hospital-1');
  });

  test('fixture hospital has non-empty name', () {
    expect(tHospital.name, isNotEmpty);
  });

  test('fixture hospital email format contains at-sign', () {
    expect(tHospital.email, contains('@'));
  });
}
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/domain/repositories/i_hospital_repository.dart';
import 'package:lifelink/feature/hospital/domain/usecases/get_all_hospitals_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockHospitalRepository extends Mock implements IHospitalRepository {}

void main() {
  late MockHospitalRepository mockRepository;
  late GetAllHospitalsUsecase usecase;

  final tHospitals = [
    HospitalEntity(
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
    ),
  ];

  setUp(() {
    mockRepository = MockHospitalRepository();
    usecase = GetAllHospitalsUsecase(repository: mockRepository);
  });

  test('calls repository.getAllHospitals with passed filters', () async {
    const params = GetAllHospitalsParams(
      city: 'Kathmandu',
      state: 'Bagmati',
      bloodType: 'A+',
      isActive: true,
    );

    when(
      () => mockRepository.getAllHospitals(
        city: any(named: 'city'),
        state: any(named: 'state'),
        bloodType: any(named: 'bloodType'),
        isActive: any(named: 'isActive'),
      ),
    ).thenAnswer((_) async => Right(tHospitals));

    final result = await usecase(params);

    expect(result, Right(tHospitals));
    verify(
      () => mockRepository.getAllHospitals(
        city: 'Kathmandu',
        state: 'Bagmati',
        bloodType: 'A+',
        isActive: true,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('returns Left when repository fails', () async {
    const params = GetAllHospitalsParams(city: 'Pokhara');
    const failure = ApiFailure(message: 'Request failed', statusCode: 500);

    when(
      () => mockRepository.getAllHospitals(
        city: any(named: 'city'),
        state: any(named: 'state'),
        bloodType: any(named: 'bloodType'),
        isActive: any(named: 'isActive'),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final result = await usecase(params);

    expect(result, const Left(failure));
  });

  test('fixture hospital has valid city', () {
    expect(tHospitals.first.address.city, 'Kathmandu');
  });

  test('fixture hospital has valid phone number', () {
    expect(tHospitals.first.phoneNumber, isNotEmpty);
  });

  test('params equality works for identical values', () {
    const p1 = GetAllHospitalsParams(city: 'Kathmandu', state: 'Bagmati');
    const p2 = GetAllHospitalsParams(city: 'Kathmandu', state: 'Bagmati');

    expect(p1, p2);
  });
}
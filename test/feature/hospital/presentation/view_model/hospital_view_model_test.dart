import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/domain/usecases/get_all_hospitals_usecase.dart';
import 'package:lifelink/feature/hospital/domain/usecases/get_hospital_by_id_usecase.dart';
import 'package:lifelink/feature/hospital/domain/usecases/get_hospital_inventory_usecase.dart';
import 'package:lifelink/feature/hospital/presentation/state/hospital_state.dart';
import 'package:lifelink/feature/hospital/presentation/view_model/hospital_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockGetAllHospitalsUsecase extends Mock
    implements GetAllHospitalsUsecase {}

class MockGetHospitalByIdUsecase extends Mock
    implements GetHospitalByIdUsecase {}

class MockGetHospitalInventoryUsecase extends Mock
    implements GetHospitalInventoryUsecase {}

void main() {
  late MockGetAllHospitalsUsecase mockGetAllHospitalsUsecase;
  late MockGetHospitalByIdUsecase mockGetHospitalByIdUsecase;
  late MockGetHospitalInventoryUsecase mockGetHospitalInventoryUsecase;
  late ProviderContainer container;

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
    bloodInventory: const [
      BloodInventoryEntity(bloodType: 'A+', unitsAvailable: 5),
    ],
  );

  const tInventory = [
    BloodInventoryEntity(bloodType: 'O+', unitsAvailable: 10),
  ];

  setUpAll(() {
    registerFallbackValue(const GetAllHospitalsParams());
  });

  setUp(() {
    mockGetAllHospitalsUsecase = MockGetAllHospitalsUsecase();
    mockGetHospitalByIdUsecase = MockGetHospitalByIdUsecase();
    mockGetHospitalInventoryUsecase = MockGetHospitalInventoryUsecase();

    container = ProviderContainer(
      overrides: [
        getAllHospitalsUsecaseProvider.overrideWithValue(
          mockGetAllHospitalsUsecase,
        ),
        getHospitalByIdUsecaseProvider.overrideWithValue(
          mockGetHospitalByIdUsecase,
        ),
        getHospitalInventoryUsecaseProvider.overrideWithValue(
          mockGetHospitalInventoryUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('HospitalViewModel', () {
    test('initial state is HospitalStatus.initial', () {
      final state = container.read(hospitalViewModelProvider);

      expect(state.status, HospitalStatus.initial);
      expect(state.hospitals, isEmpty);
      expect(state.selectedHospital, isNull);
    });

    test('getAllHospitals sets loaded state on success', () async {
      when(() => mockGetAllHospitalsUsecase(any()))
          .thenAnswer((_) async => Right([tHospital]));

      await container.read(hospitalViewModelProvider.notifier).getAllHospitals();
      final state = container.read(hospitalViewModelProvider);

      expect(state.status, HospitalStatus.loaded);
      expect(state.hospitals.length, 1);
      expect(state.hospitals.first.id, 'hospital-1');
      verify(() => mockGetAllHospitalsUsecase(any())).called(1);
    });

    test('getHospitalById sets error state on failure', () async {
      const failure = ApiFailure(message: 'Hospital not found', statusCode: 404);

      when(() => mockGetHospitalByIdUsecase('missing-id'))
          .thenAnswer((_) async => const Left(failure));

      await container
          .read(hospitalViewModelProvider.notifier)
          .getHospitalById('missing-id');
      final state = container.read(hospitalViewModelProvider);

      expect(state.status, HospitalStatus.error);
      expect(state.errorMessage, 'Hospital not found');
    });

    test('getHospitalInventory updates inventory list on success', () async {
      when(() => mockGetHospitalInventoryUsecase('hospital-1'))
          .thenAnswer((_) async => const Right(tInventory));

      await container
          .read(hospitalViewModelProvider.notifier)
          .getHospitalInventory('hospital-1');
      final state = container.read(hospitalViewModelProvider);

      expect(state.inventory, tInventory);
      verify(() => mockGetHospitalInventoryUsecase('hospital-1')).called(1);
    });

    test('clearSelectedHospital clears selectedHospital and inventory', () {
      final notifier = container.read(hospitalViewModelProvider.notifier);

      container.read(hospitalViewModelProvider.notifier).state = HospitalState(
            status: HospitalStatus.loaded,
            selectedHospital: tHospital,
            inventory: tInventory,
          );

      notifier.clearSelectedHospital();
      final state = container.read(hospitalViewModelProvider);

      expect(state.selectedHospital, isNull);
      expect(state.inventory, isEmpty);
    });
  });
}
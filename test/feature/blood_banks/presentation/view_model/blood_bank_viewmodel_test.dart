import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_banks/domain/entities/blood_bank_entity.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_all_blood_banks_usecase.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_blood_bank_by_id_usecase.dart';
import 'package:lifelink/feature/blood_banks/domain/usecases/get_blood_bank_inventory_usecase.dart';
import 'package:lifelink/feature/blood_banks/presentation/state/blood_bank_state.dart';
import 'package:lifelink/feature/blood_banks/presentation/view_model/blood_bank_viewmodel.dart';

class MockGetAllBloodBanksUsecase extends Mock
    implements GetAllBloodBanksUsecase {}

class MockGetBloodBankByIdUsecase extends Mock
    implements GetBloodBankByIdUsecase {}

class MockGetBloodBankInventoryUsecase extends Mock
    implements GetBloodBankInventoryUsecase {}

void main() {
  late MockGetAllBloodBanksUsecase mockGetAllBloodBanksUsecase;
  late MockGetBloodBankByIdUsecase mockGetBloodBankByIdUsecase;
  late MockGetBloodBankInventoryUsecase mockGetBloodBankInventoryUsecase;
  late ProviderContainer container;

  const tAddress = BloodBankAddressEntity(
    street: 'Main Street',
    city: 'Kathmandu',
    state: 'Bagmati',
    zipCode: '44600',
  );

  const tInventory = [
    BloodInventoryEntity(bloodType: 'A+', unitsAvailable: 10),
    BloodInventoryEntity(bloodType: 'B+', unitsAvailable: 5),
  ];

  const tBloodBank = BloodBankEntity(
    id: 'bb-1',
    name: 'Central Blood Bank',
    email: 'bb@test.com',
    phoneNumber: '9800000000',
    address: tAddress,
    bloodInventory: tInventory,
    location: BloodBankLocationEntity(latitude: 27.7172, longitude: 85.3240),
  );

  setUpAll(() {
    registerFallbackValue(
      const GetAllBloodBanksParams(
        city: 'fallback',
        state: 'fallback',
      ),
    );
  });

  setUp(() {
    mockGetAllBloodBanksUsecase = MockGetAllBloodBanksUsecase();
    mockGetBloodBankByIdUsecase = MockGetBloodBankByIdUsecase();
    mockGetBloodBankInventoryUsecase = MockGetBloodBankInventoryUsecase();

    container = ProviderContainer(
      overrides: [
        getAllBloodBanksUsecaseProvider
            .overrideWithValue(mockGetAllBloodBanksUsecase),
        getBloodBankByIdUsecaseProvider
            .overrideWithValue(mockGetBloodBankByIdUsecase),
        getBloodBankInventoryUsecaseProvider
            .overrideWithValue(mockGetBloodBankInventoryUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BloodBankViewModel', () {
    test('initial state is correct', () {
      final state = container.read(bloodBankViewModelProvider);

      expect(state.status, BloodBankStatus.initial);
      expect(state.bloodBanks, isEmpty);
      expect(state.selectedBloodBank, isNull);
      expect(state.inventory, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('getAllBloodBanks success sets loaded state with data', () async {
      when(() => mockGetAllBloodBanksUsecase(any()))
          .thenAnswer((_) async => const Right([tBloodBank]));

      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getAllBloodBanks(city: 'Kathmandu', bloodType: 'A+');

      final state = container.read(bloodBankViewModelProvider);
      expect(state.status, BloodBankStatus.loaded);
      expect(state.bloodBanks, [tBloodBank]);
      verify(() => mockGetAllBloodBanksUsecase(any())).called(1);
    });

    test('getAllBloodBanks failure sets error state', () async {
      const failure = ApiFailure(message: 'Failed to fetch blood banks');
      when(() => mockGetAllBloodBanksUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getAllBloodBanks();

      final state = container.read(bloodBankViewModelProvider);
      expect(state.status, BloodBankStatus.error);
      expect(state.errorMessage, 'Failed to fetch blood banks');
      verify(() => mockGetAllBloodBanksUsecase(any())).called(1);
    });

    test('getAllBloodBanks forwards nearby params', () async {
      GetAllBloodBanksParams? capturedParams;
      when(() => mockGetAllBloodBanksUsecase(any())).thenAnswer((invocation) {
        capturedParams = invocation.positionalArguments.first
            as GetAllBloodBanksParams;
        return Future.value(const Right([tBloodBank]));
      });

      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getAllBloodBanks(
        latitude: 27.7172,
        longitude: 85.3240,
        radiusKm: 25,
      );

      expect(capturedParams?.latitude, 27.7172);
      expect(capturedParams?.longitude, 85.3240);
      expect(capturedParams?.radiusKm, 25);
    });

    test('getBloodBankById success sets selected blood bank and inventory',
        () async {
      when(() => mockGetBloodBankByIdUsecase('bb-1'))
          .thenAnswer((_) async => const Right(tBloodBank));

      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getBloodBankById('bb-1');

      final state = container.read(bloodBankViewModelProvider);
      expect(state.status, BloodBankStatus.loaded);
      expect(state.selectedBloodBank, tBloodBank);
      expect(state.inventory, tInventory);
      verify(() => mockGetBloodBankByIdUsecase('bb-1')).called(1);
    });

    test('getBloodBankById failure sets error state', () async {
      const failure = ApiFailure(message: 'Blood bank not found', statusCode: 404);
      when(() => mockGetBloodBankByIdUsecase('missing-id'))
          .thenAnswer((_) async => const Left(failure));

      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getBloodBankById('missing-id');

      final state = container.read(bloodBankViewModelProvider);
      expect(state.status, BloodBankStatus.error);
      expect(state.errorMessage, 'Blood bank not found');
      verify(() => mockGetBloodBankByIdUsecase('missing-id')).called(1);
    });

    test('getBloodBankInventory success updates inventory only', () async {
      when(() => mockGetBloodBankInventoryUsecase('bb-1'))
          .thenAnswer((_) async => const Right(tInventory));

      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getBloodBankInventory('bb-1');

      final state = container.read(bloodBankViewModelProvider);
      expect(state.inventory, tInventory);
      verify(() => mockGetBloodBankInventoryUsecase('bb-1')).called(1);
    });

    test('getBloodBankInventory failure keeps previous inventory', () async {
      when(() => mockGetBloodBankByIdUsecase('bb-1'))
          .thenAnswer((_) async => const Right(tBloodBank));
      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getBloodBankById('bb-1');

      const failure = ApiFailure(message: 'Inventory error', statusCode: 500);
      when(() => mockGetBloodBankInventoryUsecase('bb-1'))
          .thenAnswer((_) async => const Left(failure));

      await viewModel.getBloodBankInventory('bb-1');

      final state = container.read(bloodBankViewModelProvider);
      expect(state.inventory, tInventory);
      verify(() => mockGetBloodBankInventoryUsecase('bb-1')).called(1);
    });

    test('clearSelectedBloodBank clears selected item and inventory', () async {
      when(() => mockGetBloodBankByIdUsecase('bb-1'))
          .thenAnswer((_) async => const Right(tBloodBank));

      final viewModel = container.read(bloodBankViewModelProvider.notifier);
      await viewModel.getBloodBankById('bb-1');
      viewModel.clearSelectedBloodBank();

      final state = container.read(bloodBankViewModelProvider);
      expect(state.selectedBloodBank, isNull);
      expect(state.inventory, isEmpty);
    });
  });
}
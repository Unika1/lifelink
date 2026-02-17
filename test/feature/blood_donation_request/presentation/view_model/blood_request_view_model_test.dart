import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/create_request_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/delete_request_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/get_all_requests_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/update_request_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/view_model/blood_request_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockGetAllRequestsUsecase extends Mock implements GetAllRequestsUsecase {}

class MockCreateRequestUsecase extends Mock implements CreateRequestUsecase {}

class MockUpdateRequestUsecase extends Mock implements UpdateRequestUsecase {}

class MockDeleteRequestUsecase extends Mock implements DeleteRequestUsecase {}

void main() {
  late MockGetAllRequestsUsecase mockGetAllRequestsUsecase;
  late MockCreateRequestUsecase mockCreateRequestUsecase;
  late MockUpdateRequestUsecase mockUpdateRequestUsecase;
  late MockDeleteRequestUsecase mockDeleteRequestUsecase;
  late ProviderContainer container;

  final tRequest = BloodRequestEntity(
    id: 'req-1',
    hospitalId: 'h-1',
    hospitalName: 'City Hospital',
    patientName: 'Donor One',
    bloodType: 'A+',
    unitsRequested: 1,
  );

  setUpAll(() {
    registerFallbackValue(const GetAllRequestsParams());
    registerFallbackValue(
      BloodRequestEntity(
        hospitalName: 'fallback',
        patientName: 'fallback',
        bloodType: 'A+',
        unitsRequested: 1,
      ),
    );
  });

  setUp(() {
    mockGetAllRequestsUsecase = MockGetAllRequestsUsecase();
    mockCreateRequestUsecase = MockCreateRequestUsecase();
    mockUpdateRequestUsecase = MockUpdateRequestUsecase();
    mockDeleteRequestUsecase = MockDeleteRequestUsecase();

    container = ProviderContainer(
      overrides: [
        getAllRequestsUsecaseProvider.overrideWithValue(mockGetAllRequestsUsecase),
        createRequestUsecaseProvider.overrideWithValue(mockCreateRequestUsecase),
        updateRequestUsecaseProvider.overrideWithValue(mockUpdateRequestUsecase),
        deleteRequestUsecaseProvider.overrideWithValue(mockDeleteRequestUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BloodRequestViewModel', () {
    test('initial state is correct', () {
      final state = container.read(bloodRequestViewModelProvider);
      expect(state.status, BloodRequestStatus.initial);
      expect(state.requests, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
    });

    test('getAllRequests success sets loaded state', () async {
      when(() => mockGetAllRequestsUsecase(any()))
          .thenAnswer((_) async => Right([tRequest]));

      final vm = container.read(bloodRequestViewModelProvider.notifier);
      await vm.getAllRequests(requestedBy: 'u-1');

      final state = container.read(bloodRequestViewModelProvider);
      expect(state.status, BloodRequestStatus.loaded);
      expect(state.requests, [tRequest]);
      verify(() => mockGetAllRequestsUsecase(any())).called(1);
    });

    test('createRequest success prepends request and emits created', () async {
      when(() => mockCreateRequestUsecase(tRequest))
          .thenAnswer((_) async => Right(tRequest));

      final vm = container.read(bloodRequestViewModelProvider.notifier);
      final result = await vm.createRequest(tRequest);

      final state = container.read(bloodRequestViewModelProvider);
      expect(result, isTrue);
      expect(state.status, BloodRequestStatus.created);
      expect(state.requests.first, tRequest);
      expect(state.successMessage, contains('created'));
    });

    test('deleteRequest success removes request', () async {
      when(() => mockGetAllRequestsUsecase(any()))
          .thenAnswer((_) async => Right([tRequest]));
      when(() => mockDeleteRequestUsecase('req-1'))
          .thenAnswer((_) async => const Right(null));

      final vm = container.read(bloodRequestViewModelProvider.notifier);
      await vm.getAllRequests();
      final result = await vm.deleteRequest('req-1');

      final state = container.read(bloodRequestViewModelProvider);
      expect(result, isTrue);
      expect(state.requests, isEmpty);
      expect(state.successMessage, contains('cancelled'));
    });

    test('getAllRequests failure sets error state', () async {
      const failure = ApiFailure(message: 'Failed to load', statusCode: 500);
      when(() => mockGetAllRequestsUsecase(any()))
          .thenAnswer((_) async => const Left(failure));

      final vm = container.read(bloodRequestViewModelProvider.notifier);
      await vm.getAllRequests();

      final state = container.read(bloodRequestViewModelProvider);
      expect(state.status, BloodRequestStatus.error);
      expect(state.errorMessage, 'Failed to load');
    });
  });
}
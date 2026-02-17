import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/create_organ_request_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/delete_organ_request_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/get_all_organ_requests_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/update_organ_request_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/view_model/organ_request_view_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class MockCreateOrganRequestUsecase extends Mock
    implements CreateOrganRequestUsecase {}

class MockGetAllOrganRequestsUsecase extends Mock
    implements GetAllOrganRequestsUsecase {}

class MockUpdateOrganRequestUsecase extends Mock
    implements UpdateOrganRequestUsecase {}

class MockDeleteOrganRequestUsecase extends Mock
    implements DeleteOrganRequestUsecase {}

void main() {
  late MockCreateOrganRequestUsecase mockCreateUsecase;
  late MockGetAllOrganRequestsUsecase mockGetAllUsecase;
  late MockUpdateOrganRequestUsecase mockUpdateUsecase;
  late MockDeleteOrganRequestUsecase mockDeleteUsecase;
  late ProviderContainer container;

  final tCreatedRequest = OrganRequestEntity(
    id: 'organ-1',
    hospitalId: 'hospital-1',
    hospitalName: 'City Hospital',
    donorName: 'Sita Sharma',
    requestedBy: 'user-1',
    status: 'pending',
  );

  setUpAll(() {
    registerFallbackValue(const GetAllOrganRequestsParams());
    registerFallbackValue(
      CreateOrganRequestParams(
        hospitalId: 'hospital-1',
        hospitalName: 'City Hospital',
        donorName: 'Donor',
        reportFile: File('fake-report.pdf'),
      ),
    );
    registerFallbackValue(
      const OrganRequestEntity(
        id: 'organ-1',
        hospitalId: 'hospital-1',
        hospitalName: 'City Hospital',
        donorName: 'Donor',
      ),
    );
  });

  setUp(() {
    mockCreateUsecase = MockCreateOrganRequestUsecase();
    mockGetAllUsecase = MockGetAllOrganRequestsUsecase();
    mockUpdateUsecase = MockUpdateOrganRequestUsecase();
    mockDeleteUsecase = MockDeleteOrganRequestUsecase();

    container = ProviderContainer(
      overrides: [
        createOrganRequestUsecaseProvider.overrideWithValue(mockCreateUsecase),
        getAllOrganRequestsUsecaseProvider.overrideWithValue(mockGetAllUsecase),
        updateOrganRequestUsecaseProvider.overrideWithValue(mockUpdateUsecase),
        deleteOrganRequestUsecaseProvider.overrideWithValue(mockDeleteUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('OrganRequestViewModel', () {
    test('initial state is OrganRequestStatus.initial', () {
      final state = container.read(organRequestViewModelProvider);

      expect(state.status, OrganRequestStatus.initial);
      expect(state.requests, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('getAllRequests sets loaded state on success', () async {
      when(() => mockGetAllUsecase(any()))
          .thenAnswer((_) async => Right([tCreatedRequest]));

      await container.read(organRequestViewModelProvider.notifier).getAllRequests(
            requestedBy: 'user-1',
          );
      final state = container.read(organRequestViewModelProvider);

      expect(state.status, OrganRequestStatus.loaded);
      expect(state.requests.length, 1);
      expect(state.requests.first.id, 'organ-1');
    });

    test('createRequest sets created state and prepends request', () async {
      when(() => mockCreateUsecase(any()))
          .thenAnswer((_) async => Right(tCreatedRequest));

      final success = await container
          .read(organRequestViewModelProvider.notifier)
          .createRequest(
            hospitalId: 'hospital-1',
            hospitalName: 'City Hospital',
            donorName: 'Sita Sharma',
            reportFile: File('fake-report.pdf'),
            requestedBy: 'user-1',
          );

      final state = container.read(organRequestViewModelProvider);
      expect(success, isTrue);
      expect(state.status, OrganRequestStatus.created);
      expect(state.createdRequest?.id, 'organ-1');
      expect(state.requests.first.id, 'organ-1');
    });

    test('deleteRequest returns false and sets error state on failure', () async {
      const failure = ApiFailure(message: 'Delete failed', statusCode: 500);

      when(() => mockDeleteUsecase('organ-1'))
          .thenAnswer((_) async => const Left(failure));

      final success = await container
          .read(organRequestViewModelProvider.notifier)
          .deleteRequest('organ-1');

      final state = container.read(organRequestViewModelProvider);
      expect(success, isFalse);
      expect(state.status, OrganRequestStatus.error);
      expect(state.errorMessage, 'Delete failed');
    });

    test('created request fixture has expected donor', () {
      expect(tCreatedRequest.donorName, 'Sita Sharma');
    });
  });
}
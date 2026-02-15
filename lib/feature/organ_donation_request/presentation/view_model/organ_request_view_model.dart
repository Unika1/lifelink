import 'dart:io';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/create_organ_request_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/delete_organ_request_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/get_all_organ_requests_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/domain/usecases/update_organ_request_usecase.dart';
import 'package:lifelink/feature/organ_donation_request/presentation/state/organ_request_state.dart';
import 'package:riverpod/riverpod.dart';

final organRequestViewModelProvider =
    NotifierProvider<OrganRequestViewModel, OrganRequestState>(
  () => OrganRequestViewModel(),
);

class OrganRequestViewModel extends Notifier<OrganRequestState> {
  late final CreateOrganRequestUsecase _createOrganRequestUsecase;
  late final GetAllOrganRequestsUsecase _getAllOrganRequestsUsecase;
  late final UpdateOrganRequestUsecase _updateOrganRequestUsecase;
  late final DeleteOrganRequestUsecase _deleteOrganRequestUsecase;

  @override
  OrganRequestState build() {
    _createOrganRequestUsecase = ref.read(createOrganRequestUsecaseProvider);
    _getAllOrganRequestsUsecase = ref.read(getAllOrganRequestsUsecaseProvider);
    _updateOrganRequestUsecase = ref.read(updateOrganRequestUsecaseProvider);
    _deleteOrganRequestUsecase = ref.read(deleteOrganRequestUsecaseProvider);
    return const OrganRequestState();
  }

  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {
    state = state.copyWith(
      status: OrganRequestStatus.loading,
      errorMessage: null,
    );

    final params = GetAllOrganRequestsParams(
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      requestedBy: requestedBy,
      status: status,
    );

    final result = await _getAllOrganRequestsUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OrganRequestStatus.error,
          errorMessage: failure.message,
        );
      },
      (requests) {
        state = state.copyWith(
          status: OrganRequestStatus.loaded,
          requests: requests,
        );
      },
    );
  }

  Future<bool> updateRequest(
    String id,
    OrganRequestEntity request,
    {File? reportFile}
  ) async {
    state = state.copyWith(
      status: OrganRequestStatus.loading,
      errorMessage: null,
    );

    final result = await _updateOrganRequestUsecase(
      id,
      request,
      reportFile: reportFile,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrganRequestStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedRequest) {
        final List<OrganRequestEntity> updatedList = [];
        for (final requestItem in state.requests) {
          if (requestItem.id == id) {
            updatedList.add(updatedRequest);
          } else {
            updatedList.add(requestItem);
          }
        }

        state = state.copyWith(
          status: OrganRequestStatus.loaded,
          requests: updatedList,
        );
        return true;
      },
    );
  }

  Future<bool> createRequest({
    required String hospitalId,
    required String hospitalName,
    required String donorName,
    required File reportFile,
    String? notes,
    String? requestedBy,
  }) async {
    state = state.copyWith(
      status: OrganRequestStatus.loading,
      errorMessage: null,
    );

    final params = CreateOrganRequestParams(
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      donorName: donorName,
      reportFile: reportFile,
      notes: notes,
      requestedBy: requestedBy,
    );

    final result = await _createOrganRequestUsecase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrganRequestStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdRequest) {
        state = state.copyWith(
          status: OrganRequestStatus.created,
          createdRequest: createdRequest,
          requests: [createdRequest, ...state.requests],
        );
        return true;
      },
    );
  }

  Future<bool> deleteRequest(String id) async {
    final result = await _deleteOrganRequestUsecase(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrganRequestStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: OrganRequestStatus.loaded,
          requests: state.requests.where((r) => r.id != id).toList(),
        );
        return true;
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      status: OrganRequestStatus.initial,
    );
  }
}

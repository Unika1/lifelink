import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/create_request_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/delete_request_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/get_all_requests_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/domain/usecases/update_request_usecase.dart';
import 'package:lifelink/feature/blood_donation_request/presentation/state/blood_request_state.dart';
import 'package:riverpod/riverpod.dart';

final bloodRequestViewModelProvider =
    NotifierProvider<BloodRequestViewModel, BloodRequestState>(
  () => BloodRequestViewModel(),
);

class BloodRequestViewModel extends Notifier<BloodRequestState> {
  late final GetAllRequestsUsecase _getAllRequestsUsecase;
  late final CreateRequestUsecase _createRequestUsecase;
  late final UpdateRequestUsecase _updateRequestUsecase;
  late final DeleteRequestUsecase _deleteRequestUsecase;

  @override
  BloodRequestState build() {
    _getAllRequestsUsecase = ref.read(getAllRequestsUsecaseProvider);
    _createRequestUsecase = ref.read(createRequestUsecaseProvider);
    _updateRequestUsecase = ref.read(updateRequestUsecaseProvider);
    _deleteRequestUsecase = ref.read(deleteRequestUsecaseProvider);
    return const BloodRequestState();
  }

  Future<void> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? filterStatus,
  }) async {
    state = state.copyWith(
        status: BloodRequestStatus.loading, errorMessage: null);

    final params = GetAllRequestsParams(
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      requestedBy: requestedBy,
      status: filterStatus,
    );

    final result = await _getAllRequestsUsecase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BloodRequestStatus.error,
          errorMessage: failure.message,
        );
      },
      (requests) {
        state = state.copyWith(
          status: BloodRequestStatus.loaded,
          requests: requests,
        );
      },
    );
  }

  Future<bool> createRequest(BloodRequestEntity request) async {
    state = state.copyWith(
        status: BloodRequestStatus.creating, errorMessage: null);

    final result = await _createRequestUsecase(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: BloodRequestStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (createdRequest) {
        state = state.copyWith(
          status: BloodRequestStatus.created,
          requests: [createdRequest, ...state.requests],
          successMessage: 'Blood donation request created successfully!',
        );
        return true;
      },
    );
  }

  Future<bool> updateRequest(String id, BloodRequestEntity request) async {
    state = state.copyWith(
        status: BloodRequestStatus.loading, errorMessage: null);

    final result = await _updateRequestUsecase(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: BloodRequestStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedRequest) {
        final updatedList = state.requests.map((r) {
          return r.id == id ? updatedRequest : r;
        }).toList();

        state = state.copyWith(
          status: BloodRequestStatus.loaded,
          requests: updatedList,
          successMessage: 'Donation request updated successfully',
        );
        return true;
      },
    );
  }

  Future<bool> deleteRequest(String id) async {
    final result = await _deleteRequestUsecase(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: BloodRequestStatus.error,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: BloodRequestStatus.loaded,
          requests:
              state.requests.where((r) => r.id != id).toList(),
          successMessage: 'Donation request cancelled',
        );
        return true;
      },
    );
  }

  void clearMessages() {
    state = BloodRequestState(
      status: state.status,
      requests: state.requests,
      selectedRequest: state.selectedRequest,
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';

enum BloodRequestStatus { initial, loading, loaded, error, creating, created }

class BloodRequestState extends Equatable {
  final BloodRequestStatus status;
  final List<BloodRequestEntity> requests;
  final BloodRequestEntity? selectedRequest;
  final String? errorMessage;
  final String? successMessage;

  const BloodRequestState({
    this.status = BloodRequestStatus.initial,
    this.requests = const [],
    this.selectedRequest,
    this.errorMessage,
    this.successMessage,
  });

  BloodRequestState copyWith({
    BloodRequestStatus? status,
    List<BloodRequestEntity>? requests,
    BloodRequestEntity? selectedRequest,
    String? errorMessage,
    String? successMessage,
  }) {
    return BloodRequestState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        requests,
        selectedRequest,
        errorMessage,
        successMessage,
      ];
}

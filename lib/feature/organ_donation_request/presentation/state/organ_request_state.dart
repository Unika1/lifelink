import 'package:equatable/equatable.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';

enum OrganRequestStatus { initial, loading, loaded, created, error }

class OrganRequestState extends Equatable {
  final OrganRequestStatus status;
  final List<OrganRequestEntity> requests;
  final OrganRequestEntity? createdRequest;
  final String? errorMessage;

  const OrganRequestState({
    this.status = OrganRequestStatus.initial,
    this.requests = const [],
    this.createdRequest,
    this.errorMessage,
  });

  OrganRequestState copyWith({
    OrganRequestStatus? status,
    List<OrganRequestEntity>? requests,
    OrganRequestEntity? createdRequest,
    String? errorMessage,
  }) {
    return OrganRequestState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      createdRequest: createdRequest ?? this.createdRequest,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, requests, createdRequest, errorMessage];
}

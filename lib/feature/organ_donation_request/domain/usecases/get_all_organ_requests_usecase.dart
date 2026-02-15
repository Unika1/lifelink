import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/data/repositories/organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';

final getAllOrganRequestsUsecaseProvider =
    Provider<GetAllOrganRequestsUsecase>((ref) {
  return GetAllOrganRequestsUsecase(
    repository: ref.read(organRequestRepositoryProvider),
  );
});

class GetAllOrganRequestsParams extends Equatable {
  final String? hospitalId;
  final String? hospitalName;
  final String? requestedBy;
  final String? status;

  const GetAllOrganRequestsParams({
    this.hospitalId,
    this.hospitalName,
    this.requestedBy,
    this.status,
  });

  @override
  List<Object?> get props => [hospitalId, hospitalName, requestedBy, status];
}

class GetAllOrganRequestsUsecase {
  final IOrganRequestRepository _repository;

  GetAllOrganRequestsUsecase({required IOrganRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<OrganRequestEntity>>> call(
      GetAllOrganRequestsParams params) async {
    return await _repository.getAllRequests(
      hospitalId: params.hospitalId,
      hospitalName: params.hospitalName,
      requestedBy: params.requestedBy,
      status: params.status,
    );
  }
}

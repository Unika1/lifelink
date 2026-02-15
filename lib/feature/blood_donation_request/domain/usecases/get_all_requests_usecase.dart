import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/data/repositories/blood_request_repository.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:riverpod/riverpod.dart';

final getAllRequestsUsecaseProvider = Provider<GetAllRequestsUsecase>((ref) {
  return GetAllRequestsUsecase(
    repository: ref.read(bloodRequestRepositoryProvider),
  );
});

class GetAllRequestsParams {
  final String? hospitalId;
  final String? hospitalName;
  final String? requestedBy;
  final String? status;

  const GetAllRequestsParams({
    this.hospitalId,
    this.hospitalName,
    this.requestedBy,
    this.status,
  });
}

class GetAllRequestsUsecase {
  final IBloodRequestRepository _repository;

  GetAllRequestsUsecase({required IBloodRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<BloodRequestEntity>>> call(
      GetAllRequestsParams params) {
    return _repository.getAllRequests(
      hospitalId: params.hospitalId,
      hospitalName: params.hospitalName,
      requestedBy: params.requestedBy,
      status: params.status,
    );
  }
}

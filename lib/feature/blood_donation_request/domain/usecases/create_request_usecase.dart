import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/data/repositories/blood_request_repository.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:riverpod/riverpod.dart';

final createRequestUsecaseProvider = Provider<CreateRequestUsecase>((ref) {
  return CreateRequestUsecase(
    repository: ref.read(bloodRequestRepositoryProvider),
  );
});

class CreateRequestUsecase {
  final IBloodRequestRepository _repository;

  CreateRequestUsecase({required IBloodRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, BloodRequestEntity>> call(
      BloodRequestEntity request) {
    return _repository.createRequest(request);
  }
}

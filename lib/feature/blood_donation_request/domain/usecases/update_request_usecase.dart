import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/data/repositories/blood_request_repository.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:riverpod/riverpod.dart';

final updateRequestUsecaseProvider = Provider<UpdateRequestUsecase>((ref) {
  return UpdateRequestUsecase(
    repository: ref.read(bloodRequestRepositoryProvider),
  );
});

class UpdateRequestUsecase {
  final IBloodRequestRepository _repository;

  UpdateRequestUsecase({required IBloodRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, BloodRequestEntity>> call(
      String id, BloodRequestEntity request) {
    return _repository.updateRequest(id, request);
  }
}

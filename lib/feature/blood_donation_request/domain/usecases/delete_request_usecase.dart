import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/data/repositories/blood_request_repository.dart';
import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:riverpod/riverpod.dart';

final deleteRequestUsecaseProvider = Provider<DeleteRequestUsecase>((ref) {
  return DeleteRequestUsecase(
    repository: ref.read(bloodRequestRepositoryProvider),
  );
});

class DeleteRequestUsecase {
  final IBloodRequestRepository _repository;

  DeleteRequestUsecase({required IBloodRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteRequest(id);
  }
}

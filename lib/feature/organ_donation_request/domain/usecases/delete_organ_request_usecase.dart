import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/data/repositories/organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';

final deleteOrganRequestUsecaseProvider =
    Provider<DeleteOrganRequestUsecase>((ref) {
  return DeleteOrganRequestUsecase(
    repository: ref.read(organRequestRepositoryProvider),
  );
});

class DeleteOrganRequestUsecase {
  final IOrganRequestRepository _repository;

  DeleteOrganRequestUsecase({required IOrganRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, void>> call(String id) {
    return _repository.deleteRequest(id);
  }
}

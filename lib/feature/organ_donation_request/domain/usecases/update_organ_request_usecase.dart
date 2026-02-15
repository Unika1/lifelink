import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/data/repositories/organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';

final updateOrganRequestUsecaseProvider =
    Provider<UpdateOrganRequestUsecase>((ref) {
  return UpdateOrganRequestUsecase(
    repository: ref.read(organRequestRepositoryProvider),
  );
});

class UpdateOrganRequestUsecase {
  final IOrganRequestRepository _repository;

  UpdateOrganRequestUsecase({required IOrganRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, OrganRequestEntity>> call(
    String id,
    OrganRequestEntity request,
    {File? reportFile}
  ) {
    return _repository.updateRequest(
      id,
      request,
      reportFile: reportFile,
    );
  }
}

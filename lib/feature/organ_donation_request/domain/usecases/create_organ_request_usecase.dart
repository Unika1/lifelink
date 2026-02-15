import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/data/repositories/organ_request_repository.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';
import 'package:riverpod/riverpod.dart';

final createOrganRequestUsecaseProvider =
    Provider<CreateOrganRequestUsecase>((ref) {
  return CreateOrganRequestUsecase(
    repository: ref.read(organRequestRepositoryProvider),
  );
});

class CreateOrganRequestParams extends Equatable {
  final String hospitalId;
  final String hospitalName;
  final String donorName;
  final File reportFile;
  final String? notes;
  final String? requestedBy;

  const CreateOrganRequestParams({
    required this.hospitalId,
    required this.hospitalName,
    required this.donorName,
    required this.reportFile,
    this.notes,
    this.requestedBy,
  });

  @override
  List<Object?> get props => [
        hospitalId,
        hospitalName,
        donorName,
        reportFile,
        notes,
        requestedBy,
      ];
}

class CreateOrganRequestUsecase {
  final IOrganRequestRepository _repository;

  CreateOrganRequestUsecase({required IOrganRequestRepository repository})
      : _repository = repository;

  Future<Either<Failure, OrganRequestEntity>> call(
      CreateOrganRequestParams params) {
    final request = OrganRequestEntity(
      hospitalId: params.hospitalId,
      hospitalName: params.hospitalName,
      donorName: params.donorName,
      requestedBy: params.requestedBy,
      notes: params.notes,
    );

    return _repository.createRequest(
      request: request,
      reportFile: params.reportFile,
    );
  }
}

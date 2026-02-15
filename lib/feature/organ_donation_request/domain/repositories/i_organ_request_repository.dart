import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';

abstract class IOrganRequestRepository {
  Future<Either<Failure, OrganRequestEntity>> createRequest({
    required OrganRequestEntity request,
    required File reportFile,
  });

  Future<Either<Failure, List<OrganRequestEntity>>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  });

  Future<Either<Failure, OrganRequestEntity>> getRequestById(String id);

  Future<Either<Failure, OrganRequestEntity>> updateRequest(
    String id,
    OrganRequestEntity request,
    {File? reportFile}
  );

  Future<Either<Failure, void>> deleteRequest(String id);
}

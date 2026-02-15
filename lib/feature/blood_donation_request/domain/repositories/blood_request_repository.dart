import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';

abstract class IBloodRequestRepository {
  Future<Either<Failure, List<BloodRequestEntity>>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  });

  Future<Either<Failure, BloodRequestEntity>> getRequestById(String id);

  Future<Either<Failure, BloodRequestEntity>> createRequest(
      BloodRequestEntity request);

  Future<Either<Failure, BloodRequestEntity>> updateRequest(
    String id,
    BloodRequestEntity request,
  );

  Future<Either<Failure, void>> deleteRequest(String id);
}

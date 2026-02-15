import 'package:dartz/dartz.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';

abstract interface class IHospitalRepository {
  /// Get all hospitals with optional filters
  Future<Either<Failure, List<HospitalEntity>>> getAllHospitals({
    String? city,
    String? state,
    String? bloodType,
    bool? isActive,
  });

  /// Get a single hospital by ID
  Future<Either<Failure, HospitalEntity>> getHospitalById(String id);

  /// Get blood inventory for a specific hospital
  Future<Either<Failure, List<BloodInventoryEntity>>> getHospitalInventory(
      String hospitalId);
}

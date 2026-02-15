import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/hospital/data/datasources/hospital_datasource.dart';
import 'package:lifelink/feature/hospital/data/datasources/remote/hospital_remote_datasource.dart';
import 'package:lifelink/feature/hospital/domain/entities/hospital_entity.dart';
import 'package:lifelink/feature/hospital/domain/repositories/i_hospital_repository.dart';
import 'package:riverpod/riverpod.dart';

/// Provider
final hospitalRepositoryProvider = Provider<IHospitalRepository>((ref) {
  return HospitalRepository(
    remoteDataSource: ref.read(hospitalRemoteDataSourceProvider),
  );
});

class HospitalRepository implements IHospitalRepository {
  final IHospitalRemoteDataSource _remoteDataSource;

  HospitalRepository({
    required IHospitalRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<HospitalEntity>>> getAllHospitals({
    String? city,
    String? state,
    String? bloodType,
    bool? isActive,
  }) async {
    try {
      final models = await _remoteDataSource.getAllHospitals(
        city: city,
        state: state,
        bloodType: bloodType,
        isActive: isActive,
      );

      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on DioException catch (e) {
      debugPrint('=== HOSPITAL API ERROR ===');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      return Left(
        ApiFailure(
          message:
              e.response?.data['message']?.toString() ?? 'Failed to load hospitals',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('=== HOSPITAL UNEXPECTED ERROR ===');
      debugPrint('Error: $e');
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HospitalEntity>> getHospitalById(String id) async {
    try {
      final model = await _remoteDataSource.getHospitalById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message']?.toString() ?? 'Hospital not found',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BloodInventoryEntity>>> getHospitalInventory(
      String hospitalId) async {
    try {
      final models =
          await _remoteDataSource.getHospitalInventory(hospitalId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Failed to load inventory',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

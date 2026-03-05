import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/blood_donation_request/data/datasources/blood_request_datasource.dart';
import 'package:lifelink/feature/blood_donation_request/data/datasources/remote/blood_request_remote_datasource.dart';
import 'package:lifelink/feature/blood_donation_request/data/models/blood_request_api_model.dart';
import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';
import 'package:lifelink/feature/blood_donation_request/domain/repositories/blood_request_repository.dart';
import 'package:riverpod/riverpod.dart';

final bloodRequestRepositoryProvider =
    Provider<IBloodRequestRepository>((ref) {
  return BloodRequestRepository(
    remoteDataSource: ref.read(bloodRequestRemoteDataSourceProvider),
  );
});

class BloodRequestRepository implements IBloodRequestRepository {
  final IBloodRequestRemoteDataSource _remoteDataSource;

  BloodRequestRepository({
    required IBloodRequestRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<BloodRequestEntity>>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {
    try {
      debugPrint('[REPO] Fetching blood requests...');
      debugPrint('  - requestedBy: $requestedBy');
      debugPrint('  - hospitalId: $hospitalId');
      debugPrint('  - hospitalName: $hospitalName');
      
      final models = await _remoteDataSource.getAllRequests(
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        requestedBy: requestedBy,
        status: status,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint('[REPO] Blood request API timeout after 20s');
          throw DioException(
            requestOptions: RequestOptions(path: '/blood-requests'),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timeout - backend may be down',
          );
        },
      );
      
      final entities = models.map((model) => model.toEntity()).toList();
      debugPrint('[REPO] Blood requests fetched: ${entities.length}');
      return Right(entities);
    } on DioException catch (e) {
      debugPrint('[REPO] BLOOD REQUEST API ERROR');
      debugPrint('  Type: ${e.type}');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Status: ${e.response?.statusCode}');
      debugPrint('  Response: ${e.response?.data}');
      
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check if backend is running at ${e.requestOptions.baseUrl}';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server took too long to respond';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Check network or backend';
      } else {
        errorMessage = e.response?.data['message']?.toString() ?? 'Failed to load requests';
      }
      
      return Left(
        ApiFailure(
          message: errorMessage,
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('[REPO] BLOOD REQUEST UNEXPECTED ERROR');
      debugPrint('  Error: $e');
      return Left(ApiFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, BloodRequestEntity>> getRequestById(String id) async {
    try {
      final model = await _remoteDataSource.getRequestById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Request not found',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BloodRequestEntity>> createRequest(
      BloodRequestEntity request) async {
    try {
      final apiModel = BloodRequestApiModel.fromEntity(request);
      final result = await _remoteDataSource.createRequest(apiModel);
      return Right(result.toEntity());
    } on DioException catch (e) {
      debugPrint('=== CREATE REQUEST API ERROR ===');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Failed to create request',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('=== CREATE REQUEST UNEXPECTED ERROR ===');
      debugPrint('Error: $e');
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BloodRequestEntity>> updateRequest(
      String id, BloodRequestEntity request) async {
    try {
      final apiModel = BloodRequestApiModel.fromEntity(request);
      final result = await _remoteDataSource.updateRequest(id, apiModel);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Failed to update request',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRequest(String id) async {
    try {
      await _remoteDataSource.deleteRequest(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Failed to delete request',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

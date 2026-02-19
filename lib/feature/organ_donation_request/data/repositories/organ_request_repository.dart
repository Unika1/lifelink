import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/organ_donation_request/data/datasources/organ_request_datasource.dart';
import 'package:lifelink/feature/organ_donation_request/data/datasources/remote/organ_request_remote_datasource.dart';
import 'package:lifelink/feature/organ_donation_request/data/models/organ_request_api_model.dart';
import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';
import 'package:lifelink/feature/organ_donation_request/domain/repositories/i_organ_request_repository.dart';
import 'package:riverpod/riverpod.dart';

String _extractDioMessage(DioException e, String fallback) {
  final data = e.response?.data;
  if (data is Map) {
    final message = data['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }
  } else if (data is String && data.trim().isNotEmpty) {
    return data;
  }

  final dioMessage = e.message;
  if (dioMessage != null && dioMessage.trim().isNotEmpty) {
    return dioMessage;
  }

  return fallback;
}

final organRequestRepositoryProvider = Provider<IOrganRequestRepository>((ref) {
  return OrganRequestRepository(
    remoteDataSource: ref.read(organRequestRemoteDataSourceProvider),
  );
});

class OrganRequestRepository implements IOrganRequestRepository {
  final IOrganRequestRemoteDataSource _remoteDataSource;

  OrganRequestRepository({
    required IOrganRequestRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, OrganRequestEntity>> createRequest({
    required OrganRequestEntity request,
    required File reportFile,
  }) async {
    try {
      final apiModel = OrganRequestApiModel.fromEntity(request);
      final result = await _remoteDataSource.createRequest(
        request: apiModel,
        reportFile: reportFile,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      debugPrint('=== ORGAN REQUEST API ERROR ===');
      debugPrint('Type: ${e.type}');
      debugPrint('Message: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      return Left(
        ApiFailure(
          message: _extractDioMessage(e, 'Failed to create request'),
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('=== ORGAN REQUEST UNEXPECTED ERROR ===');
      debugPrint('Error: $e');
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrganRequestEntity>>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {
    try {
      final results = await _remoteDataSource.getAllRequests(
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        requestedBy: requestedBy,
        status: status,
      );
      return Right(results.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: _extractDioMessage(e, 'Failed to fetch requests'),
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganRequestEntity>> getRequestById(String id) async {
    try {
      final result = await _remoteDataSource.getRequestById(id);
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: _extractDioMessage(e, 'Failed to fetch request'),
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrganRequestEntity>> updateRequest(
    String id,
    OrganRequestEntity request, {
    File? reportFile,
  }) async {
    try {
      final apiModel = OrganRequestApiModel.fromEntity(request);
      final result = await _remoteDataSource.updateRequest(
        id,
        apiModel,
        reportFile: reportFile,
      );
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: _extractDioMessage(e, 'Failed to update request'),
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
          message: _extractDioMessage(e, 'Failed to delete request'),
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

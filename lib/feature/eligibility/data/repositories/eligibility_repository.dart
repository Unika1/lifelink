import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lifelink/core/error/failures.dart';
import 'package:lifelink/feature/eligibility/data/datasources/remote/eligibility_remote_datasource.dart';
import 'package:lifelink/feature/eligibility/data/models/eligibility_api_model.dart';
import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';
import 'package:lifelink/feature/eligibility/domain/repositories/i_eligibility_repository.dart';
import 'package:riverpod/riverpod.dart';

final eligibilityRepositoryProvider =
    Provider<IEligibilityRepository>((ref) {
  return EligibilityRepository(
    remoteDataSource: ref.read(eligibilityRemoteDataSourceProvider),
  );
});

class EligibilityRepository implements IEligibilityRepository {
  final EligibilityRemoteDataSource _remoteDataSource;

  EligibilityRepository({
    required EligibilityRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, EligibilityQuestionnaireEntity>> submitQuestionnaire(
      EligibilityQuestionnaireEntity questionnaire) async {
    try {
      final apiModel =
          EligibilityQuestionnaireApiModel.fromEntity(questionnaire);
      final result = await _remoteDataSource.submitQuestionnaire(apiModel);
      return Right(result.toEntity());
    } on DioException catch (e) {
      debugPrint('=== ELIGIBILITY SUBMIT ERROR ===');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Failed to submit questionnaire',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      debugPrint('=== ELIGIBILITY SUBMIT UNEXPECTED ERROR: $e');
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EligibilityResultEntity>> checkEligibility() async {
    try {
      final result = await _remoteDataSource.checkEligibility();
      return Right(result.toEntity());
    } on DioException catch (e) {
      debugPrint('=== ELIGIBILITY CHECK ERROR ===');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'Failed to check eligibility',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EligibilityQuestionnaireEntity>>
      getQuestionnaire() async {
    try {
      final result = await _remoteDataSource.getQuestionnaire();
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data['message']?.toString() ??
              'No questionnaire found',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}

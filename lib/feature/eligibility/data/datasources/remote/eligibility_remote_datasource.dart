import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/feature/eligibility/data/models/eligibility_api_model.dart';

final eligibilityRemoteDataSourceProvider =
    Provider<EligibilityRemoteDataSource>((ref) {
  return EligibilityRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class EligibilityRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  EligibilityRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  Options _authOptions() {
    final token = _tokenService.getToken();
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<EligibilityQuestionnaireApiModel> submitQuestionnaire(
      EligibilityQuestionnaireApiModel questionnaire) async {
    final response = await _apiClient.post(
      ApiEndpoints.eligibilitySubmit,
      data: questionnaire.toJson(),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return EligibilityQuestionnaireApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.eligibilitySubmit),
      message: response.data['message'] ?? 'Failed to submit questionnaire',
    );
  }

  Future<EligibilityResultApiModel> checkEligibility() async {
    final response = await _apiClient.get(
      ApiEndpoints.eligibilityCheck,
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return EligibilityResultApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.eligibilityCheck),
      message: response.data['message'] ?? 'Failed to check eligibility',
    );
  }

  Future<EligibilityQuestionnaireApiModel> getQuestionnaire() async {
    final response = await _apiClient.get(
      ApiEndpoints.eligibilityQuestionnaire,
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return EligibilityQuestionnaireApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions:
          RequestOptions(path: ApiEndpoints.eligibilityQuestionnaire),
      message: response.data['message'] ?? 'No questionnaire found',
    );
  }
}

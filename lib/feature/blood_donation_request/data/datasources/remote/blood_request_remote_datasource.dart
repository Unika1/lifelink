import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/feature/blood_donation_request/data/datasources/blood_request_datasource.dart';
import 'package:lifelink/feature/blood_donation_request/data/models/blood_request_api_model.dart';

final bloodRequestRemoteDataSourceProvider =
    Provider<IBloodRequestRemoteDataSource>((ref) {
  return BloodRequestRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class BloodRequestRemoteDataSource implements IBloodRequestRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  BloodRequestRemoteDataSource({
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

  @override
  Future<List<BloodRequestApiModel>> getAllRequests({
    String? hospitalId,
    String? hospitalName,
    String? requestedBy,
    String? status,
  }) async {
    final Map<String, dynamic> query = {};
    if (hospitalId != null && hospitalId.isNotEmpty) {
      query['hospitalId'] = hospitalId;
    }
    if (hospitalName != null && hospitalName.isNotEmpty) {
      query['hospitalName'] = hospitalName;
    }
    if (requestedBy != null && requestedBy.isNotEmpty) {
      query['requestedBy'] = requestedBy;
    }
    if (status != null && status.isNotEmpty) query['status'] = status;

    final response = await _apiClient.get(
      ApiEndpoints.bloodRequests,
      query: query.isNotEmpty ? query : null,
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final List<dynamic> dataList = response.data['data'] ?? [];
      return dataList
          .map((json) =>
              BloodRequestApiModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    return [];
  }

  @override
  Future<BloodRequestApiModel> getRequestById(String id) async {
    final response = await _apiClient.get(
      ApiEndpoints.bloodRequestById(id),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return BloodRequestApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.bloodRequestById(id)),
      message: response.data['message'] ?? 'Request not found',
    );
  }

  @override
  Future<BloodRequestApiModel> createRequest(
      BloodRequestApiModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.bloodRequests,
      data: request.toJson(),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return BloodRequestApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.bloodRequests),
      message: response.data['message'] ?? 'Failed to create request',
    );
  }

  @override
  Future<BloodRequestApiModel> updateRequest(
      String id, BloodRequestApiModel request) async {
    final response = await _apiClient.put(
      ApiEndpoints.bloodRequestById(id),
      data: request.toJson(),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return BloodRequestApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.bloodRequestById(id)),
      message: response.data['message'] ?? 'Failed to update request',
    );
  }

  @override
  Future<void> deleteRequest(String id) async {
    final response = await _apiClient.delete(
      ApiEndpoints.bloodRequestById(id),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      return;
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.bloodRequestById(id)),
      message: response.data['message'] ?? 'Failed to delete request',
    );
  }
}

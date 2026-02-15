import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/feature/hospital/data/datasources/hospital_datasource.dart';
import 'package:lifelink/feature/hospital/data/models/hospital_api_model.dart';

/// Provider
final hospitalRemoteDataSourceProvider =
    Provider<IHospitalRemoteDataSource>((ref) {
  return HospitalRemoteDataSource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

/// Implementation
class HospitalRemoteDataSource implements IHospitalRemoteDataSource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  HospitalRemoteDataSource({
    required ApiClient apiClient,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _tokenService = tokenService;

  /// Helper to build auth headers
  Options _authOptions() {
    final token = _tokenService.getToken();
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<List<HospitalApiModel>> getAllHospitals({
    String? city,
    String? state,
    String? bloodType,
    bool? isActive,
  }) async {
    // Build query parameters — only include non-null values
    final Map<String, dynamic> query = {};
    if (city != null && city.isNotEmpty) query['city'] = city;
    if (state != null && state.isNotEmpty) query['state'] = state;
    if (bloodType != null && bloodType.isNotEmpty) {
      query['bloodType'] = bloodType;
    }
    if (isActive != null) query['isActive'] = isActive;

    final response = await _apiClient.get(
      ApiEndpoints.hospitals,
      query: query.isNotEmpty ? query : null,
    );

    if (response.data is Map && response.data['success'] == true) {
      final List<dynamic> dataList = response.data['data'] ?? [];
      return dataList
          .map((json) =>
              HospitalApiModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    return [];
  }

  @override
  Future<HospitalApiModel> getHospitalById(String id) async {
    final response = await _apiClient.get(
      ApiEndpoints.hospitalById(id),
    );

    if (response.data is Map && response.data['success'] == true) {
      final json = Map<String, dynamic>.from(response.data['data']);
      return HospitalApiModel.fromJson(json);
    }

    throw DioException(
      requestOptions: RequestOptions(path: ApiEndpoints.hospitalById(id)),
      message: response.data['message'] ?? 'Hospital not found',
    );
  }

  @override
  Future<List<BloodInventoryApiModel>> getHospitalInventory(
      String hospitalId) async {
    final response = await _apiClient.get(
      ApiEndpoints.hospitalInventory(hospitalId),
      options: _authOptions(),
    );

    if (response.data is Map && response.data['success'] == true) {
      final List<dynamic> dataList = response.data['data'] ?? [];
      return dataList
          .map((json) =>
              BloodInventoryApiModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    return [];
  }
}

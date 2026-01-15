import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/feature/auth/data/models/auth_api_model.dart';

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel?> login(String email, String password);
  Future<void> register(AuthApiModel model);
}

final authRemoteProvider = Provider<IAuthRemoteDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  @override
  Future<void> register(AuthApiModel model) async {
    await _apiClient.post(
      ApiEndpoints.register,
      data: model.toJson(),
    );
    
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        "email": email,
        "password": password,
      },
    );

    final data = response.data;

    // if API returns { user: {...} }
    if (data is Map && data['data'] != null) {
      return AuthApiModel.fromJson(
        Map<String, dynamic>.from(data['data']),
      );
    }

    // if API returns user directly
    return AuthApiModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }
}

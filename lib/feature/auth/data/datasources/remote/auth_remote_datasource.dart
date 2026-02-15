import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifelink/core/api/api_client.dart';
import 'package:lifelink/core/api/api_endpoints.dart';
import 'package:lifelink/core/services/storage/token_service.dart';
import 'package:lifelink/core/services/storage/user_session_service.dart';
import 'package:lifelink/feature/auth/data/datasources/auth_datasource.dart';
import 'package:lifelink/feature/auth/data/models/auth_api_model.dart';

/// Provider
final authRemoteProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

/// Implementation (REMOTE)
class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;

  /// LOGIN
  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        "email": email,
        "password": password,
      },
    );

    // Backend response: { success:true, data:{...user}, token:"..." }
    if (response.data is Map && response.data['success'] == true) {
      final userJson = Map<String, dynamic>.from(response.data['data']);
      final user = AuthApiModel.fromJson(userJson);

      // Save token
      final token = response.data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _tokenService.saveToken(token);
      }

      // Save session with role
      if (user.id != null && user.id!.isNotEmpty) {
        await _userSessionService.setLoggedIn(user.id!, role: user.role);
      }

      return user;
    }

    return null;
  }

  /// REGISTER
  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: user.toJson(),
      );

      // Handle different response formats
      if (response.data is Map) {
        Map<String, dynamic> responseMap = response.data;
        
        // Format 1: { success: true, data: {...user} }
        if (responseMap['success'] == true && responseMap['data'] != null) {
          final data = Map<String, dynamic>.from(responseMap['data']);
          return AuthApiModel.fromJson(data);
        }
        
        // Format 2: Direct user object { _id, firstName, lastName, email, ... }
        if (responseMap.containsKey('_id') || responseMap.containsKey('firstName')) {
          return AuthApiModel.fromJson(responseMap);
        }
        
        // Format 3: Wrapped in 'user' key
        if (responseMap['user'] != null) {
          final data = Map<String, dynamic>.from(responseMap['user']);
          return AuthApiModel.fromJson(data);
        }
      }

      // Fallback: assume registration succeeded
      return user;
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  /// GET USER BY ID (optional)
  @override
  Future<AuthApiModel> getUserById(String authId) {
    throw UnimplementedError();
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await _apiClient.post(
      ApiEndpoints.requestPasswordReset,
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword(token),
      data: {'newPassword': newPassword},
    );
  }
}

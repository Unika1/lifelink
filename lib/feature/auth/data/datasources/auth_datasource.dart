import 'package:lifelink/feature/auth/data/models/auth_api_model.dart';
import 'package:lifelink/feature/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDataSource{
  Future<bool>register(AuthHiveModel model);
  Future<AuthHiveModel?>login(String email,String password);
  Future<AuthHiveModel?>getCurrentUser();
  Future<bool>logout();
}
//repo ko jasto same hunu pardaina aru pani add garna milchha
abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel> getUserById(String authId);
  Future<void> requestPasswordReset(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> changePassword(String token, String currentPassword, String newPassword);
}
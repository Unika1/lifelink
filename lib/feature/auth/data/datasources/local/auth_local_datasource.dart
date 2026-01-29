import 'package:lifelink/core/provider/hive_service_provider.dart';
import 'package:lifelink/core/services/hive/hive_service.dart';
import 'package:lifelink/feature/auth/data/datasources/auth_datasource.dart';
import 'package:lifelink/feature/auth/data/models/auth_hive_model.dart';
import 'package:riverpod/riverpod.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthLocalDataSource{
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService}) : _hiveService = hiveService;

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    return null;
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try{
      final user=await _hiveService.loginUser(email, password);
      return Future.value(user);
    }catch(e){
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try{
      await _hiveService.logoutUser();
      return Future.value(true);
    }catch (e){
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(AuthHiveModel model) async {
    try{
      await _hiveService.registerUser(model);
      return Future.value(true);
    }catch(e){
      return Future.value(false);
    }
  }
}
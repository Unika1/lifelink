import 'package:lifelink/feature/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthDataSource{
  Future<bool>register(AuthHiveModel model);
  Future<AuthHiveModel?>login(String email,String password);
  Future<AuthHiveModel?>getCurrentUser();
  Future<bool>logout();
}
//repo ko jasto same hunu pardaina aru pani add garna milchha
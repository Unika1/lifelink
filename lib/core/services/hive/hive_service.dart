import 'package:hive/hive.dart';
import 'package:lifelink/core/constants/hive_table_constant.dart';
import 'package:lifelink/feature/auth/data/models/auth_hive_model.dart';

class HiveService {
  void _registerAdapter(){
    if(!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)){
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  //open boxes
  Future<void>openBoxes()async{
    _registerAdapter();
    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    }
  }

  //clse boxes
  Future<void>closeBoxes() async{
    if (Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.box<AuthHiveModel>(HiveTableConstant.authTable).close();
    }
  }


  //Auth Query
  Box<AuthHiveModel> get _authBox =>
    Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
    
  Future<AuthHiveModel>registerUser(AuthHiveModel model)async{
      await _authBox.put(model.authId, model);
    return model;
}

//login user
Future<AuthHiveModel?>loginUser(String email, String password) async {
  final users = _authBox.values.where((user) {
    final userPassword = user.password;
      return user.email == email && userPassword != null && userPassword == password;
  });

  if (users.isNotEmpty) return users.first;
    return null;
  }

    //logout 
  Future<void>logoutUser() async{}
  AuthHiveModel?getCurrentUser(String authId){
    return _authBox.get(authId);
  }

}

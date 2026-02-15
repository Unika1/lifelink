import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lifelink/core/constants/hive_table_constant.dart';
import 'package:lifelink/feature/auth/data/models/auth_hive_model.dart';
import 'package:lifelink/feature/profile/data/models/profile_hive_model.dart';

class HiveService {
  void _registerAdapter(){
    if(!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)){
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if(!Hive.isAdapterRegistered(HiveTableConstant.profileTypeId)){
      Hive.registerAdapter(ProfileHiveModelAdapter());
    }
  }

  Future<void> init() async {
    await Hive.initFlutter();
    await openBoxes();
  }

  //open boxes
  Future<void>openBoxes()async{
    _registerAdapter();
    if (!Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    }
    if (!Hive.isBoxOpen(HiveTableConstant.profileTable)) {
      await Hive.openBox<ProfileHiveModel>(HiveTableConstant.profileTable);
    }
  }

  //clse boxes
  Future<void>closeBoxes() async{
    if (Hive.isBoxOpen(HiveTableConstant.authTable)) {
      await Hive.box<AuthHiveModel>(HiveTableConstant.authTable).close();
    }
    if (Hive.isBoxOpen(HiveTableConstant.profileTable)) {
      await Hive.box<ProfileHiveModel>(HiveTableConstant.profileTable).close();
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
  Future<void> logoutUser() async {
    await _authBox.clear();
  }

  //Profile Query
  Box<ProfileHiveModel> get _profileBox =>
    Hive.box<ProfileHiveModel>(HiveTableConstant.profileTable);

  Future<void> cacheProfile(ProfileHiveModel profile) async {
    await _profileBox.put(profile.userId, profile);
  }

  Future<ProfileHiveModel?> getCachedProfile(String userId) async {
    return _profileBox.get(userId);
  }

  Future<void> clearProfile(String userId) async {
    await _profileBox.delete(userId);
  }

  Future<void> updateCachedProfileImage(String userId, String imageUrl) async {
    final profile = _profileBox.get(userId);
    if (profile != null) {
      final updated = ProfileHiveModel(
        userId: profile.userId,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        imageUrl: imageUrl,
        bloodGroup: profile.bloodGroup,
        phoneNumber: profile.phoneNumber,
        emergencyContact: profile.emergencyContact,
      );
      await _profileBox.put(userId, updated);
    }
  }

}

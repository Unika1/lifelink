import 'package:hive/hive.dart';
import 'package:lifelink/core/constants/hive_table_constant.dart';
import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';
part 'auth_hive_model.g.dart';
//dart run build_runner build -d
@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject{
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String role;

  AuthHiveModel({
    String? authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.role = 'donor',
  }) : authId = authId ?? Uuid().v4();

  //From Entity
  factory AuthHiveModel.fromEntity(AuthEntity entity){
    return AuthHiveModel(
      authId: entity.authId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      password: entity.password,
      role: entity.role,
    );
  }
  //To entity
  AuthEntity toEntity(){
    return AuthEntity(
      authId: authId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      role: role,
    );
  }
}

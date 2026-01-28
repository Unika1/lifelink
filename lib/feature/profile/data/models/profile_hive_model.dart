import 'package:hive/hive.dart';
import 'package:lifelink/core/constants/hive_table_constant.dart';
import 'package:lifelink/feature/profile/domain/entities/profile_entity.dart';

part 'profile_hive_model.g.dart';

// run: dart run build_runner build -d
@HiveType(typeId: HiveTableConstant.profileTypeId)
class ProfileHiveModel extends HiveObject {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? imageUrl;

  ProfileHiveModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
  });

  factory ProfileHiveModel.fromEntity(ProfileEntity entity) {
    return ProfileHiveModel(
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      imageUrl: entity.imageUrl,
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      imageUrl: imageUrl,
    );
  }
}

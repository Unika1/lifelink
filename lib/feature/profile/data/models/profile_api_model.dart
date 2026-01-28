import 'package:lifelink/feature/profile/domain/entities/profile_entity.dart';

class ProfileApiModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl;

  ProfileApiModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      userId: (json['_id'] ?? json['id']).toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
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

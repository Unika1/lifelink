import 'package:lifelink/feature/profile/domain/entities/profile_entity.dart';

class ProfileApiModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl;
  final String? bloodGroup;
  final String? phoneNumber;
  final String? emergencyContact;

  ProfileApiModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    this.bloodGroup,
    this.phoneNumber,
    this.emergencyContact,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      userId: (json['_id'] ?? json['id']).toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      emergencyContact: json['emergencyContact']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };

    if (imageUrl != null && imageUrl!.isNotEmpty) map['imageUrl'] = imageUrl;
    if (bloodGroup != null && bloodGroup!.isNotEmpty) {
      map['bloodGroup'] = bloodGroup;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      map['phoneNumber'] = phoneNumber;
    }
    if (emergencyContact != null && emergencyContact!.isNotEmpty) {
      map['emergencyContact'] = emergencyContact;
    }

    return map;
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      imageUrl: imageUrl,
      bloodGroup: bloodGroup,
      phoneNumber: phoneNumber,
      emergencyContact: emergencyContact,
    );
  }

  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      userId: entity.userId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      imageUrl: entity.imageUrl,
      bloodGroup: entity.bloodGroup,
      phoneNumber: entity.phoneNumber,
      emergencyContact: entity.emergencyContact,
    );
  }
}

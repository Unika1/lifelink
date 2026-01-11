import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;

  AuthApiModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: (json['_id'] ?? json['id']) as String?,
      firstName: (json['firstName'] ?? "") as String,
      lastName: (json['lastName'] ?? "") as String,
      email: (json['email'] ?? "") as String,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.authId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      password: entity.password,
    );
  }
}

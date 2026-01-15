import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? confirmPassword;

  AuthApiModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.password,
    );
  }
}

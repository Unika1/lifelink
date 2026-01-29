import 'package:lifelink/feature/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? token;
  final String? imageUrl;
  final String? bloodGroup;

  AuthApiModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.confirmPassword,
    this.token,
    this.imageUrl,
    this.bloodGroup,
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
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'],
      bloodGroup: json['bloodGroup'],
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      token: token,
      imageUrl: imageUrl,
      bloodGroup: bloodGroup,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }
}

import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{
  final String? authId;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl;
  final String? password;
  final String? confirmPassword;
  final String? token;
  final String? bloodGroup;

  AuthEntity({
    this.authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    this.password,
    this.confirmPassword,
    this.token,
    this.bloodGroup,
  });

  @override
  List<Object?> get props => [authId, firstName, lastName, email, password, confirmPassword, token, imageUrl,bloodGroup];

}
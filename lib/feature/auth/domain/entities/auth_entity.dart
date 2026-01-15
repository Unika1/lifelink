import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable{
  final String? authId;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? confirmPassword;

  AuthEntity({
    this.authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [authId, firstName, lastName, email, password, confirmPassword];

}
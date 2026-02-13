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
  final String role; // 'donor', 'hospital', 'admin'

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
    this.role = 'donor',
  });

  bool get isDonor => role == 'donor';
  bool get isHospital => role == 'hospital';
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [authId, firstName, lastName, email, password, confirmPassword, token, imageUrl, bloodGroup, role];

}
import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl; // from backend: "/uploads/xyz.jpg"
  final String? bloodGroup;
  final String? phoneNumber;
  final String? emergencyContact;

  const ProfileEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
    this.bloodGroup,
    this.phoneNumber,
    this.emergencyContact,
  });

  String get fullName => "$firstName $lastName".trim();

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        email,
        imageUrl,
        bloodGroup,
        phoneNumber,
        emergencyContact,
      ];
}

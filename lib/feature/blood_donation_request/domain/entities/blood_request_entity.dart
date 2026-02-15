import 'package:equatable/equatable.dart';

class BloodRequestEntity extends Equatable {
  final String? id;
  final String? hospitalId;
  final String hospitalName;
  final String patientName;
  final String bloodType;
  final int unitsRequested;
  final String status; // pending, approved, rejected, fulfilled
  final String? requestedBy;
  final String? contactPhone;
  final DateTime? neededBy;
  final DateTime? scheduledAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BloodRequestEntity({
    this.id,
    this.hospitalId,
    required this.hospitalName,
    required this.patientName,
    required this.bloodType,
    required this.unitsRequested,
    this.status = 'pending',
    this.requestedBy,
    this.contactPhone,
    this.neededBy,
    this.scheduledAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        hospitalId,
        hospitalName,
        patientName,
        bloodType,
        unitsRequested,
        status,
        requestedBy,
        contactPhone,
        neededBy,
        scheduledAt,
        notes,
        createdAt,
        updatedAt,
      ];
}

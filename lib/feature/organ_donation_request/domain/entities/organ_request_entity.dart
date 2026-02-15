import 'package:equatable/equatable.dart';

class OrganRequestEntity extends Equatable {
  final String? id;
  final String? hospitalId;
  final String hospitalName;
  final String donorName;
  final String? requestedBy;
  final String? reportUrl;
  final String status;
  final DateTime? scheduledAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrganRequestEntity({
    this.id,
    this.hospitalId,
    required this.hospitalName,
    required this.donorName,
    this.requestedBy,
    this.reportUrl,
    this.status = 'pending',
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
        donorName,
        requestedBy,
        reportUrl,
        status,
        scheduledAt,
        notes,
        createdAt,
        updatedAt,
      ];
}

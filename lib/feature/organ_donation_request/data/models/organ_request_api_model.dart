import 'package:lifelink/feature/organ_donation_request/domain/entities/organ_request_entity.dart';

class OrganRequestApiModel {
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

  OrganRequestApiModel({
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

  factory OrganRequestApiModel.fromJson(Map<String, dynamic> json) {
    return OrganRequestApiModel(
      id: json['_id'],
      hospitalId: json['hospitalId'],
      hospitalName: json['hospitalName'] ?? '',
      donorName: json['donorName'] ?? '',
      requestedBy: json['requestedBy'],
      reportUrl: json['reportUrl'],
      status: json['status'] ?? 'pending',
        scheduledAt:
          json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'donorName': donorName,
      'requestedBy': requestedBy,
      'reportUrl': reportUrl,
      'status': status,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'notes': notes,
    };
  }

  OrganRequestEntity toEntity() {
    return OrganRequestEntity(
      id: id,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      donorName: donorName,
      requestedBy: requestedBy,
      reportUrl: reportUrl,
      status: status,
      scheduledAt: scheduledAt,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory OrganRequestApiModel.fromEntity(OrganRequestEntity entity) {
    return OrganRequestApiModel(
      id: entity.id,
      hospitalId: entity.hospitalId,
      hospitalName: entity.hospitalName,
      donorName: entity.donorName,
      requestedBy: entity.requestedBy,
      reportUrl: entity.reportUrl,
      status: entity.status,
      scheduledAt: entity.scheduledAt,
      notes: entity.notes,
    );
  }
}

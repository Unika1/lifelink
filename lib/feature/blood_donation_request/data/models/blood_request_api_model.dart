import 'package:lifelink/feature/blood_donation_request/domain/entities/blood_request_entity.dart';

class BloodRequestApiModel {
  final String? id;
  final String? hospitalId;
  final String hospitalName;
  final String patientName;
  final String bloodType;
  final int unitsRequested;
  final String status;
  final String? requestedBy;
  final String? contactPhone;
  final DateTime? neededBy;
  final DateTime? scheduledAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BloodRequestApiModel({
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'hospitalName': hospitalName,
      'patientName': patientName,
      'bloodType': bloodType,
      'unitsRequested': unitsRequested,
    };

    if (hospitalId != null && hospitalId!.isNotEmpty) {
      map['hospitalId'] = hospitalId;
    }
    if (status.isNotEmpty) {
      map['status'] = status;
    }
    if (requestedBy != null && requestedBy!.isNotEmpty) {
      map['requestedBy'] = requestedBy;
    }
    if (contactPhone != null && contactPhone!.isNotEmpty) {
      map['contactPhone'] = contactPhone;
    }
    if (neededBy != null) {
      map['neededBy'] = neededBy!.toIso8601String();
    }
    if (scheduledAt != null) {
      map['scheduledAt'] = scheduledAt!.toIso8601String();
    }
    if (notes != null && notes!.isNotEmpty) {
      map['notes'] = notes;
    }

    return map;
  }

  factory BloodRequestApiModel.fromJson(Map<String, dynamic> json) {
    return BloodRequestApiModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      hospitalId: json['hospitalId']?.toString(),
      hospitalName: json['hospitalName']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? '',
      bloodType: json['bloodType']?.toString() ?? '',
      unitsRequested: _toInt(json['unitsRequested']),
      status: json['status']?.toString() ?? 'pending',
      requestedBy: json['requestedBy']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      neededBy: _toDateTime(json['neededBy']),
      scheduledAt: _toDateTime(json['scheduledAt']),
      notes: json['notes']?.toString(),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  BloodRequestEntity toEntity() {
    return BloodRequestEntity(
      id: id,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      patientName: patientName,
      bloodType: bloodType,
      unitsRequested: unitsRequested,
      status: status,
      requestedBy: requestedBy,
      contactPhone: contactPhone,
      neededBy: neededBy,
      scheduledAt: scheduledAt,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory BloodRequestApiModel.fromEntity(BloodRequestEntity entity) {
    return BloodRequestApiModel(
      id: entity.id,
      hospitalId: entity.hospitalId,
      hospitalName: entity.hospitalName,
      patientName: entity.patientName,
      bloodType: entity.bloodType,
      unitsRequested: entity.unitsRequested,
      status: entity.status,
      requestedBy: entity.requestedBy,
      contactPhone: entity.contactPhone,
      neededBy: entity.neededBy,
      scheduledAt: entity.scheduledAt,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

import 'package:lifelink/feature/eligibility/domain/entities/eligibility_entity.dart';

class EligibilityQuestionnaireApiModel {
  final String? id;
  final String? userId;
  final int age;
  final double weight;
  final String gender;
  final DateTime? lastDonationDate;
  final int totalDonationsCount;
  final bool hasBloodPressure;
  final bool hasDiabetes;
  final bool hasHeartDisease;
  final bool hasCancer;
  final bool hasHepatitis;
  final bool hasHIV;
  final bool hasTuberculosis;
  final bool recentTravel;
  final List<String> travelCountries;
  final bool takingMedications;
  final List<String> medications;
  final bool activeInfection;
  final String? infectionDetails;
  final bool? isPregnant;
  final bool? isBreastfeeding;
  final bool hasRecentTattoo;
  final DateTime? tattooDate;
  final bool hasRecentPiercing;
  final DateTime? piercingDate;
  final bool hadBloodTransfusion;
  final DateTime? transfusionDate;
  final String? additionalNotes;

  EligibilityQuestionnaireApiModel({
    this.id,
    this.userId,
    required this.age,
    required this.weight,
    required this.gender,
    this.lastDonationDate,
    this.totalDonationsCount = 0,
    this.hasBloodPressure = false,
    this.hasDiabetes = false,
    this.hasHeartDisease = false,
    this.hasCancer = false,
    this.hasHepatitis = false,
    this.hasHIV = false,
    this.hasTuberculosis = false,
    this.recentTravel = false,
    this.travelCountries = const [],
    this.takingMedications = false,
    this.medications = const [],
    this.activeInfection = false,
    this.infectionDetails,
    this.isPregnant,
    this.isBreastfeeding,
    this.hasRecentTattoo = false,
    this.tattooDate,
    this.hasRecentPiercing = false,
    this.piercingDate,
    this.hadBloodTransfusion = false,
    this.transfusionDate,
    this.additionalNotes,
  });

  factory EligibilityQuestionnaireApiModel.fromJson(
      Map<String, dynamic> json) {
    return EligibilityQuestionnaireApiModel(
      id: json['_id']?.toString(),
      userId: json['userId']?.toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      gender: json['gender']?.toString() ?? 'male',
      lastDonationDate: json['lastDonationDate'] != null
          ? DateTime.tryParse(json['lastDonationDate'].toString())
          : null,
      totalDonationsCount:
          (json['totalDonationsCount'] as num?)?.toInt() ?? 0,
      hasBloodPressure: json['hasBloodPressure'] == true,
      hasDiabetes: json['hasDiabetes'] == true,
      hasHeartDisease: json['hasHeartDisease'] == true,
      hasCancer: json['hasCancer'] == true,
      hasHepatitis: json['hasHepatitis'] == true,
      hasHIV: json['hasHIV'] == true,
      hasTuberculosis: json['hasTuberculosis'] == true,
      recentTravel: json['recentTravel'] == true,
      travelCountries: (json['travelCountries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      takingMedications: json['takingMedications'] == true,
      medications: (json['medications'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      activeInfection: json['activeInfection'] == true,
      infectionDetails: json['infectionDetails']?.toString(),
      isPregnant: json['isPregnant'] as bool?,
      isBreastfeeding: json['isBreastfeeding'] as bool?,
      hasRecentTattoo: json['hasRecentTattoo'] == true,
      tattooDate: json['tattooDate'] != null
          ? DateTime.tryParse(json['tattooDate'].toString())
          : null,
      hasRecentPiercing: json['hasRecentPiercing'] == true,
      piercingDate: json['piercingDate'] != null
          ? DateTime.tryParse(json['piercingDate'].toString())
          : null,
      hadBloodTransfusion: json['hadBloodTransfusion'] == true,
      transfusionDate: json['transfusionDate'] != null
          ? DateTime.tryParse(json['transfusionDate'].toString())
          : null,
      additionalNotes: json['additionalNotes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'age': age,
      'weight': weight,
      'gender': gender,
      'hasBloodPressure': hasBloodPressure,
      'hasDiabetes': hasDiabetes,
      'hasHeartDisease': hasHeartDisease,
      'hasCancer': hasCancer,
      'hasHepatitis': hasHepatitis,
      'hasHIV': hasHIV,
      'hasTuberculosis': hasTuberculosis,
      'recentTravel': recentTravel,
      'takingMedications': takingMedications,
      'activeInfection': activeInfection,
      'hasRecentTattoo': hasRecentTattoo,
      'hasRecentPiercing': hasRecentPiercing,
      'hadBloodTransfusion': hadBloodTransfusion,
    };

    if (lastDonationDate != null) {
      map['lastDonationDate'] = lastDonationDate!.toIso8601String();
    }
    if (travelCountries.isNotEmpty) map['travelCountries'] = travelCountries;
    if (medications.isNotEmpty) map['medications'] = medications;
    if (infectionDetails != null) map['infectionDetails'] = infectionDetails;
    if (isPregnant != null) map['isPregnant'] = isPregnant;
    if (isBreastfeeding != null) map['isBreastfeeding'] = isBreastfeeding;
    if (tattooDate != null) {
      map['tattooDate'] = tattooDate!.toIso8601String();
    }
    if (piercingDate != null) {
      map['piercingDate'] = piercingDate!.toIso8601String();
    }
    if (transfusionDate != null) {
      map['transfusionDate'] = transfusionDate!.toIso8601String();
    }
    if (additionalNotes != null && additionalNotes!.isNotEmpty) {
      map['additionalNotes'] = additionalNotes;
    }

    return map;
  }

  EligibilityQuestionnaireEntity toEntity() {
    return EligibilityQuestionnaireEntity(
      id: id,
      userId: userId,
      age: age,
      weight: weight,
      gender: gender,
      lastDonationDate: lastDonationDate,
      totalDonationsCount: totalDonationsCount,
      hasBloodPressure: hasBloodPressure,
      hasDiabetes: hasDiabetes,
      hasHeartDisease: hasHeartDisease,
      hasCancer: hasCancer,
      hasHepatitis: hasHepatitis,
      hasHIV: hasHIV,
      hasTuberculosis: hasTuberculosis,
      recentTravel: recentTravel,
      travelCountries: travelCountries,
      takingMedications: takingMedications,
      medications: medications,
      activeInfection: activeInfection,
      infectionDetails: infectionDetails,
      isPregnant: isPregnant,
      isBreastfeeding: isBreastfeeding,
      hasRecentTattoo: hasRecentTattoo,
      tattooDate: tattooDate,
      hasRecentPiercing: hasRecentPiercing,
      piercingDate: piercingDate,
      hadBloodTransfusion: hadBloodTransfusion,
      transfusionDate: transfusionDate,
      additionalNotes: additionalNotes,
    );
  }

  static EligibilityQuestionnaireApiModel fromEntity(
      EligibilityQuestionnaireEntity entity) {
    return EligibilityQuestionnaireApiModel(
      id: entity.id,
      userId: entity.userId,
      age: entity.age,
      weight: entity.weight,
      gender: entity.gender,
      lastDonationDate: entity.lastDonationDate,
      totalDonationsCount: entity.totalDonationsCount,
      hasBloodPressure: entity.hasBloodPressure,
      hasDiabetes: entity.hasDiabetes,
      hasHeartDisease: entity.hasHeartDisease,
      hasCancer: entity.hasCancer,
      hasHepatitis: entity.hasHepatitis,
      hasHIV: entity.hasHIV,
      hasTuberculosis: entity.hasTuberculosis,
      recentTravel: entity.recentTravel,
      travelCountries: entity.travelCountries,
      takingMedications: entity.takingMedications,
      medications: entity.medications,
      activeInfection: entity.activeInfection,
      infectionDetails: entity.infectionDetails,
      isPregnant: entity.isPregnant,
      isBreastfeeding: entity.isBreastfeeding,
      hasRecentTattoo: entity.hasRecentTattoo,
      tattooDate: entity.tattooDate,
      hasRecentPiercing: entity.hasRecentPiercing,
      piercingDate: entity.piercingDate,
      hadBloodTransfusion: entity.hadBloodTransfusion,
      transfusionDate: entity.transfusionDate,
      additionalNotes: entity.additionalNotes,
    );
  }
}

class EligibilityResultApiModel {
  final bool eligible;
  final int score;
  final List<String> reasons;
  final DateTime? nextEligibleDate;
  final String message;
  final DateTime checkedAt;

  EligibilityResultApiModel({
    required this.eligible,
    required this.score,
    this.reasons = const [],
    this.nextEligibleDate,
    required this.message,
    required this.checkedAt,
  });

  factory EligibilityResultApiModel.fromJson(Map<String, dynamic> json) {
    return EligibilityResultApiModel(
      eligible: json['eligible'] == true,
      score: (json['score'] as num?)?.toInt() ?? 0,
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      nextEligibleDate: json['nextEligibleDate'] != null
          ? DateTime.tryParse(json['nextEligibleDate'].toString())
          : null,
      message: json['message']?.toString() ?? '',
      checkedAt: DateTime.tryParse(json['checkedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'eligible': eligible,
      'score': score,
      'reasons': reasons,
      'message': message,
      'checkedAt': checkedAt.toIso8601String(),
    };

    if (nextEligibleDate != null) {
      map['nextEligibleDate'] = nextEligibleDate!.toIso8601String();
    }

    return map;
  }

  EligibilityResultEntity toEntity() {
    return EligibilityResultEntity(
      eligible: eligible,
      score: score,
      reasons: reasons,
      nextEligibleDate: nextEligibleDate,
      message: message,
      checkedAt: checkedAt,
    );
  }

  factory EligibilityResultApiModel.fromEntity(EligibilityResultEntity entity) {
    return EligibilityResultApiModel(
      eligible: entity.eligible,
      score: entity.score,
      reasons: entity.reasons,
      nextEligibleDate: entity.nextEligibleDate,
      message: entity.message,
      checkedAt: entity.checkedAt,
    );
  }
}

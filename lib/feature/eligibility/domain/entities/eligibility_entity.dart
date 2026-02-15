import 'package:equatable/equatable.dart';

class EligibilityQuestionnaireEntity extends Equatable {
  final String? id;
  final String? userId;
  final int age;
  final double weight;
  final String gender; // male, female, other
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

  const EligibilityQuestionnaireEntity({
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

  @override
  List<Object?> get props => [
        id, userId, age, weight, gender, lastDonationDate,
        totalDonationsCount, hasBloodPressure, hasDiabetes,
        hasHeartDisease, hasCancer, hasHepatitis, hasHIV,
        hasTuberculosis, recentTravel, travelCountries,
        takingMedications, medications, activeInfection,
        infectionDetails, isPregnant, isBreastfeeding,
        hasRecentTattoo, tattooDate, hasRecentPiercing,
        piercingDate, hadBloodTransfusion, transfusionDate,
        additionalNotes,
      ];
}

class EligibilityResultEntity extends Equatable {
  final bool eligible;
  final int score;
  final List<String> reasons;
  final DateTime? nextEligibleDate;
  final String message;
  final DateTime checkedAt;

  const EligibilityResultEntity({
    required this.eligible,
    required this.score,
    this.reasons = const [],
    this.nextEligibleDate,
    required this.message,
    required this.checkedAt,
  });

  @override
  List<Object?> get props =>
      [eligible, score, reasons, nextEligibleDate, message, checkedAt];
}

import 'package:equatable/equatable.dart';

class PetHealthEntity extends Equatable {
  final String id;
  final String petId;
  final double? weight;
  final Map<String, dynamic>? weightHistory;

  // New dynamic health system fields
  final Map<String, dynamic> healthParameters;
  final String healthScore;
  final DateTime? lastScoredAt;

  // Legacy fields - kept for backward compatibility during migration
  final String? vaccinationStatus;
  final DateTime? lastVaccinationDate;
  final DateTime? nextVaccinationDate;
  final String? healthNotes;
  final List<String>? medicalConditions;
  final List<String>? allergies;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const PetHealthEntity({
    required this.id,
    required this.petId,
    this.weight,
    this.weightHistory,
    this.healthParameters = const {},
    this.healthScore = 'healthy',
    this.lastScoredAt,
    this.vaccinationStatus,
    this.lastVaccinationDate,
    this.nextVaccinationDate,
    this.healthNotes,
    this.medicalConditions,
    this.allergies,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isHealthy => healthScore == 'healthy';
  bool get needsAttention => healthScore == 'needs_attention';

  // Legacy getters - kept for backward compatibility
  bool get hasAllergies => allergies != null && allergies!.isNotEmpty;

  bool get hasMedicalConditions =>
      medicalConditions != null && medicalConditions!.isNotEmpty;

  bool get needsVaccination {
    if (nextVaccinationDate == null) return false;
    final now = DateTime.now();
    return nextVaccinationDate!.isBefore(now) ||
        nextVaccinationDate!.difference(now).inDays <= 7;
  }

  // Helper methods for health parameters
  T? getParameter<T>(String key) {
    final value = healthParameters[key];
    if (value == null) return null;
    return value as T;
  }

  bool getBoolParameter(String key, {bool defaultValue = false}) {
    return getParameter<bool>(key) ?? defaultValue;
  }

  String? getStringParameter(String key) {
    return getParameter<String>(key);
  }

  DateTime? getDateParameter(String key) {
    final value = healthParameters[key];
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  PetHealthEntity copyWith({
    String? id,
    String? petId,
    double? weight,
    Map<String, dynamic>? weightHistory,
    Map<String, dynamic>? healthParameters,
    String? healthScore,
    DateTime? lastScoredAt,
    String? vaccinationStatus,
    DateTime? lastVaccinationDate,
    DateTime? nextVaccinationDate,
    String? healthNotes,
    List<String>? medicalConditions,
    List<String>? allergies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetHealthEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      weight: weight ?? this.weight,
      weightHistory: weightHistory ?? this.weightHistory,
      healthParameters: healthParameters ?? this.healthParameters,
      healthScore: healthScore ?? this.healthScore,
      lastScoredAt: lastScoredAt ?? this.lastScoredAt,
      vaccinationStatus: vaccinationStatus ?? this.vaccinationStatus,
      lastVaccinationDate: lastVaccinationDate ?? this.lastVaccinationDate,
      nextVaccinationDate: nextVaccinationDate ?? this.nextVaccinationDate,
      healthNotes: healthNotes ?? this.healthNotes,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petId,
    weight,
    weightHistory,
    healthParameters,
    healthScore,
    lastScoredAt,
    vaccinationStatus,
    lastVaccinationDate,
    nextVaccinationDate,
    healthNotes,
    medicalConditions,
    allergies,
    createdAt,
    updatedAt,
  ];
}

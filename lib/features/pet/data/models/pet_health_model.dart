import 'dart:convert';
import '../../domain/entities/pet_health_entity.dart';

class PetHealthModel extends PetHealthEntity {
  const PetHealthModel({
    required super.id,
    required super.petId,
    super.weight,
    super.weightHistory,
    super.healthParameters = const {},
    super.healthScore = 'healthy',
    super.lastScoredAt,
    super.vaccinationStatus,
    super.lastVaccinationDate,
    super.nextVaccinationDate,
    super.healthNotes,
    super.medicalConditions,
    super.allergies,
    required super.createdAt,
    super.updatedAt,
  });

  factory PetHealthModel.fromJson(Map<String, dynamic> json) {
    // Parse health_parameters from JSONB
    Map<String, dynamic> healthParams = {};
    if (json['health_parameters'] != null) {
      if (json['health_parameters'] is String) {
        healthParams =
            jsonDecode(json['health_parameters'] as String)
                as Map<String, dynamic>;
      } else if (json['health_parameters'] is Map) {
        healthParams = Map<String, dynamic>.from(
          json['health_parameters'] as Map,
        );
      }
    }

    return PetHealthModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      weightHistory: json['weight_history'] as Map<String, dynamic>?,
      healthParameters: healthParams,
      healthScore: json['health_score'] as String? ?? 'healthy',
      lastScoredAt: json['last_scored_at'] != null
          ? DateTime.parse(json['last_scored_at'] as String)
          : null,
      vaccinationStatus: json['vaccination_status'] as String?,
      lastVaccinationDate: json['last_vaccination_date'] != null
          ? DateTime.parse(json['last_vaccination_date'] as String)
          : null,
      nextVaccinationDate: json['next_vaccination_date'] != null
          ? DateTime.parse(json['next_vaccination_date'] as String)
          : null,
      healthNotes: json['health_notes'] as String?,
      medicalConditions: json['medical_conditions'] != null
          ? List<String>.from(json['medical_conditions'] as List)
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'weight': weight,
      'weight_history': weightHistory != null
          ? jsonEncode(weightHistory)
          : null,
      'health_parameters': healthParameters.isNotEmpty
          ? healthParameters
          : null,
      'health_score': healthScore,
      'last_scored_at': lastScoredAt?.toIso8601String(),
      'vaccination_status': vaccinationStatus,
      'last_vaccination_date': lastVaccinationDate?.toIso8601String(),
      'next_vaccination_date': nextVaccinationDate?.toIso8601String(),
      'health_notes': healthNotes,
      'medical_conditions': medicalConditions,
      'allergies': allergies,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PetHealthEntity toEntity() {
    return PetHealthEntity(
      id: id,
      petId: petId,
      weight: weight,
      weightHistory: weightHistory,
      healthParameters: healthParameters,
      healthScore: healthScore,
      lastScoredAt: lastScoredAt,
      vaccinationStatus: vaccinationStatus,
      lastVaccinationDate: lastVaccinationDate,
      nextVaccinationDate: nextVaccinationDate,
      healthNotes: healthNotes,
      medicalConditions: medicalConditions,
      allergies: allergies,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

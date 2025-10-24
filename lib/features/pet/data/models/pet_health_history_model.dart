import '../../domain/entities/pet_health_history_entity.dart';

class PetHealthHistoryModel extends PetHealthHistoryEntity {
  const PetHealthHistoryModel({
    required super.id,
    required super.petId,
    required super.parameterKey,
    super.oldValue,
    super.newValue,
    required super.changedAt,
    super.changedBy,
    super.notes,
  });

  factory PetHealthHistoryModel.fromJson(Map<String, dynamic> json) {
    return PetHealthHistoryModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      parameterKey: json['parameter_key'] as String,
      oldValue: json['old_value'],
      newValue: json['new_value'],
      changedAt: DateTime.parse(json['changed_at'] as String),
      changedBy: json['changed_by'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'parameter_key': parameterKey,
      'old_value': oldValue,
      'new_value': newValue,
      'changed_at': changedAt.toIso8601String(),
      'changed_by': changedBy,
      'notes': notes,
    };
  }

  PetHealthHistoryEntity toEntity() {
    return PetHealthHistoryEntity(
      id: id,
      petId: petId,
      parameterKey: parameterKey,
      oldValue: oldValue,
      newValue: newValue,
      changedAt: changedAt,
      changedBy: changedBy,
      notes: notes,
    );
  }
}

import '../../domain/entities/pet_schedule_entity.dart';

class PetScheduleModel extends PetScheduleEntity {
  const PetScheduleModel({
    required super.id,
    required super.petId,
    required super.scheduleTypeId,
    required super.scheduledAt,
    super.completedAt,
    super.notes,
    required super.status,
    super.recurringPatternId,
    required super.createdAt,
    super.updatedAt,
    super.scheduleTypeName,
    super.scheduleTypeIcon,
    super.scheduleTypeColor,
  });

  factory PetScheduleModel.fromJson(Map<String, dynamic> json) {
    return PetScheduleModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      scheduleTypeId: json['schedule_type_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'scheduled',
      recurringPatternId: json['recurring_pattern_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      scheduleTypeName: json['schedule_type_name'] as String?,
      scheduleTypeIcon: json['schedule_type_icon'] as String?,
      scheduleTypeColor: json['schedule_type_color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'schedule_type_id': scheduleTypeId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'status': status,
      'recurring_pattern_id': recurringPatternId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PetScheduleEntity toEntity() {
    return PetScheduleEntity(
      id: id,
      petId: petId,
      scheduleTypeId: scheduleTypeId,
      scheduledAt: scheduledAt,
      completedAt: completedAt,
      notes: notes,
      status: status,
      recurringPatternId: recurringPatternId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      scheduleTypeName: scheduleTypeName,
      scheduleTypeIcon: scheduleTypeIcon,
      scheduleTypeColor: scheduleTypeColor,
    );
  }
}

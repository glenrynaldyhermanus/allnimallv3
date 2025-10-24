import '../../domain/entities/schedule_type_entity.dart';

class ScheduleTypeModel extends ScheduleTypeEntity {
  const ScheduleTypeModel({
    required super.id,
    required super.name,
    super.description,
    super.icon,
    super.color,
    required super.isRecurring,
    required super.defaultDurationMinutes,
    required super.createdAt,
    super.updatedAt,
  });

  factory ScheduleTypeModel.fromJson(Map<String, dynamic> json) {
    return ScheduleTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      defaultDurationMinutes: json['default_duration_minutes'] as int? ?? 60,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'is_recurring': isRecurring,
      'default_duration_minutes': defaultDurationMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ScheduleTypeEntity toEntity() {
    return ScheduleTypeEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
      color: color,
      isRecurring: isRecurring,
      defaultDurationMinutes: defaultDurationMinutes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

import '../../domain/entities/recurring_pattern_entity.dart';

class RecurringPatternModel extends RecurringPatternEntity {
  const RecurringPatternModel({
    required super.id,
    required super.patternType,
    required super.intervalValue,
    super.endDate,
    required super.isActive,
    required super.createdAt,
    super.updatedAt,
  });

  factory RecurringPatternModel.fromJson(Map<String, dynamic> json) {
    return RecurringPatternModel(
      id: json['id'] as String,
      patternType: json['pattern_type'] as String,
      intervalValue: json['interval_value'] as int,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pattern_type': patternType,
      'interval_value': intervalValue,
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  RecurringPatternEntity toEntity() {
    return RecurringPatternEntity(
      id: id,
      patternType: patternType,
      intervalValue: intervalValue,
      endDate: endDate,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

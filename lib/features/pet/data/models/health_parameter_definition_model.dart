import '../../domain/entities/health_parameter_definition_entity.dart';

class HealthParameterDefinitionModel extends HealthParameterDefinitionEntity {
  const HealthParameterDefinitionModel({
    required super.id,
    required super.petCategoryId,
    required super.parameterKey,
    required super.parameterNameId,
    required super.parameterNameEn,
    required super.parameterType,
    required super.isRequired,
    required super.affectsHealthScore,
    required super.displayOrder,
    super.icon,
    super.color,
    super.description,
    required super.createdAt,
    super.updatedAt,
  });

  factory HealthParameterDefinitionModel.fromJson(Map<String, dynamic> json) {
    return HealthParameterDefinitionModel(
      id: json['id'] as String,
      petCategoryId: json['pet_category_id'] as String,
      parameterKey: json['parameter_key'] as String,
      parameterNameId: json['parameter_name_id'] as String,
      parameterNameEn: json['parameter_name_en'] as String,
      parameterType: json['parameter_type'] as String,
      isRequired: json['is_required'] as bool? ?? false,
      affectsHealthScore: json['affects_health_score'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_category_id': petCategoryId,
      'parameter_key': parameterKey,
      'parameter_name_id': parameterNameId,
      'parameter_name_en': parameterNameEn,
      'parameter_type': parameterType,
      'is_required': isRequired,
      'affects_health_score': affectsHealthScore,
      'display_order': displayOrder,
      'icon': icon,
      'color': color,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  HealthParameterDefinitionEntity toEntity() {
    return HealthParameterDefinitionEntity(
      id: id,
      petCategoryId: petCategoryId,
      parameterKey: parameterKey,
      parameterNameId: parameterNameId,
      parameterNameEn: parameterNameEn,
      parameterType: parameterType,
      isRequired: isRequired,
      affectsHealthScore: affectsHealthScore,
      displayOrder: displayOrder,
      icon: icon,
      color: color,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

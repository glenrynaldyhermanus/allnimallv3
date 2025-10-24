import 'package:equatable/equatable.dart';

class HealthParameterDefinitionEntity extends Equatable {
  final String id;
  final String petCategoryId;
  final String parameterKey;
  final String parameterNameId;
  final String parameterNameEn;
  final String parameterType;
  final bool isRequired;
  final bool affectsHealthScore;
  final int displayOrder;
  final String? icon;
  final String? color;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HealthParameterDefinitionEntity({
    required this.id,
    required this.petCategoryId,
    required this.parameterKey,
    required this.parameterNameId,
    required this.parameterNameEn,
    required this.parameterType,
    required this.isRequired,
    required this.affectsHealthScore,
    required this.displayOrder,
    this.icon,
    this.color,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isBoolean => parameterType == 'boolean';
  bool get isDate => parameterType == 'date';
  bool get isText => parameterType == 'text';
  bool get isNumber => parameterType == 'number';
  bool get isSelect => parameterType == 'select';

  HealthParameterDefinitionEntity copyWith({
    String? id,
    String? petCategoryId,
    String? parameterKey,
    String? parameterNameId,
    String? parameterNameEn,
    String? parameterType,
    bool? isRequired,
    bool? affectsHealthScore,
    int? displayOrder,
    String? icon,
    String? color,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthParameterDefinitionEntity(
      id: id ?? this.id,
      petCategoryId: petCategoryId ?? this.petCategoryId,
      parameterKey: parameterKey ?? this.parameterKey,
      parameterNameId: parameterNameId ?? this.parameterNameId,
      parameterNameEn: parameterNameEn ?? this.parameterNameEn,
      parameterType: parameterType ?? this.parameterType,
      isRequired: isRequired ?? this.isRequired,
      affectsHealthScore: affectsHealthScore ?? this.affectsHealthScore,
      displayOrder: displayOrder ?? this.displayOrder,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petCategoryId,
    parameterKey,
    parameterNameId,
    parameterNameEn,
    parameterType,
    isRequired,
    affectsHealthScore,
    displayOrder,
    icon,
    color,
    description,
    createdAt,
    updatedAt,
  ];
}

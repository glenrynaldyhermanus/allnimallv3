import 'package:equatable/equatable.dart';

class ScheduleTypeEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final bool isRecurring;
  final int defaultDurationMinutes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ScheduleTypeEntity({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.isRecurring,
    required this.defaultDurationMinutes,
    required this.createdAt,
    this.updatedAt,
  });

  ScheduleTypeEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    bool? isRecurring,
    int? defaultDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleTypeEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isRecurring: isRecurring ?? this.isRecurring,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    icon,
    color,
    isRecurring,
    defaultDurationMinutes,
    createdAt,
    updatedAt,
  ];
}

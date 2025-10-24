import 'package:equatable/equatable.dart';

class RecurringPatternEntity extends Equatable {
  final String id;
  final String patternType; // daily, weekly, monthly, yearly
  final int intervalValue;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RecurringPatternEntity({
    required this.id,
    required this.patternType,
    required this.intervalValue,
    this.endDate,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  RecurringPatternEntity copyWith({
    String? id,
    String? patternType,
    int? intervalValue,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringPatternEntity(
      id: id ?? this.id,
      patternType: patternType ?? this.patternType,
      intervalValue: intervalValue ?? this.intervalValue,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patternType,
    intervalValue,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];
}

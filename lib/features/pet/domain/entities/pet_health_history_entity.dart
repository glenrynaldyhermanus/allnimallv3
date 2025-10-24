import 'package:equatable/equatable.dart';

class PetHealthHistoryEntity extends Equatable {
  final String id;
  final String petId;
  final String parameterKey;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime changedAt;
  final String? changedBy;
  final String? notes;

  const PetHealthHistoryEntity({
    required this.id,
    required this.petId,
    required this.parameterKey,
    this.oldValue,
    this.newValue,
    required this.changedAt,
    this.changedBy,
    this.notes,
  });

  String get changeDescription {
    if (oldValue == null) {
      return 'Set to $newValue';
    } else if (newValue == null) {
      return 'Cleared from $oldValue';
    } else {
      return 'Changed from $oldValue to $newValue';
    }
  }

  PetHealthHistoryEntity copyWith({
    String? id,
    String? petId,
    String? parameterKey,
    dynamic oldValue,
    dynamic newValue,
    DateTime? changedAt,
    String? changedBy,
    String? notes,
  }) {
    return PetHealthHistoryEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      parameterKey: parameterKey ?? this.parameterKey,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      changedAt: changedAt ?? this.changedAt,
      changedBy: changedBy ?? this.changedBy,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petId,
    parameterKey,
    oldValue,
    newValue,
    changedAt,
    changedBy,
    notes,
  ];
}

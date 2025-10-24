import 'package:equatable/equatable.dart';

class PetScheduleEntity extends Equatable {
  final String id;
  final String petId;
  final String scheduleTypeId;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final String? notes;
  final String status; // scheduled, completed, cancelled
  final String? recurringPatternId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Joined data (not from database directly)
  final String? scheduleTypeName;
  final String? scheduleTypeIcon;
  final String? scheduleTypeColor;

  const PetScheduleEntity({
    required this.id,
    required this.petId,
    required this.scheduleTypeId,
    required this.scheduledAt,
    this.completedAt,
    this.notes,
    required this.status,
    this.recurringPatternId,
    required this.createdAt,
    this.updatedAt,
    this.scheduleTypeName,
    this.scheduleTypeIcon,
    this.scheduleTypeColor,
  });

  bool get isCompleted => status == 'completed';
  bool get isScheduled => status == 'scheduled';
  bool get isCancelled => status == 'cancelled';
  bool get isRecurring => recurringPatternId != null;
  bool get isPast => scheduledAt.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return scheduledAt.year == now.year &&
        scheduledAt.month == now.month &&
        scheduledAt.day == now.day;
  }

  PetScheduleEntity copyWith({
    String? id,
    String? petId,
    String? scheduleTypeId,
    DateTime? scheduledAt,
    DateTime? completedAt,
    String? notes,
    String? status,
    String? recurringPatternId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? scheduleTypeName,
    String? scheduleTypeIcon,
    String? scheduleTypeColor,
  }) {
    return PetScheduleEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      scheduleTypeId: scheduleTypeId ?? this.scheduleTypeId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      recurringPatternId: recurringPatternId ?? this.recurringPatternId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduleTypeName: scheduleTypeName ?? this.scheduleTypeName,
      scheduleTypeIcon: scheduleTypeIcon ?? this.scheduleTypeIcon,
      scheduleTypeColor: scheduleTypeColor ?? this.scheduleTypeColor,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petId,
    scheduleTypeId,
    scheduledAt,
    completedAt,
    notes,
    status,
    recurringPatternId,
    createdAt,
    updatedAt,
    scheduleTypeName,
    scheduleTypeIcon,
    scheduleTypeColor,
  ];
}

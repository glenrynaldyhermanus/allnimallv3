import 'package:equatable/equatable.dart';

class PetTimelineEntity extends Equatable {
  final String id;
  final String petId;
  final String
  timelineType; // 'birthday', 'welcome', 'schedule', 'activity', 'media', 'weight_update'
  final String title;
  final String? caption;
  final String? mediaUrl;
  final String? mediaType; // 'image', 'video', null
  final String visibility; // 'public', 'private'
  final DateTime eventDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const PetTimelineEntity({
    required this.id,
    required this.petId,
    required this.timelineType,
    required this.title,
    this.caption,
    this.mediaUrl,
    this.mediaType,
    required this.visibility,
    required this.eventDate,
    this.metadata,
    required this.createdAt,
  });

  PetTimelineEntity copyWith({
    String? id,
    String? petId,
    String? timelineType,
    String? title,
    String? caption,
    String? mediaUrl,
    String? mediaType,
    String? visibility,
    DateTime? eventDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return PetTimelineEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      timelineType: timelineType ?? this.timelineType,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      visibility: visibility ?? this.visibility,
      eventDate: eventDate ?? this.eventDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petId,
    timelineType,
    title,
    caption,
    mediaUrl,
    mediaType,
    visibility,
    eventDate,
    metadata,
    createdAt,
  ];
}

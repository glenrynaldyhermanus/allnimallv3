import '../../domain/entities/pet_timeline_entity.dart';

class PetTimelineModel extends PetTimelineEntity {
  const PetTimelineModel({
    required super.id,
    required super.petId,
    required super.timelineType,
    required super.title,
    super.caption,
    super.mediaUrl,
    super.mediaType,
    required super.visibility,
    required super.eventDate,
    super.metadata,
    required super.createdAt,
  });

  factory PetTimelineModel.fromJson(Map<String, dynamic> json) {
    return PetTimelineModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      timelineType: json['timeline_type'] as String,
      title: json['title'] as String,
      caption: json['caption'] as String?,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
      visibility: json['visibility'] as String? ?? 'public',
      eventDate: DateTime.parse(json['event_date'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'timeline_type': timelineType,
      'title': title,
      'caption': caption,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'visibility': visibility,
      'event_date': eventDate.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PetTimelineEntity toEntity() {
    return PetTimelineEntity(
      id: id,
      petId: petId,
      timelineType: timelineType,
      title: title,
      caption: caption,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      visibility: visibility,
      eventDate: eventDate,
      metadata: metadata,
      createdAt: createdAt,
    );
  }

  factory PetTimelineModel.fromEntity(PetTimelineEntity entity) {
    return PetTimelineModel(
      id: entity.id,
      petId: entity.petId,
      timelineType: entity.timelineType,
      title: entity.title,
      caption: entity.caption,
      mediaUrl: entity.mediaUrl,
      mediaType: entity.mediaType,
      visibility: entity.visibility,
      eventDate: entity.eventDate,
      metadata: entity.metadata,
      createdAt: entity.createdAt,
    );
  }
}

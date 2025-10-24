import '../../domain/entities/pet_photo_entity.dart';

class PetPhotoModel extends PetPhotoEntity {
  const PetPhotoModel({
    required super.id,
    required super.petId,
    required super.photoUrl,
    super.isPrimary,
    super.sortOrder,
    super.caption,
    super.hashtags,
    super.fileSize,
    super.mimeType,
    super.width,
    super.height,
    super.duration,
    super.thumbnailUrl,
    super.likeCount,
    super.commentCount,
    super.shareCount,
    required super.createdAt,
    super.updatedAt,
  });

  factory PetPhotoModel.fromJson(Map<String, dynamic> json) {
    // Parse hashtags from JSON array
    List<String>? hashtags;
    if (json['hashtags'] != null) {
      hashtags = (json['hashtags'] as List).map((e) => e.toString()).toList();
    }

    return PetPhotoModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      photoUrl: json['photo_url'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      caption: json['caption'] as String?,
      hashtags: hashtags,
      fileSize: json['file_size'] as int?,
      mimeType: json['mime_type'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'photo_url': photoUrl,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'caption': caption,
      'hashtags': hashtags,
      'file_size': fileSize,
      'mime_type': mimeType,
      'width': width,
      'height': height,
      'duration': duration,
      'thumbnail_url': thumbnailUrl,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PetPhotoEntity toEntity() {
    return PetPhotoEntity(
      id: id,
      petId: petId,
      photoUrl: photoUrl,
      isPrimary: isPrimary,
      sortOrder: sortOrder,
      caption: caption,
      hashtags: hashtags,
      fileSize: fileSize,
      mimeType: mimeType,
      width: width,
      height: height,
      duration: duration,
      thumbnailUrl: thumbnailUrl,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

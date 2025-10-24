import '../../domain/entities/photo_like_entity.dart';

class PhotoLikeModel extends PhotoLikeEntity {
  const PhotoLikeModel({
    required super.id,
    required super.photoId,
    super.userId,
    super.likedByIp,
    required super.createdAt,
  });

  factory PhotoLikeModel.fromJson(Map<String, dynamic> json) {
    return PhotoLikeModel(
      id: json['id'] as String,
      photoId: json['photo_id'] as String,
      userId: json['user_id'] as String?,
      likedByIp: json['liked_by_ip'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'user_id': userId,
      'liked_by_ip': likedByIp,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PhotoLikeEntity toEntity() {
    return PhotoLikeEntity(
      id: id,
      photoId: photoId,
      userId: userId,
      likedByIp: likedByIp,
      createdAt: createdAt,
    );
  }
}

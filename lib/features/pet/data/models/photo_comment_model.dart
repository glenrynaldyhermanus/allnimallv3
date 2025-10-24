import '../../domain/entities/photo_comment_entity.dart';

class PhotoCommentModel extends PhotoCommentEntity {
  const PhotoCommentModel({
    required super.id,
    required super.photoId,
    super.userId,
    super.commenterName,
    super.commenterIp,
    required super.commentText,
    required super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory PhotoCommentModel.fromJson(Map<String, dynamic> json) {
    return PhotoCommentModel(
      id: json['id'] as String,
      photoId: json['photo_id'] as String,
      userId: json['user_id'] as String?,
      commenterName: json['commenter_name'] as String?,
      commenterIp: json['commenter_ip'] as String?,
      commentText: json['comment_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'user_id': userId,
      'commenter_name': commenterName,
      'commenter_ip': commenterIp,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  PhotoCommentEntity toEntity() {
    return PhotoCommentEntity(
      id: id,
      photoId: photoId,
      userId: userId,
      commenterName: commenterName,
      commenterIp: commenterIp,
      commentText: commentText,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }
}

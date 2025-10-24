import '../../domain/entities/photo_share_entity.dart';

class PhotoShareModel extends PhotoShareEntity {
  const PhotoShareModel({
    required super.id,
    required super.photoId,
    super.sharedByUserId,
    super.sharedByIp,
    required super.sharedToPlatform,
    required super.createdAt,
  });

  factory PhotoShareModel.fromJson(Map<String, dynamic> json) {
    return PhotoShareModel(
      id: json['id'] as String,
      photoId: json['photo_id'] as String,
      sharedByUserId: json['shared_by_user_id'] as String?,
      sharedByIp: json['shared_by_ip'] as String?,
      sharedToPlatform: json['shared_to_platform'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_id': photoId,
      'shared_by_user_id': sharedByUserId,
      'shared_by_ip': sharedByIp,
      'shared_to_platform': sharedToPlatform,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PhotoShareEntity toEntity() {
    return PhotoShareEntity(
      id: id,
      photoId: photoId,
      sharedByUserId: sharedByUserId,
      sharedByIp: sharedByIp,
      sharedToPlatform: sharedToPlatform,
      createdAt: createdAt,
    );
  }
}

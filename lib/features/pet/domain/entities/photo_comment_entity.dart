import 'package:equatable/equatable.dart';

class PhotoCommentEntity extends Equatable {
  final String id;
  final String photoId;
  final String? userId;
  final String? commenterName;
  final String? commenterIp;
  final String commentText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const PhotoCommentEntity({
    required this.id,
    required this.photoId,
    this.userId,
    this.commenterName,
    this.commenterIp,
    required this.commentText,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  bool get isAnonymous => userId == null;

  bool get isDeleted => deletedAt != null;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years${years == 1 ? 'y' : 'y'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months${months == 1 ? 'mo' : 'mo'}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}${difference.inDays == 1 ? 'd' : 'd'}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${difference.inHours == 1 ? 'h' : 'h'}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${difference.inMinutes == 1 ? 'm' : 'm'}';
    } else {
      return 'now';
    }
  }

  PhotoCommentEntity copyWith({
    String? id,
    String? photoId,
    String? userId,
    String? commenterName,
    String? commenterIp,
    String? commentText,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return PhotoCommentEntity(
      id: id ?? this.id,
      photoId: photoId ?? this.photoId,
      userId: userId ?? this.userId,
      commenterName: commenterName ?? this.commenterName,
      commenterIp: commenterIp ?? this.commenterIp,
      commentText: commentText ?? this.commentText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    photoId,
    userId,
    commenterName,
    commenterIp,
    commentText,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

import 'package:equatable/equatable.dart';

class PhotoLikeEntity extends Equatable {
  final String id;
  final String photoId;
  final String? userId;
  final String? likedByIp;
  final DateTime createdAt;

  const PhotoLikeEntity({
    required this.id,
    required this.photoId,
    this.userId,
    this.likedByIp,
    required this.createdAt,
  });

  bool get isAnonymous => userId == null;

  @override
  List<Object?> get props => [id, photoId, userId, likedByIp, createdAt];
}

import 'package:equatable/equatable.dart';

class PhotoShareEntity extends Equatable {
  final String id;
  final String photoId;
  final String? sharedByUserId;
  final String? sharedByIp;
  final String sharedToPlatform;
  final DateTime createdAt;

  const PhotoShareEntity({
    required this.id,
    required this.photoId,
    this.sharedByUserId,
    this.sharedByIp,
    required this.sharedToPlatform,
    required this.createdAt,
  });

  bool get isAnonymous => sharedByUserId == null;

  @override
  List<Object?> get props => [
    id,
    photoId,
    sharedByUserId,
    sharedByIp,
    sharedToPlatform,
    createdAt,
  ];
}

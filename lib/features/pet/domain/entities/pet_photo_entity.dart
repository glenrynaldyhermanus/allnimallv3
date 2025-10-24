import 'package:equatable/equatable.dart';

class PetPhotoEntity extends Equatable {
  final String id;
  final String petId;
  final String photoUrl;
  final bool isPrimary;
  final int sortOrder;
  final String? caption;
  final List<String>? hashtags;
  final int? fileSize;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? duration; // Duration in seconds for videos
  final String? thumbnailUrl; // Thumbnail URL for videos
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PetPhotoEntity({
    required this.id,
    required this.petId,
    required this.photoUrl,
    this.isPrimary = false,
    this.sortOrder = 0,
    this.caption,
    this.hashtags,
    this.fileSize,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
    this.thumbnailUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // Check if this is a video
  bool get isVideo => mimeType?.startsWith('video/') ?? false;

  // Get hashtags as a list
  List<String> get hashtagList => hashtags ?? [];

  // Format duration for videos
  String get formattedDuration {
    if (duration == null) return '';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  PetPhotoEntity copyWith({
    String? id,
    String? petId,
    String? photoUrl,
    bool? isPrimary,
    int? sortOrder,
    String? caption,
    List<String>? hashtags,
    int? fileSize,
    String? mimeType,
    int? width,
    int? height,
    int? duration,
    String? thumbnailUrl,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetPhotoEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      photoUrl: photoUrl ?? this.photoUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      sortOrder: sortOrder ?? this.sortOrder,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petId,
    photoUrl,
    isPrimary,
    sortOrder,
    caption,
    hashtags,
    fileSize,
    mimeType,
    width,
    height,
    duration,
    thumbnailUrl,
    likeCount,
    commentCount,
    shareCount,
    createdAt,
    updatedAt,
  ];
}

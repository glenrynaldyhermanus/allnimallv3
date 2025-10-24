import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pet_repository.dart';

class SharePhotoUseCase {
  final PetRepository repository;

  SharePhotoUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String photoId,
    required String platform,
    String? userId,
    String? ip,
  }) async {
    // Validation
    if (photoId.trim().isEmpty) {
      return const Left(ValidationFailure('Photo ID cannot be empty'));
    }

    if (platform.trim().isEmpty) {
      return const Left(ValidationFailure('Platform cannot be empty'));
    }

    final validPlatforms = [
      'instagram',
      'facebook',
      'whatsapp',
      'twitter',
      'link',
    ];
    if (!validPlatforms.contains(platform.toLowerCase())) {
      return const Left(ValidationFailure('Invalid platform'));
    }

    return await repository.sharePhoto(photoId, platform, userId, ip);
  }
}

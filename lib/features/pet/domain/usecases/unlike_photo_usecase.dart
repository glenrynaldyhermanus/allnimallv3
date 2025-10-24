import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pet_repository.dart';

class UnlikePhotoUseCase {
  final PetRepository repository;

  UnlikePhotoUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String photoId,
    String? userId,
    String? ip,
  }) async {
    // Validation
    if (photoId.trim().isEmpty) {
      return const Left(ValidationFailure('Photo ID cannot be empty'));
    }

    if (userId == null && ip == null) {
      return const Left(
        ValidationFailure('Either userId or IP must be provided'),
      );
    }

    return await repository.unlikePhoto(photoId, userId, ip);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/photo_comment_entity.dart';
import '../repositories/pet_repository.dart';

class AddPhotoCommentUseCase {
  final PetRepository repository;

  AddPhotoCommentUseCase(this.repository);

  Future<Either<Failure, PhotoCommentEntity>> call({
    required String photoId,
    required String commentText,
    String? userId,
    String? name,
    String? ip,
  }) async {
    // Validation
    if (photoId.trim().isEmpty) {
      return const Left(ValidationFailure('Photo ID cannot be empty'));
    }

    if (commentText.trim().isEmpty) {
      return const Left(ValidationFailure('Comment cannot be empty'));
    }

    if (commentText.length > 500) {
      return const Left(
        ValidationFailure('Comment cannot exceed 500 characters'),
      );
    }

    if (userId == null && name == null) {
      return const Left(
        ValidationFailure('Either userId or name must be provided'),
      );
    }

    return await repository.addComment(photoId, commentText, userId, name, ip);
  }
}

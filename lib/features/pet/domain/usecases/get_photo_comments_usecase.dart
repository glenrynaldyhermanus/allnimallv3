import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/photo_comment_entity.dart';
import '../repositories/pet_repository.dart';

class GetPhotoCommentsUseCase {
  final PetRepository repository;

  GetPhotoCommentsUseCase(this.repository);

  Future<Either<Failure, List<PhotoCommentEntity>>> call(String photoId) async {
    // Validation
    if (photoId.trim().isEmpty) {
      return const Left(ValidationFailure('Photo ID cannot be empty'));
    }

    return await repository.getPhotoComments(photoId);
  }
}

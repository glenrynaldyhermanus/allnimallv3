import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pet_repository.dart';

class DeletePhotoCommentUseCase {
  final PetRepository repository;

  DeletePhotoCommentUseCase(this.repository);

  Future<Either<Failure, void>> call(String commentId) async {
    // Validation
    if (commentId.trim().isEmpty) {
      return const Left(ValidationFailure('Comment ID cannot be empty'));
    }

    return await repository.deleteComment(commentId);
  }
}

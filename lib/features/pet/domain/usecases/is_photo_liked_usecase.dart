import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pet_repository.dart';

class IsPhotoLikedUseCase {
  final PetRepository repository;

  IsPhotoLikedUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String photoId,
    String? userId,
    String? ip,
  }) async {
    return await repository.isPhotoLiked(photoId, userId, ip);
  }
}

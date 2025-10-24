import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_photo_entity.dart';
import '../repositories/pet_repository.dart';

class UploadPetPhotoUseCase {
  final PetRepository repository;

  UploadPetPhotoUseCase(this.repository);

  Future<Either<Failure, PetPhotoEntity>> call({
    required String petId,
    required File file,
    String? caption,
    List<String>? hashtags,
  }) async {
    // Validation
    if (petId.trim().isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    if (!file.existsSync()) {
      return const Left(ValidationFailure('File does not exist'));
    }

    // Optional: Validate file size (e.g., max 50MB)
    final fileSize = await file.length();
    if (fileSize > 50 * 1024 * 1024) {
      return const Left(ValidationFailure('File size cannot exceed 50MB'));
    }

    return await repository.uploadPetPhoto(petId, file, caption, hashtags);
  }
}

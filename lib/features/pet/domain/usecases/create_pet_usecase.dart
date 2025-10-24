import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class CreatePetUseCase {
  final PetRepository repository;

  CreatePetUseCase(this.repository);

  Future<Either<Failure, PetEntity>> call(PetEntity pet) async {
    // Basic validation
    if (pet.name.trim().isEmpty) {
      return const Left(ValidationFailure('Pet name cannot be empty'));
    }

    if (pet.ownerId.isEmpty) {
      return const Left(ValidationFailure('Owner ID cannot be empty'));
    }

    if (pet.petCategoryId.isEmpty) {
      return const Left(ValidationFailure('Pet category cannot be empty'));
    }

    return await repository.createPet(pet);
  }
}

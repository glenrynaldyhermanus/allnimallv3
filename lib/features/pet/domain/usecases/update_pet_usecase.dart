import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class UpdatePetUseCase {
  final PetRepository repository;

  UpdatePetUseCase(this.repository);

  Future<Either<Failure, PetEntity>> call(PetEntity pet) async {
    // Basic validation
    if (pet.id.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    if (pet.name.trim().isEmpty) {
      return const Left(ValidationFailure('Pet name cannot be empty'));
    }

    return await repository.updatePet(pet);
  }
}

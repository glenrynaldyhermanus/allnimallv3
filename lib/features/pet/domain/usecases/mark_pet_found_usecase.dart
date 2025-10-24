import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class MarkPetFoundUseCase {
  final PetRepository repository;

  MarkPetFoundUseCase(this.repository);

  Future<Either<Failure, PetEntity>> call(String petId) async {
    if (petId.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    return await repository.markAsFound(petId);
  }
}

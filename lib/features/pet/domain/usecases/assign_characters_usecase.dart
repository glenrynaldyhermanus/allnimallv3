import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pet_repository.dart';

class AssignCharactersUseCase {
  final PetRepository repository;

  AssignCharactersUseCase(this.repository);

  Future<Either<Failure, void>> call(
    String petId,
    List<String> characterIds,
  ) async {
    if (petId.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    return await repository.assignCharactersToPet(petId, characterIds);
  }
}

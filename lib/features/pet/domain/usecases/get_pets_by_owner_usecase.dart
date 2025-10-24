import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class GetPetsByOwnerUseCase {
  final PetRepository repository;

  GetPetsByOwnerUseCase(this.repository);

  Future<Either<Failure, List<PetEntity>>> call(String ownerId) async {
    if (ownerId.isEmpty) {
      return const Left(ValidationFailure('Owner ID cannot be empty'));
    }

    return await repository.getPetsByOwner(ownerId);
  }
}

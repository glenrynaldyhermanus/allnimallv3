import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_timeline_entity.dart';
import '../repositories/pet_repository.dart';

class GetPetTimelinesUseCase {
  final PetRepository repository;

  GetPetTimelinesUseCase(this.repository);

  Future<Either<Failure, List<PetTimelineEntity>>> call(String petId) async {
    return await repository.getPetTimelines(petId);
  }
}

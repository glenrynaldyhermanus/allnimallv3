import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_schedule_entity.dart';
import '../repositories/pet_repository.dart';

class GetPetSchedulesUseCase {
  final PetRepository repository;

  GetPetSchedulesUseCase(this.repository);

  Future<Either<Failure, List<PetScheduleEntity>>> call(String petId) async {
    if (petId.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    return await repository.getSchedulesByPetId(petId);
  }
}

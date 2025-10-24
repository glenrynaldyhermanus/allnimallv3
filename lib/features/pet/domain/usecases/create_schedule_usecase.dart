import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_schedule_entity.dart';
import '../repositories/pet_repository.dart';

class CreateScheduleUseCase {
  final PetRepository repository;

  CreateScheduleUseCase(this.repository);

  Future<Either<Failure, PetScheduleEntity>> call(
    PetScheduleEntity schedule,
  ) async {
    if (schedule.petId.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    if (schedule.scheduleTypeId.isEmpty) {
      return const Left(ValidationFailure('Schedule type cannot be empty'));
    }

    return await repository.createSchedule(schedule);
  }
}

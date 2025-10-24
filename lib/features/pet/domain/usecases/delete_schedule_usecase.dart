import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pet_repository.dart';

class DeleteScheduleUseCase {
  final PetRepository repository;

  DeleteScheduleUseCase(this.repository);

  Future<Either<Failure, void>> call(String scheduleId) async {
    if (scheduleId.isEmpty) {
      return const Left(ValidationFailure('Schedule ID cannot be empty'));
    }

    return await repository.deleteSchedule(scheduleId);
  }
}

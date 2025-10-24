import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_timeline_entity.dart';
import '../repositories/pet_repository.dart';

class CreateTimelineEntryUseCase {
  final PetRepository repository;

  CreateTimelineEntryUseCase(this.repository);

  Future<Either<Failure, PetTimelineEntity>> call(
    PetTimelineEntity timeline,
  ) async {
    // Basic validation
    if (timeline.petId.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    if (timeline.title.trim().isEmpty) {
      return const Left(ValidationFailure('Timeline title cannot be empty'));
    }

    if (timeline.timelineType.isEmpty) {
      return const Left(ValidationFailure('Timeline type cannot be empty'));
    }

    return await repository.createTimelineEntry(timeline);
  }
}

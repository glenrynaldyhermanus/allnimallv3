import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pet_repository.dart';

class DeleteTimelineEntryUseCase {
  final PetRepository repository;

  DeleteTimelineEntryUseCase(this.repository);

  Future<Either<Failure, void>> call(String timelineId) async {
    if (timelineId.isEmpty) {
      return const Left(ValidationFailure('Timeline ID cannot be empty'));
    }

    return await repository.deleteTimelineEntry(timelineId);
  }
}

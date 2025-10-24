import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_health_history_entity.dart';
import '../repositories/pet_repository.dart';

class GetHealthHistory {
  final PetRepository repository;

  GetHealthHistory(this.repository);

  Future<Either<Failure, List<PetHealthHistoryEntity>>> call(
    String petId, {
    String? parameterKey,
    int? limit,
  }) async {
    return await repository.getHealthHistory(
      petId,
      parameterKey: parameterKey,
      limit: limit,
    );
  }
}

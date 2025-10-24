import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';
import '../repositories/pet_repository.dart';

class ReportLostPetUseCase {
  final PetRepository repository;

  ReportLostPetUseCase(this.repository);

  Future<Either<Failure, PetEntity>> call(
    String petId, {
    String? lostMessage,
    String? emergencyContact,
  }) async {
    if (petId.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    return await repository.reportLost(petId, lostMessage, emergencyContact);
  }
}

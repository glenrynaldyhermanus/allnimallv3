import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_health_entity.dart';
import '../entities/health_parameter_definition_entity.dart';
import '../repositories/pet_repository.dart';
import 'calculate_health_score.dart';

class UpdateHealthParameter {
  final PetRepository repository;
  final CalculateHealthScore calculateHealthScore;

  UpdateHealthParameter(this.repository, this.calculateHealthScore);

  Future<Either<Failure, PetHealthEntity>> call({
    required String petId,
    required String parameterKey,
    required dynamic parameterValue,
    String? notes,
  }) async {
    try {
      // Get current health data
      final currentHealthResult = await repository.getPetHealth(petId);

      PetHealthEntity? currentHealth;
      await currentHealthResult.fold(
        (failure) => null,
        (health) async => currentHealth = health,
      );

      // Get pet to access category
      final petResult = await repository.getPet(petId);
      String? petCategoryId;
      await petResult.fold(
        (failure) => null,
        (pet) async => petCategoryId = pet.petCategoryId,
      );

      if (petCategoryId == null) {
        return Left(ServerFailure('Pet category not found'));
      }

      // Get parameter definitions for the category
      final parametersResult = await repository.getHealthParametersForCategory(
        petCategoryId!,
      );

      List<HealthParameterDefinitionEntity> parameterDefinitions = [];
      await parametersResult.fold(
        (failure) => null,
        (params) async => parameterDefinitions = params,
      );

      // Update health parameters
      final updatedParameters = Map<String, dynamic>.from(
        currentHealth?.healthParameters ?? {},
      );
      updatedParameters[parameterKey] = parameterValue;

      // Calculate new health score
      final newHealthScore = calculateHealthScore(
        healthParameters: updatedParameters,
        parameterDefinitions: parameterDefinitions,
      );

      // Create updated health entity
      final updatedHealth = PetHealthEntity(
        id: currentHealth?.id ?? '',
        petId: petId,
        weight: currentHealth?.weight,
        weightHistory: currentHealth?.weightHistory,
        healthParameters: updatedParameters,
        healthScore: newHealthScore,
        lastScoredAt: DateTime.now(),
        vaccinationStatus: currentHealth?.vaccinationStatus,
        lastVaccinationDate: currentHealth?.lastVaccinationDate,
        nextVaccinationDate: currentHealth?.nextVaccinationDate,
        healthNotes: currentHealth?.healthNotes,
        medicalConditions: currentHealth?.medicalConditions,
        allergies: currentHealth?.allergies,
        createdAt: currentHealth?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      final saveResult = await repository.updatePetHealth(updatedHealth);

      // Create history entry
      await repository.createHealthHistory(
        petId: petId,
        parameterKey: parameterKey,
        oldValue: currentHealth?.healthParameters[parameterKey],
        newValue: parameterValue,
        notes: notes,
      );

      return saveResult;
    } catch (e) {
      return Left(ServerFailure('Failed to update health parameter: $e'));
    }
  }
}

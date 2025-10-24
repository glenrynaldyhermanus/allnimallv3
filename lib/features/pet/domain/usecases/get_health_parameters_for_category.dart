import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/health_parameter_definition_entity.dart';
import '../repositories/pet_repository.dart';

class GetHealthParametersForCategory {
  final PetRepository repository;

  GetHealthParametersForCategory(this.repository);

  Future<Either<Failure, List<HealthParameterDefinitionEntity>>> call(
    String petCategoryId,
  ) async {
    return await repository.getHealthParametersForCategory(petCategoryId);
  }
}

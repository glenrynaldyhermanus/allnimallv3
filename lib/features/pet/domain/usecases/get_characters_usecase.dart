import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/character_entity.dart';
import '../repositories/pet_repository.dart';

class GetCharactersUseCase {
  final PetRepository repository;

  GetCharactersUseCase(this.repository);

  Future<Either<Failure, List<CharacterEntity>>> call() async {
    return await repository.getCharacters();
  }
}

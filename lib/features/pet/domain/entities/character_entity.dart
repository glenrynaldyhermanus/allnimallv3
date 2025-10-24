import 'package:equatable/equatable.dart';

class CharacterEntity extends Equatable {
  final String id;
  final String characterEn;
  final String characterId;
  final bool goodCharacter;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CharacterEntity({
    required this.id,
    required this.characterEn,
    required this.characterId,
    required this.goodCharacter,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    characterEn,
    characterId,
    goodCharacter,
    createdAt,
    updatedAt,
  ];
}

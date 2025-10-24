import 'package:equatable/equatable.dart';

class PetCategoryEntity extends Equatable {
  final String id;
  final String nameEn;
  final String nameId;
  final String? pictureUrl;
  final String? iconUrl;

  const PetCategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameId,
    this.pictureUrl,
    this.iconUrl,
  });

  String get name => nameId; // Use Indonesian name by default

  @override
  List<Object?> get props => [id, nameEn, nameId, pictureUrl, iconUrl];
}

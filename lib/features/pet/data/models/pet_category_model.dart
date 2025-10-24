import '../../domain/entities/pet_category_entity.dart';

class PetCategoryModel extends PetCategoryEntity {
  const PetCategoryModel({
    required super.id,
    required super.nameEn,
    required super.nameId,
    super.pictureUrl,
    super.iconUrl,
  });

  factory PetCategoryModel.fromJson(Map<String, dynamic> json) {
    return PetCategoryModel(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameId: json['name_id'] as String,
      pictureUrl: json['picture_url'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_id': nameId,
      'picture_url': pictureUrl,
      'icon_url': iconUrl,
    };
  }
}

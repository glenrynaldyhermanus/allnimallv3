import '../../domain/entities/pet_entity.dart';

class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.petCategoryId,
    super.breed,
    super.birthDate,
    super.gender,
    super.color,
    super.weight,
    super.microchipId,
    super.qrId,
    super.pictureUrl,
    super.story,
    super.isLost,
    super.lostAt,
    super.lostMessage,
    super.emergencyContact,
    super.activatedAt,
    super.qrCodeUrl,
    super.sterilizationStatus,
    super.adoptionStatus,
    required super.createdAt,
    super.updatedAt,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      petCategoryId: json['pet_category_id'] as String,
      breed: json['breed'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      color: json['color'] as String?,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      microchipId: json['microchip_id'] as String?,
      qrId: json['qr_id'] as String?,
      pictureUrl: json['picture_url'] as String?,
      story: json['story'] as String?,
      isLost: json['is_lost'] as bool? ?? false,
      lostAt: json['lost_at'] != null
          ? DateTime.parse(json['lost_at'] as String)
          : null,
      lostMessage: json['lost_message'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      activatedAt: json['activated_at'] != null
          ? DateTime.parse(json['activated_at'] as String)
          : null,
      qrCodeUrl: json['qr_code_url'] as String?,
      sterilizationStatus: json['sterilization_status'] as String?,
      adoptionStatus: json['adoption_status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'pet_category_id': petCategoryId,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'color': color,
      'weight': weight,
      'microchip_id': microchipId,
      'picture_url': pictureUrl,
      'story': story,
      'is_lost': isLost,
      'lost_at': lostAt?.toIso8601String(),
      'lost_message': lostMessage,
      'emergency_contact': emergencyContact,
      'activated_at': activatedAt?.toIso8601String(),
      'qr_code_url': qrCodeUrl,
      'sterilization_status': sterilizationStatus,
      'adoption_status': adoptionStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PetEntity toEntity() {
    return PetEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      petCategoryId: petCategoryId,
      breed: breed,
      birthDate: birthDate,
      gender: gender,
      color: color,
      weight: weight,
      microchipId: microchipId,
      pictureUrl: pictureUrl,
      story: story,
      isLost: isLost,
      lostAt: lostAt,
      lostMessage: lostMessage,
      emergencyContact: emergencyContact,
      activatedAt: activatedAt,
      qrCodeUrl: qrCodeUrl,
      sterilizationStatus: sterilizationStatus,
      adoptionStatus: adoptionStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

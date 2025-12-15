import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String ownerId;
  final String name;
  final String petCategoryId;
  final String? breed;
  final DateTime? birthDate;
  final String? gender;
  final String? color;
  final double? weight;
  final String? microchipId;
  final String? qrId; // NEW: QR ID for collar
  final String? pictureUrl;
  final String? story;
  final bool isLost;
  final DateTime? lostAt;
  final String? lostMessage;
  final String? emergencyContact;
  final DateTime? activatedAt;
  final String? qrCodeUrl;
  final String? sterilizationStatus;
  final String? adoptionStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PetEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.petCategoryId,
    this.breed,
    this.birthDate,
    this.gender,
    this.color,
    this.weight,
    this.microchipId,
    this.qrId,
    this.pictureUrl,
    this.story,
    this.isLost = false,
    this.lostAt,
    this.lostMessage,
    this.emergencyContact,
    this.activatedAt,
    this.qrCodeUrl,
    this.sterilizationStatus,
    this.adoptionStatus,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isNewCollar => name == 'Allnimall';

  int? get ageInYears {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  String get ageDisplay {
    final age = ageInYears;
    if (age == null) return 'Unknown';
    if (age == 0) return 'Less than 1 year';
    if (age == 1) return '1 year';
    return '$age years';
  }

  PetEntity copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? petCategoryId,
    String? breed,
    DateTime? birthDate,
    String? gender,
    String? color,
    double? weight,
    String? microchipId,
    String? qrId,
    String? pictureUrl,
    String? story,
    bool? isLost,
    DateTime? lostAt,
    String? lostMessage,
    String? emergencyContact,
    DateTime? activatedAt,
    String? qrCodeUrl,
    String? sterilizationStatus,
    String? adoptionStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetEntity(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      petCategoryId: petCategoryId ?? this.petCategoryId,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      microchipId: microchipId ?? this.microchipId,
      qrId: qrId ?? this.qrId,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      story: story ?? this.story,
      isLost: isLost ?? this.isLost,
      lostAt: lostAt ?? this.lostAt,
      lostMessage: lostMessage ?? this.lostMessage,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      activatedAt: activatedAt ?? this.activatedAt,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      sterilizationStatus: sterilizationStatus ?? this.sterilizationStatus,
      adoptionStatus: adoptionStatus ?? this.adoptionStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    petCategoryId,
    breed,
    birthDate,
    gender,
    color,
    weight,
    microchipId,
    qrId,
    pictureUrl,
    story,
    isLost,
    lostAt,
    lostMessage,
    emergencyContact,
    activatedAt,
    qrCodeUrl,
    sterilizationStatus,
    adoptionStatus,
    createdAt,
    updatedAt,
  ];
}

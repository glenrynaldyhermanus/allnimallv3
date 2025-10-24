import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String? name; // Nullable for new Firebase users (fill later)
  final String phoneNumber;
  final String? email;
  final String? pictureUrl;
  final String? address;
  final String? authId; // Firebase UID or Supabase UUID
  final String authProvider; // 'FIREBASE_SMS' or 'SUPABASE'
  final String? gender;
  final DateTime? birthDate;
  final String membershipType;
  final int level;
  final int experiencePoints;
  final DateTime joinedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomerEntity({
    required this.id,
    this.name, // Now nullable
    required this.phoneNumber,
    this.email,
    this.pictureUrl,
    this.address,
    this.authId,
    this.authProvider = 'SUPABASE', // Default for existing users
    this.gender,
    this.birthDate,
    this.membershipType = 'free',
    this.level = 1,
    this.experiencePoints = 0,
    required this.joinedAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPremium => membershipType == 'premium';

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? pictureUrl,
    String? address,
    String? authId,
    String? authProvider,
    String? gender,
    DateTime? birthDate,
    String? membershipType,
    int? level,
    int? experiencePoints,
    DateTime? joinedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      address: address ?? this.address,
      authId: authId ?? this.authId,
      authProvider: authProvider ?? this.authProvider,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      membershipType: membershipType ?? this.membershipType,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      joinedAt: joinedAt ?? this.joinedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phoneNumber,
    email,
    pictureUrl,
    address,
    authId,
    authProvider,
    gender,
    birthDate,
    membershipType,
    level,
    experiencePoints,
    joinedAt,
    createdAt,
    updatedAt,
  ];
}

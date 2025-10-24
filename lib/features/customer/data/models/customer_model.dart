import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    super.name, // Now nullable
    required super.phoneNumber,
    super.email,
    super.pictureUrl,
    super.address,
    super.authId,
    super.authProvider = 'SUPABASE', // Default for existing users
    super.gender,
    super.birthDate,
    super.membershipType,
    super.level,
    super.experiencePoints,
    required super.joinedAt,
    required super.createdAt,
    super.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String?, // Now nullable
      phoneNumber: json['phone'] as String,
      email: json['email'] as String?,
      pictureUrl: json['picture_url'] as String?,
      address: json['address'] as String?,
      authId: json['auth_id'] as String?,
      authProvider: json['auth_provider'] as String? ?? 'SUPABASE',
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      membershipType: json['membership_type'] as String? ?? 'free',
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experience_points'] as int? ?? 0,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, // Nullable
      'phone': phoneNumber,
      'email': email,
      'picture_url': pictureUrl,
      'address': address,
      'auth_id': authId,
      'auth_provider': authProvider,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'membership_type': membershipType,
      'level': level,
      'experience_points': experiencePoints,
      'joined_at': joinedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      pictureUrl: pictureUrl,
      address: address,
      authId: authId,
      authProvider: authProvider,
      gender: gender,
      birthDate: birthDate,
      membershipType: membershipType,
      level: level,
      experiencePoints: experiencePoints,
      joinedAt: joinedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

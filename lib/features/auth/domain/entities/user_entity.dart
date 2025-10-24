import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id; // Supabase customer ID
  final String? phone;
  final String? email;
  final String? name; // Nullable for new Firebase users
  final String? pictureUrl;
  final String? firebaseUid; // Firebase UID (for Firebase auth users)
  final String authProvider; // 'FIREBASE_SMS' or 'SUPABASE'
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  const UserEntity({
    required this.id,
    this.phone,
    this.email,
    this.name,
    this.pictureUrl,
    this.firebaseUid,
    this.authProvider = 'SUPABASE', // Default for existing users
    this.createdAt,
    this.lastSignInAt,
  });

  UserEntity copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? pictureUrl,
    String? firebaseUid,
    String? authProvider,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    phone,
    email,
    name,
    pictureUrl,
    firebaseUid,
    authProvider,
    createdAt,
    lastSignInAt,
  ];
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Sign in with phone number and send OTP
  Future<Either<Failure, void>> signInWithPhone(String phoneNumber);

  /// Verify OTP code
  Future<Either<Failure, UserEntity>> verifyOTP(
    String phoneNumber,
    String otpCode,
  );

  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Check if user is authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;
}

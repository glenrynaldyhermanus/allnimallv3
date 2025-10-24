import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOTPUseCase {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String phoneNumber,
    String otpCode,
  ) async {
    // Validate phone number
    final phoneValidationError = Validators.phone(phoneNumber);
    if (phoneValidationError != null) {
      return Left(ValidationFailure(phoneValidationError));
    }

    // Validate OTP code
    final otpValidationError = Validators.otp(otpCode);
    if (otpValidationError != null) {
      return Left(ValidationFailure(otpValidationError));
    }

    return await repository.verifyOTP(phoneNumber, otpCode);
  }
}

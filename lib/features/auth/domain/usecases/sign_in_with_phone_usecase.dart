import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class SignInWithPhoneUseCase {
  final AuthRepository repository;

  SignInWithPhoneUseCase(this.repository);

  Future<Either<Failure, void>> call(String phoneNumber) async {
    // Validate phone number
    final validationError = Validators.phone(phoneNumber);
    if (validationError != null) {
      return Left(ValidationFailure(validationError));
    }

    return await repository.signInWithPhone(phoneNumber);
  }
}

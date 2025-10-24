import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/customer_repository.dart';

/// Use case to check if a customer exists by phone number
class CheckCustomerExistsUseCase {
  final CustomerRepository _repository;

  CheckCustomerExistsUseCase(this._repository);

  Future<Either<Failure, bool>> call(String phoneNumber) async {
    try {
      final result = await _repository.checkCustomerExists(phoneNumber);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

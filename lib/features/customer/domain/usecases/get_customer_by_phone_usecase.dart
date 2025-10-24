import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Use case to get customer by phone number
class GetCustomerByPhoneUseCase {
  final CustomerRepository _repository;

  GetCustomerByPhoneUseCase(this._repository);

  Future<Either<Failure, CustomerEntity?>> call(String phoneNumber) async {
    try {
      final customer = await _repository.getCustomerByPhone(phoneNumber);
      return Right(customer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

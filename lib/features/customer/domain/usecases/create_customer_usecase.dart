import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_entity.dart';
import '../repositories/customer_repository.dart';

/// Use case to create a new customer
class CreateCustomerUseCase {
  final CustomerRepository _repository;

  CreateCustomerUseCase(this._repository);

  Future<Either<Failure, CustomerEntity>> call(CustomerEntity customer) async {
    try {
      final createdCustomer = await _repository.createCustomer(customer);
      return Right(createdCustomer);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/usecases/check_customer_exists_usecase.dart';
import '../../domain/usecases/get_customer_by_phone_usecase.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';

/// Customer repository provider
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl();
});

/// Check customer exists use case provider
final checkCustomerExistsUseCaseProvider = Provider<CheckCustomerExistsUseCase>(
  (ref) {
    final repository = ref.watch(customerRepositoryProvider);
    return CheckCustomerExistsUseCase(repository);
  },
);

/// Get customer by phone use case provider
final getCustomerByPhoneUseCaseProvider = Provider<GetCustomerByPhoneUseCase>((
  ref,
) {
  final repository = ref.watch(customerRepositoryProvider);
  return GetCustomerByPhoneUseCase(repository);
});

/// Create customer use case provider
final createCustomerUseCaseProvider = Provider<CreateCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return CreateCustomerUseCase(repository);
});

/// Update customer use case provider
final updateCustomerUseCaseProvider = Provider<UpdateCustomerUseCase>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return UpdateCustomerUseCase(repository);
});

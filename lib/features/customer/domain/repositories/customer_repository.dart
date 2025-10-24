import '../entities/customer_entity.dart';

/// Abstract repository interface for customer operations
abstract class CustomerRepository {
  /// Check if customer exists by phone number
  Future<bool> checkCustomerExists(String phoneNumber);

  /// Get customer by phone number
  Future<CustomerEntity?> getCustomerByPhone(String phoneNumber);

  /// Create new customer
  Future<CustomerEntity> createCustomer(CustomerEntity customer);

  /// Create new customer from Firebase auth (name nullable, auth_provider = 'FIREBASE_SMS')
  Future<CustomerEntity> createFirebaseCustomer({
    required String phoneNumber,
    required String firebaseUid,
  });

  /// Update customer
  Future<CustomerEntity> updateCustomer(CustomerEntity customer);

  /// Get customer by ID
  Future<CustomerEntity?> getCustomerById(String id);
}

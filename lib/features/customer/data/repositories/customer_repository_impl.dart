import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';

/// Implementation of CustomerRepository
class CustomerRepositoryImpl implements CustomerRepository {
  final SupabaseClient _client = SupabaseConfig.instance;

  @override
  Future<bool> checkCustomerExists(String phoneNumber) async {
    try {
      print(
        '🔍 Repository: Checking customer existence for phone: $phoneNumber',
      );
      final response = await _client
          .from('customers')
          .select('id')
          .eq('phone', phoneNumber)
          .maybeSingle();

      print('🔍 Repository: Response: $response');
      final exists = response != null;
      print('🔍 Repository: Customer exists: $exists');
      return exists;
    } on PostgrestException catch (e) {
      print('❌ Repository: PostgrestException: ${e.message}');
      throw ServerException('Failed to check customer existence: ${e.message}');
    } catch (e) {
      print('❌ Repository: Unexpected error: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<CustomerEntity?> getCustomerByPhone(String phoneNumber) async {
    try {
      final response = await _client
          .from('customers')
          .select('*')
          .eq('phone', phoneNumber)
          .maybeSingle();

      if (response == null) return null;
      return CustomerModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get customer: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<CustomerEntity> createCustomer(CustomerEntity customer) async {
    try {
      final customerModel = CustomerModel(
        id: customer.id,
        name: customer.name,
        phoneNumber: customer.phoneNumber,
        email: customer.email,
        pictureUrl: customer.pictureUrl,
        address: customer.address,
        authId: customer.authId,
        authProvider: customer.authProvider,
        gender: customer.gender,
        birthDate: customer.birthDate,
        membershipType: customer.membershipType,
        level: customer.level,
        experiencePoints: customer.experiencePoints,
        joinedAt: customer.joinedAt,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
      );

      final response = await _client
          .from('customers')
          .insert(customerModel.toJson())
          .select()
          .single();

      return CustomerModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create customer: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<CustomerEntity> createFirebaseCustomer({
    required String phoneNumber,
    required String firebaseUid,
  }) async {
    try {
      // Normalize phone number to +6289637978871 format (with +62 prefix)
      String normalizedPhone = phoneNumber;
      if (normalizedPhone.startsWith('+62')) {
        normalizedPhone = normalizedPhone; // Already correct
      } else if (normalizedPhone.startsWith('62')) {
        normalizedPhone = '+$normalizedPhone'; // Add + prefix
      } else if (normalizedPhone.startsWith('0')) {
        normalizedPhone =
            '+62${normalizedPhone.substring(1)}'; // Replace 0 with +62
      }

      print(
        '🔥 Creating Firebase customer: phone=$normalizedPhone (original: $phoneNumber), uid=$firebaseUid',
      );

      final now = DateTime.now();
      final customerData = {
        'phone': normalizedPhone,
        'auth_id': firebaseUid,
        'auth_provider': 'FIREBASE_SMS',
        'name': null, // User will fill this later in profile setup
        'membership_type': 'free',
        'level': 1,
        'experience_points': 0,
        'joined_at': now.toIso8601String(), // Changed from joined_date
        // 'is_verified' removed - column no longer exists
      };

      final response = await _client
          .from('customers')
          .insert(customerData)
          .select()
          .single();

      print('✅ Firebase customer created successfully: ${response['id']}');
      return CustomerModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      print('❌ Failed to create Firebase customer: ${e.message}');
      throw ServerException('Failed to create Firebase customer: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error creating Firebase customer: $e');
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<CustomerEntity> updateCustomer(CustomerEntity customer) async {
    try {
      final customerModel = CustomerModel(
        id: customer.id,
        name: customer.name,
        phoneNumber: customer.phoneNumber,
        email: customer.email,
        pictureUrl: customer.pictureUrl,
        address: customer.address,
        authId: customer.authId,
        authProvider: customer.authProvider,
        gender: customer.gender,
        birthDate: customer.birthDate,
        membershipType: customer.membershipType,
        level: customer.level,
        experiencePoints: customer.experiencePoints,
        joinedAt: customer.joinedAt,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
      );

      final response = await _client
          .from('customers')
          .update(customerModel.toJson())
          .eq('id', customer.id)
          .select()
          .single();

      return CustomerModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update customer: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<CustomerEntity?> getCustomerById(String id) async {
    try {
      final response = await _client
          .from('customers')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CustomerModel.fromJson(response).toEntity();
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get customer: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}

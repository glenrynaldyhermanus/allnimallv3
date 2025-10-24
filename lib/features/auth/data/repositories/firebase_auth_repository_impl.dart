import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart' as exceptions;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../../customer/domain/entities/customer_entity.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// NEW: Firebase Auth Repository Implementation
/// Integrates Firebase Phone Auth + Supabase Customer Management
class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseAuthDataSource;
  final CustomerRepository customerRepository;

  // For OTP verification flow
  String? _verificationId;

  FirebaseAuthRepositoryImpl({
    required this.firebaseAuthDataSource,
    required this.customerRepository,
  });

  @override
  Future<Either<Failure, void>> signInWithPhone(String phoneNumber) async {
    try {
      AppLogger.info('📱 Starting Firebase Phone Auth flow for: $phoneNumber');

      // Step 1: Send OTP via Firebase (FREE!)
      _verificationId = await firebaseAuthDataSource.sendOTP(phoneNumber);

      AppLogger.info('✅ OTP sent successfully via Firebase');
      AppLogger.info('💰 Cost: FREE! (would be \$0.05 with Supabase)');

      return const Right(null);
    } on exceptions.AuthException catch (e) {
      AppLogger.error('Auth error during phone sign in', e);
      return Left(AuthFailure(e.message));
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server error during phone sign in', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during phone sign in', e, stackTrace);
      return Left(ServerFailure('Failed to send OTP: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOTP(
    String phoneNumber,
    String otpCode,
  ) async {
    try {
      AppLogger.info('🔐 Verifying OTP for: $phoneNumber');

      // Validate we have verification ID
      if (_verificationId == null) {
        throw exceptions.AuthException(
          'No verification in progress. Please request OTP first.',
          'NO_VERIFICATION',
        );
      }

      // Step 1: Verify OTP with Firebase
      AppLogger.info('Step 1: Verifying OTP with Firebase...');
      final firebaseUser = await firebaseAuthDataSource.verifyOTP(
        _verificationId!,
        otpCode,
      );

      AppLogger.info('✅ Firebase verification successful!');
      AppLogger.info('Firebase UID: ${firebaseUser.uid}');
      AppLogger.info('Phone: ${firebaseUser.phoneNumber}');

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

      AppLogger.info(
        'Normalized phone for DB: $normalizedPhone (original: $phoneNumber)',
      );

      // Step 2: Check if customer exists in Supabase
      AppLogger.info('Step 2: Checking customer in Supabase...');
      var customer = await customerRepository.getCustomerByPhone(
        normalizedPhone,
      );

      if (customer == null) {
        // Step 3: Create new customer in Supabase
        AppLogger.info('Customer not found. Creating new customer...');
        customer = await customerRepository.createFirebaseCustomer(
          phoneNumber: normalizedPhone,
          firebaseUid: firebaseUser.uid,
        );
        AppLogger.info('✅ New customer created: ${customer.id}');
        AppLogger.info(
          'Note: Customer name is null - will be set in profile setup',
        );
      } else {
        AppLogger.info('✅ Existing customer found: ${customer.id}');
        AppLogger.info('Customer name: ${customer.name ?? "(not set)"}');
      }

      // Step 4: Convert to UserEntity
      final userEntity = UserEntity(
        id: customer.id, // Supabase customer ID
        phone: customer.phoneNumber,
        email: customer.email,
        name: customer.name, // May be null for new users
        firebaseUid: firebaseUser.uid, // Firebase UID
        authProvider: customer.authProvider, // 'FIREBASE_SMS'
        createdAt: customer.createdAt,
      );

      // Clear verification data
      _verificationId = null;

      AppLogger.info('🎉 Authentication successful!');
      AppLogger.info('User ID: ${userEntity.id}');
      AppLogger.info('Firebase UID: ${userEntity.firebaseUid}');
      AppLogger.info('Auth Provider: ${userEntity.authProvider}');

      return Right(userEntity);
    } on exceptions.InvalidOTPException catch (e) {
      AppLogger.error('Invalid OTP', e);
      return Left(AuthFailure(e.message));
    } on exceptions.AuthException catch (e) {
      AppLogger.error('Auth error during OTP verification', e);
      return Left(AuthFailure(e.message));
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server error during OTP verification', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during OTP verification',
        e,
        stackTrace,
      );
      return Left(ServerFailure('Failed to verify OTP: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      AppLogger.debug('Getting current user...');

      // Get current Firebase user
      final firebaseUser = await firebaseAuthDataSource
          .getCurrentFirebaseUser();

      if (firebaseUser == null) {
        AppLogger.debug('No Firebase user signed in');
        return const Right(null);
      }

      AppLogger.debug('Firebase user found: ${firebaseUser.uid}');

      // Get customer from Supabase
      var phoneNumber = firebaseUser.phoneNumber;
      if (phoneNumber == null) {
        AppLogger.warning('Firebase user has no phone number');
        return const Right(null);
      }

      // Normalize phone number to +6289637978871 format (with +62 prefix)
      if (phoneNumber.startsWith('+62')) {
        phoneNumber = phoneNumber; // Already correct
      } else if (phoneNumber.startsWith('62')) {
        phoneNumber = '+$phoneNumber'; // Add + prefix
      } else if (phoneNumber.startsWith('0')) {
        phoneNumber = '+62${phoneNumber.substring(1)}'; // Replace 0 with +62
      }

      AppLogger.debug('Looking up customer with phone: $phoneNumber');

      final customer = await customerRepository.getCustomerByPhone(phoneNumber);

      if (customer == null) {
        AppLogger.warning('Customer not found in Supabase');
        return const Right(null);
      }

      final userEntity = UserEntity(
        id: customer.id,
        phone: customer.phoneNumber,
        email: customer.email,
        name: customer.name,
        firebaseUid: firebaseUser.uid,
        authProvider: customer.authProvider,
        createdAt: customer.createdAt,
      );

      AppLogger.debug('Current user: ${userEntity.id}');
      return Right(userEntity);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server error getting current user', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting current user', e, stackTrace);
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      AppLogger.info('Signing out...');

      // Sign out from Firebase
      await firebaseAuthDataSource.signOut();

      // Clear verification data
      _verificationId = null;

      AppLogger.info('✅ Signed out successfully');
      return const Right(null);
    } on exceptions.AuthException catch (e) {
      AppLogger.error('Auth error during sign out', e);
      return Left(AuthFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign out', e, stackTrace);
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final firebaseUser = await firebaseAuthDataSource
          .getCurrentFirebaseUser();
      final isAuth = firebaseUser != null;
      AppLogger.debug('Is authenticated: $isAuth');
      return Right(isAuth);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking authentication status', e, stackTrace);
      return const Right(false);
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return firebaseAuthDataSource.authStateChanges.asyncMap((
      firebaseUser,
    ) async {
      if (firebaseUser == null) {
        AppLogger.debug('Auth state: No user');
        return null;
      }

      try {
        AppLogger.debug('Auth state changed: ${firebaseUser.uid}');

        var phoneNumber = firebaseUser.phoneNumber;
        if (phoneNumber == null) return null;

        // Normalize phone number to +6289637978871 format (with +62 prefix)
        if (phoneNumber.startsWith('+62')) {
          phoneNumber = phoneNumber; // Already correct
        } else if (phoneNumber.startsWith('62')) {
          phoneNumber = '+$phoneNumber'; // Add + prefix
        } else if (phoneNumber.startsWith('0')) {
          phoneNumber = '+62${phoneNumber.substring(1)}'; // Replace 0 with +62
        }

        AppLogger.debug('Looking up customer with phone: $phoneNumber');

        // Retry logic to handle race condition with customer creation
        CustomerEntity? customer;
        for (int attempt = 0; attempt < 3; attempt++) {
          customer = await customerRepository.getCustomerByPhone(phoneNumber);

          if (customer != null) {
            AppLogger.debug('Customer found on attempt ${attempt + 1}');
            break;
          }

          if (attempt < 2) {
            AppLogger.debug(
              'Customer not found, retrying in 500ms (attempt ${attempt + 1}/3)',
            );
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }

        if (customer == null) {
          AppLogger.debug(
            'Customer not found after 3 attempts for phone: $phoneNumber',
          );
          return null;
        }

        return UserEntity(
          id: customer.id,
          phone: customer.phoneNumber,
          email: customer.email,
          name: customer.name,
          firebaseUid: firebaseUser.uid,
          authProvider: customer.authProvider,
          createdAt: customer.createdAt,
        );
      } catch (e) {
        AppLogger.error('Error in auth state changes', e);
        return null;
      }
    });
  }
}

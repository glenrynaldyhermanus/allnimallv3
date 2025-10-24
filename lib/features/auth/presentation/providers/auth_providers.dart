import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../customer/data/repositories/customer_repository_impl.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/firebase_auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/is_authenticated_usecase.dart';
import '../../domain/usecases/sign_in_with_phone_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

// Firebase Auth Data Source
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSourceImpl(firebaseAuth: FirebaseAuth.instance);
});

// Customer Repository (for Supabase customer management)
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl();
});

// Auth Repository (uses Firebase + Supabase)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepositoryImpl(
    firebaseAuthDataSource: ref.watch(firebaseAuthDataSourceProvider),
    customerRepository: ref.watch(customerRepositoryProvider),
  );
});

// Use Cases
final signInWithPhoneUseCaseProvider = Provider<SignInWithPhoneUseCase>((ref) {
  return SignInWithPhoneUseCase(ref.watch(authRepositoryProvider));
});

final verifyOTPUseCaseProvider = Provider<VerifyOTPUseCase>((ref) {
  return VerifyOTPUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final isAuthenticatedUseCaseProvider = Provider<IsAuthenticatedUseCase>((ref) {
  return IsAuthenticatedUseCase(ref.watch(authRepositoryProvider));
});

// Auth State Stream
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current User
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  final result = await useCase();

  return result.fold((failure) => null, (user) => user);
});

// Is Authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final useCase = ref.watch(isAuthenticatedUseCaseProvider);
  final result = await useCase();

  return result.fold((failure) => false, (isAuth) => isAuth);
});

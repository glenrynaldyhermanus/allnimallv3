# Firebase Phone Authentication Migration Plan

**Date:** October 8, 2025  
**Project:** Allnimall QR  
**Migration:** Supabase Phone OTP → Firebase Phone OTP

---

## 📋 Executive Summary

**Goal:** Migrate from paid Supabase Phone OTP to free Firebase Phone Authentication while maintaining backward compatibility with existing users.

**Current Status:** 🔄 **30% Complete** - Database migration done, ready for Firebase setup

**Key Changes:**

- Replace Supabase Phone OTP with Firebase Phone Auth
- Store Firebase UID in `customers.auth_id` ✅ Schema ready
- Set `auth_provider` to `'FIREBASE_SMS'` ✅ Schema ready
- Auto-create customer record in Supabase after Firebase auth success

**Impact:**

- ✅ **Cost Savings:** Free unlimited OTP from Firebase
- ✅ **Better Reliability:** Firebase has 99.95% uptime SLA
- ✅ **Database Migration:** COMPLETED - dual auth providers supported
- ⏳ **Code Refactoring:** In progress - auth flow needs update

---

## 🗂️ Current State Analysis

### Current Database Schema (customers table)

```sql
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,                      -- ⚠️ Currently NOT NULL
    phone TEXT NOT NULL UNIQUE,
    email TEXT,
    auth_id UUID,                            -- Currently stores Supabase Auth UUID
    auth_provider TEXT DEFAULT 'SUPABASE'::text NOT NULL,
    -- ... other fields
);
```

### Current Authentication Flow

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Flutter   │────1───▶│  Supabase    │────2───▶│   Supabase   │
│   App       │◀───3────│  Auth SDK    │◀───4────│   Database   │
└─────────────┘         └──────────────┘         └──────────────┘

1. signInWithPhone(phone) → Supabase sends OTP via SMS
2. verifyOTP(phone, code) → Supabase verifies OTP
3. Returns Supabase User object (user.id as UUID)
4. Customer record linked via auth_id = user.id
```

### Current Code Structure

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart      ← Uses Supabase Auth
│   ├── models/
│   │   └── user_model.dart                  ← Maps Supabase User
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── sign_in_with_phone_usecase.dart
│       └── verify_otp_usecase.dart
└── presentation/
    ├── pages/
    │   ├── login_page.dart
    │   └── otp_page.dart
    └── providers/
        └── auth_providers.dart
```

---

## 🎯 Target State (Firebase Phone Auth)

### New Authentication Flow

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Flutter   │────1───▶│   Firebase   │────2───▶│   Supabase   │
│   App       │◀───3────│   Auth SDK   │◀───4────│   Database   │
└─────────────┘         └────────┬─────┘         └──────────────┘
                                 │
                                 5. Auto-create customer if not exists
                                    ├─ auth_id = Firebase UID (string)
                                    ├─ auth_provider = 'FIREBASE_SMS'
                                    └─ name = null (to be filled later)
```

**Flow Steps:**

1. User enters phone → Firebase sends OTP (FREE)
2. User enters OTP → Firebase verifies & returns User (UID as string)
3. Check if customer exists in Supabase by phone
4. If not exists, create new customer:
   - `auth_id` = Firebase UID
   - `auth_provider` = 'FIREBASE_SMS'
   - `name` = null (user fills later in profile setup)
5. Return authenticated user to app

### Database Schema Changes Required

```sql
-- Step 1: Allow name to be nullable (for new users)
ALTER TABLE customers
ALTER COLUMN name DROP NOT NULL;

-- Step 2: Change auth_id from UUID to TEXT to support Firebase UID
ALTER TABLE customers
ALTER COLUMN auth_id TYPE TEXT;

-- Step 3: Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_customers_phone
ON customers(phone);

CREATE INDEX IF NOT EXISTS idx_customers_auth_id
ON customers(auth_id);
```

---

## 📝 Detailed Implementation Steps

## Phase 1: Database Migration ✅ **COMPLETED**

**Status:** ✅ Already executed in Supabase by user

**Completed Changes:**

- ✅ `customers.name` changed to nullable
- ✅ `customers.auth_id` changed from UUID to TEXT
- ✅ `customers.auth_provider` constraint added (SUPABASE | FIREBASE_SMS)
- ✅ Indexes created on phone, auth_id, auth_provider

**No further action needed for Phase 1.**

---

### ~~Step 1.1: Backup Current Data~~ ✅ SKIPPED

~~Already handled by user~~

---

### ~~Step 1.2: Create Migration File~~ ✅ SKIPPED

**File:** `database/migrations/005_firebase_auth_migration.sql` (for reference only)

```sql
-- Migration: Support Firebase Phone Authentication
-- Date: 2025-10-08
-- Description: Modify customers table to support Firebase Auth UIDs

BEGIN;

-- Step 1: Allow name to be NULL for new Firebase users
-- (they will fill it during profile setup)
ALTER TABLE customers
ALTER COLUMN name DROP NOT NULL;

COMMENT ON COLUMN customers.name IS 'Customer name - can be NULL for new users during registration';

-- Step 2: Change auth_id from UUID to TEXT
-- This supports both Supabase UUID and Firebase string UIDs
ALTER TABLE customers
ALTER COLUMN auth_id TYPE TEXT USING auth_id::TEXT;

COMMENT ON COLUMN customers.auth_id IS 'Authentication provider user ID - UUID for Supabase, string for Firebase';

-- Step 3: Update default value for auth_provider
-- Keep existing default but allow FIREBASE_SMS
ALTER TABLE customers
ALTER COLUMN auth_provider DROP DEFAULT;

ALTER TABLE customers
ALTER COLUMN auth_provider SET DEFAULT 'FIREBASE_SMS';

ALTER TABLE customers
ADD CONSTRAINT check_auth_provider
CHECK (auth_provider IN ('SUPABASE', 'FIREBASE_SMS'));

-- Step 4: Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_customers_phone
ON customers(phone);

CREATE INDEX IF NOT EXISTS idx_customers_auth_id
ON customers(auth_id)
WHERE auth_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_customers_auth_provider
ON customers(auth_provider);

-- Step 5: Add trigger to update updated_at
CREATE OR REPLACE FUNCTION update_customers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS customers_updated_at_trigger ON customers;

CREATE TRIGGER customers_updated_at_trigger
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_customers_updated_at();

COMMIT;
```

**Rollback Script:**

```sql
-- Rollback: Revert to Supabase-only auth
BEGIN;

ALTER TABLE customers
ALTER COLUMN name SET NOT NULL;

ALTER TABLE customers
ALTER COLUMN auth_id TYPE UUID USING auth_id::UUID;

ALTER TABLE customers
ALTER COLUMN auth_provider SET DEFAULT 'SUPABASE';

DROP CONSTRAINT IF EXISTS check_auth_provider ON customers;

COMMIT;
```

---

### ~~Step 1.3: Execute Migration~~ ✅ COMPLETED

**Status:** ✅ Already executed by user in Supabase

**Optional Verification SQL (run in Supabase SQL Editor):**

```sql
-- 1. Verify column changes
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'customers'
    AND column_name IN ('name', 'auth_id', 'auth_provider')
ORDER BY column_name;

-- Expected:
-- auth_id: text, YES
-- auth_provider: text, NO
-- name: text, YES ✅

-- 2. Test Firebase UID insert (will clean up after)
INSERT INTO customers (
    name, phone, auth_id, auth_provider
) VALUES (
    NULL, '+6281999999999', 'test_firebase_uid', 'FIREBASE_SMS'
) RETURNING id, phone, auth_id, auth_provider, name;

-- Should succeed with NULL name ✅

-- Clean up
DELETE FROM customers WHERE phone = '+6281999999999';
```

**✅ If tests pass, database is ready for Phase 2 (Firebase Setup).**

---

## Phase 2: Firebase Setup (2-3 hours)

### Step 2.1: Create Firebase Project

**Owner:** @architect.mdc, @dev.mdc

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `allnimall-qr-prod`
4. Disable Google Analytics (optional)
5. Click "Create Project"

**Result:**

- ✅ Firebase project created
- ✅ Project ID noted: `allnimall-qr-prod`

---

### Step 2.2: Enable Phone Authentication

**Owner:** @dev.mdc

1. In Firebase Console → Authentication
2. Click "Get Started"
3. Go to "Sign-in method" tab
4. Click "Phone" provider
5. Toggle "Enable"
6. Save

**SMS Quota:**

- Free tier: 10,000 verifications/month
- No credit card required
- Auto-scales if needed

---

### Step 2.3: Register Android App

**Owner:** @dev.mdc

1. Firebase Console → Project Settings
2. Click Android icon
3. Enter package name: `com.allnimall.qr` (from `android/app/build.gradle`)
4. Download `google-services.json`
5. Place in `android/app/google-services.json`

**Update `android/build.gradle`:**

```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**Update `android/app/build.gradle`:**

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

// Add this line at the bottom
apply plugin: 'com.google.gms.google-services'
```

---

### Step 2.4: Register iOS App

**Owner:** @dev.mdc

1. Firebase Console → Project Settings
2. Click iOS icon
3. Enter bundle ID: `com.allnimall.qr` (from `ios/Runner/Info.plist`)
4. Download `GoogleService-Info.plist`
5. Open Xcode → `ios/Runner.xcworkspace`
6. Drag `GoogleService-Info.plist` to `Runner/` folder
7. Ensure "Copy items if needed" is checked

**Update `ios/Runner/Info.plist`:**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

---

### Step 2.5: Add Flutter Dependencies

**Owner:** @dev.mdc

**Update `pubspec.yaml`:**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing dependencies
  supabase_flutter: ^2.6.0
  riverpod: ^2.6.1
  # ... other existing deps

  # NEW: Firebase dependencies
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
```

**Run:**

```bash
flutter pub get
```

---

## Phase 3: Code Implementation (4-6 hours)

### Step 3.1: Initialize Firebase in main.dart

**Owner:** @dev.mdc

**File:** `lib/main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Auto-generated by FlutterFire CLI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase BEFORE Supabase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}
```

**Generate `firebase_options.dart`:**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate firebase_options.dart
flutterfire configure --project=allnimall-qr-prod
```

---

### Step 3.2: Create Firebase Auth Data Source

**Owner:** @dev.mdc

**File:** `lib/features/auth/data/datasources/firebase_auth_remote_datasource.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/exceptions.dart' as exceptions;
import '../../../../core/utils/logger.dart';

abstract class FirebaseAuthRemoteDataSource {
  /// Sign in with phone number and send OTP via Firebase
  Future<String> signInWithPhone(String phoneNumber);

  /// Verify OTP code from Firebase
  Future<firebase_auth.User> verifyOTP(String verificationId, String otpCode);

  /// Get current Firebase user
  Future<firebase_auth.User?> getCurrentUser();

  /// Sign out from Firebase
  Future<void> signOut();
}

class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<String> signInWithPhone(String phoneNumber) async {
    try {
      AppLogger.info('Firebase: Signing in with phone: $phoneNumber');

      // Normalize phone number to E.164 format (+62xxx)
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);

      // Completer to handle async verification
      final completer = Completer<String>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,

        // Timeout after 60 seconds
        timeout: const Duration(seconds: 60),

        // Called when SMS code is sent
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.info('Firebase: OTP sent successfully');
          completer.complete(verificationId);
        },

        // Called when verification completes automatically (Android auto-verify)
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          AppLogger.info('Firebase: Auto-verification completed');
          // This happens on Android when SMS is auto-read
          // We don't complete here, let user enter OTP manually
        },

        // Called when verification fails
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          AppLogger.error('Firebase: Verification failed', e);
          completer.completeError(
            exceptions.AuthException(
              e.message ?? 'Phone verification failed',
              e.code,
            ),
          );
        },

        // Called when timeout occurs
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.warn('Firebase: Auto-retrieval timeout');
          if (!completer.isCompleted) {
            completer.complete(verificationId);
          }
        },
      );

      return await completer.future;

    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during sign in', e);
      throw exceptions.AuthException(
        e.message ?? 'Failed to send OTP',
        e.code,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during Firebase sign in', e, stackTrace);
      throw exceptions.ServerException('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<firebase_auth.User> verifyOTP(
    String verificationId,
    String otpCode,
  ) async {
    try {
      AppLogger.info('Firebase: Verifying OTP');

      // Create credential from verification ID and OTP code
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      // Sign in with credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw exceptions.AuthException('OTP verification failed');
      }

      AppLogger.info('Firebase: OTP verified successfully');
      AppLogger.info('Firebase UID: ${userCredential.user!.uid}');

      return userCredential.user!;

    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during OTP verification', e);

      if (e.code == 'invalid-verification-code') {
        throw exceptions.InvalidOTPException('Invalid OTP code');
      } else if (e.code == 'session-expired') {
        throw exceptions.OTPExpiredException('OTP has expired');
      }

      throw exceptions.AuthException(
        e.message ?? 'OTP verification failed',
        e.code,
      );

    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during OTP verification', e, stackTrace);
      throw exceptions.ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<firebase_auth.User?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      AppLogger.debug('Current Firebase user: ${user?.uid}');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting current Firebase user', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      AppLogger.info('Firebase: Signed out successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Error signing out from Firebase', e, stackTrace);
      throw exceptions.ServerException('Failed to sign out');
    }
  }

  /// Normalize phone number to E.164 format
  /// Indonesia: +62xxx
  String _normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If starts with '0', replace with '62'
    if (digitsOnly.startsWith('0')) {
      digitsOnly = '62${digitsOnly.substring(1)}';
    }

    // If starts with '62', add '+'
    if (digitsOnly.startsWith('62')) {
      return '+$digitsOnly';
    }

    // If starts with '8', add '+62'
    if (digitsOnly.startsWith('8')) {
      return '+62$digitsOnly';
    }

    // Already starts with '+', return as is
    if (phoneNumber.startsWith('+')) {
      return phoneNumber;
    }

    // Default: assume Indonesia number
    return '+62$digitsOnly';
  }
}
```

---

### Step 3.3: Create Supabase Customer Data Source

**Owner:** @dev.mdc

**File:** `lib/features/auth/data/datasources/customer_remote_datasource.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart' as exceptions;
import '../../../../core/utils/logger.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  /// Check if customer exists by phone number
  Future<CustomerModel?> getCustomerByPhone(String phone);

  /// Check if customer exists by auth_id
  Future<CustomerModel?> getCustomerByAuthId(String authId);

  /// Create new customer after Firebase auth
  Future<CustomerModel> createCustomer({
    required String phone,
    required String authId,
    required String authProvider,
    String? name,
  });

  /// Update customer profile
  Future<CustomerModel> updateCustomer(String id, Map<String, dynamic> updates);
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final SupabaseClient _supabase;

  CustomerRemoteDataSourceImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseConfig.instance;

  @override
  Future<CustomerModel?> getCustomerByPhone(String phone) async {
    try {
      AppLogger.info('Checking if customer exists with phone: $phone');

      final response = await _supabase
          .from('customers')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (response == null) {
        AppLogger.info('Customer not found with phone: $phone');
        return null;
      }

      AppLogger.info('Customer found: ${response['id']}');
      return CustomerModel.fromJson(response);

    } catch (e, stackTrace) {
      AppLogger.error('Error getting customer by phone', e, stackTrace);
      throw exceptions.ServerException('Failed to get customer: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel?> getCustomerByAuthId(String authId) async {
    try {
      AppLogger.info('Checking if customer exists with auth_id: $authId');

      final response = await _supabase
          .from('customers')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();

      if (response == null) {
        AppLogger.info('Customer not found with auth_id: $authId');
        return null;
      }

      AppLogger.info('Customer found: ${response['id']}');
      return CustomerModel.fromJson(response);

    } catch (e, stackTrace) {
      AppLogger.error('Error getting customer by auth_id', e, stackTrace);
      throw exceptions.ServerException('Failed to get customer: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel> createCustomer({
    required String phone,
    required String authId,
    required String authProvider,
    String? name,
  }) async {
    try {
      AppLogger.info('Creating new customer with phone: $phone');

      final customerData = {
        'phone': phone,
        'auth_id': authId,
        'auth_provider': authProvider,
        'name': name, // Can be null for Firebase users
        'membership_type': 'free',
        'level': 1,
        'experience_points': 0,
        'loyalty_points': 0,
        'total_orders': 0,
        'total_spent': 0,
      };

      final response = await _supabase
          .from('customers')
          .insert(customerData)
          .select()
          .single();

      AppLogger.info('Customer created successfully: ${response['id']}');
      return CustomerModel.fromJson(response);

    } on PostgrestException catch (e) {
      AppLogger.error('Postgres error creating customer', e);

      if (e.code == '23505') {
        // Unique constraint violation (phone already exists)
        throw exceptions.DuplicatePhoneException(
          'Phone number already registered',
        );
      }

      throw exceptions.ServerException('Failed to create customer: ${e.message}');

    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating customer', e, stackTrace);
      throw exceptions.ServerException('Failed to create customer: ${e.toString()}');
    }
  }

  @override
  Future<CustomerModel> updateCustomer(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      AppLogger.info('Updating customer: $id');

      final response = await _supabase
          .from('customers')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      AppLogger.info('Customer updated successfully');
      return CustomerModel.fromJson(response);

    } catch (e, stackTrace) {
      AppLogger.error('Error updating customer', e, stackTrace);
      throw exceptions.ServerException('Failed to update customer: ${e.toString()}');
    }
  }
}
```

---

### Step 3.4: Create Customer Model

**Owner:** @dev.mdc

**File:** `lib/features/auth/data/models/customer_model.dart`

```dart
import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.phone,
    required super.authId,
    required super.authProvider,
    super.name,
    super.email,
    super.pictureUrl,
    super.membershipType,
    super.level,
    super.experiencePoints,
    super.loyaltyPoints,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      authId: json['auth_id'] as String,
      authProvider: json['auth_provider'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      pictureUrl: json['picture_url'] as String?,
      membershipType: json['membership_type'] as String? ?? 'free',
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experience_points'] as int? ?? 0,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'auth_id': authId,
      'auth_provider': authProvider,
      'name': name,
      'email': email,
      'picture_url': pictureUrl,
      'membership_type': membershipType,
      'level': level,
      'experience_points': experiencePoints,
      'loyalty_points': loyaltyPoints,
    };
  }

  CustomerEntity toEntity() => this;
}
```

**File:** `lib/features/auth/domain/entities/customer_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String phone;
  final String authId;
  final String authProvider; // 'FIREBASE_SMS' or 'SUPABASE'
  final String? name;
  final String? email;
  final String? pictureUrl;
  final String membershipType;
  final int level;
  final int experiencePoints;
  final int loyaltyPoints;

  const CustomerEntity({
    required this.id,
    required this.phone,
    required this.authId,
    required this.authProvider,
    this.name,
    this.email,
    this.pictureUrl,
    this.membershipType = 'free',
    this.level = 1,
    this.experiencePoints = 0,
    this.loyaltyPoints = 0,
  });

  bool get isFirebaseAuth => authProvider == 'FIREBASE_SMS';
  bool get isSupabaseAuth => authProvider == 'SUPABASE';
  bool get hasCompletedProfile => name != null && name!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        phone,
        authId,
        authProvider,
        name,
        email,
        pictureUrl,
        membershipType,
        level,
        experiencePoints,
        loyaltyPoints,
      ];
}
```

---

### Step 3.5: Update Auth Repository

**Owner:** @dev.mdc

**File:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart' as exceptions;
import '../../../../core/utils/logger.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_remote_datasource.dart';
import '../datasources/customer_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthRemoteDataSource firebaseDataSource;
  final CustomerRemoteDataSource customerDataSource;

  AuthRepositoryImpl({
    required this.firebaseDataSource,
    required this.customerDataSource,
  });

  @override
  Future<Either<Failure, String>> signInWithPhone(String phoneNumber) async {
    try {
      // Send OTP via Firebase (FREE)
      final verificationId = await firebaseDataSource.signInWithPhone(phoneNumber);
      return Right(verificationId);

    } on exceptions.AuthException catch (e) {
      AppLogger.error('Auth exception during sign in', e);
      return Left(AuthFailure(e.message));
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception during sign in', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during sign in', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> verifyOTP(
    String verificationId,
    String otpCode,
    String phoneNumber,
  ) async {
    try {
      AppLogger.info('Step 1: Verifying OTP with Firebase');

      // Step 1: Verify OTP with Firebase
      final firebaseUser = await firebaseDataSource.verifyOTP(
        verificationId,
        otpCode,
      );

      AppLogger.info('Step 2: Firebase verification successful');
      AppLogger.info('Firebase UID: ${firebaseUser.uid}');
      AppLogger.info('Phone: ${firebaseUser.phoneNumber}');

      // Step 2: Check if customer exists in Supabase by phone
      CustomerModel? customer = await customerDataSource.getCustomerByPhone(
        phoneNumber,
      );

      // Step 3: If customer doesn't exist, create new one
      if (customer == null) {
        AppLogger.info('Step 3: Customer not found, creating new customer');

        customer = await customerDataSource.createCustomer(
          phone: phoneNumber,
          authId: firebaseUser.uid, // Firebase UID as string
          authProvider: 'FIREBASE_SMS',
          name: null, // Will be filled during profile setup
        );

        AppLogger.info('Step 4: New customer created: ${customer.id}');
      } else {
        AppLogger.info('Step 3: Existing customer found: ${customer.id}');

        // Update auth_id and auth_provider if migrating from Supabase
        if (customer.authProvider != 'FIREBASE_SMS') {
          AppLogger.info('Migrating customer from ${customer.authProvider} to FIREBASE_SMS');

          customer = await customerDataSource.updateCustomer(
            customer.id,
            {
              'auth_id': firebaseUser.uid,
              'auth_provider': 'FIREBASE_SMS',
            },
          );
        }
      }

      AppLogger.info('Step 5: Authentication complete');
      return Right(customer.toEntity());

    } on exceptions.InvalidOTPException catch (e) {
      AppLogger.error('Invalid OTP exception', e);
      return Left(InvalidOTPFailure(e.message));
    } on exceptions.OTPExpiredException catch (e) {
      AppLogger.error('OTP expired exception', e);
      return Left(OTPExpiredFailure(e.message));
    } on exceptions.DuplicatePhoneException catch (e) {
      AppLogger.error('Duplicate phone exception', e);
      return Left(AuthFailure('Phone number already registered'));
    } on exceptions.AuthException catch (e) {
      AppLogger.error('Auth exception during OTP verification', e);
      return Left(AuthFailure(e.message));
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception during OTP verification', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during OTP verification', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity?>> getCurrentUser() async {
    try {
      // Get current Firebase user
      final firebaseUser = await firebaseDataSource.getCurrentUser();

      if (firebaseUser == null) {
        return const Right(null);
      }

      // Get customer from Supabase using Firebase UID
      final customer = await customerDataSource.getCustomerByAuthId(
        firebaseUser.uid,
      );

      if (customer == null) {
        AppLogger.warn('Firebase user exists but no customer record found');
        return const Right(null);
      }

      return Right(customer.toEntity());

    } catch (e, stackTrace) {
      AppLogger.error('Error getting current user', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await firebaseDataSource.signOut();
      return const Right(null);
    } catch (e, stackTrace) {
      AppLogger.error('Error signing out', e, stackTrace);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final firebaseUser = await firebaseDataSource.getCurrentUser();
      return Right(firebaseUser != null);
    } catch (e, stackTrace) {
      AppLogger.error('Error checking authentication', e, stackTrace);
      return const Right(false);
    }
  }

  @override
  Stream<CustomerEntity?> get authStateChanges {
    return firebase_auth.FirebaseAuth.instance
        .authStateChanges()
        .asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        final customer = await customerDataSource.getCustomerByAuthId(
          firebaseUser.uid,
        );
        return customer?.toEntity();
      } catch (e) {
        AppLogger.error('Error in auth state changes', e);
        return null;
      }
    });
  }
}
```

---

### Step 3.6: Update Use Cases

**Owner:** @dev.mdc

**File:** `lib/features/auth/domain/usecases/verify_otp_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../entities/customer_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOTPUseCase {
  final AuthRepository repository;

  VerifyOTPUseCase(this.repository);

  /// Verify OTP and authenticate user
  ///
  /// Parameters:
  /// - verificationId: Firebase verification ID from signInWithPhone
  /// - otpCode: 6-digit OTP code entered by user
  /// - phoneNumber: User's phone number in E.164 format
  Future<Either<Failure, CustomerEntity>> call({
    required String verificationId,
    required String otpCode,
    required String phoneNumber,
  }) async {
    // Validate phone number
    final phoneValidationError = Validators.phone(phoneNumber);
    if (phoneValidationError != null) {
      return Left(ValidationFailure(phoneValidationError));
    }

    // Validate OTP code (must be 6 digits)
    final otpValidationError = Validators.otp(otpCode);
    if (otpValidationError != null) {
      return Left(ValidationFailure(otpValidationError));
    }

    // Verify OTP with Firebase and create/get customer
    return await repository.verifyOTP(verificationId, otpCode, phoneNumber);
  }
}
```

**File:** `lib/features/auth/domain/usecases/sign_in_with_phone_usecase.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class SignInWithPhoneUseCase {
  final AuthRepository repository;

  SignInWithPhoneUseCase(this.repository);

  /// Send OTP to phone number via Firebase
  ///
  /// Returns verification ID to be used in verifyOTP
  Future<Either<Failure, String>> call(String phoneNumber) async {
    // Validate phone number
    final phoneValidationError = Validators.phone(phoneNumber);
    if (phoneValidationError != null) {
      return Left(ValidationFailure(phoneValidationError));
    }

    return await repository.signInWithPhone(phoneNumber);
  }
}
```

---

### Step 3.7: Update Auth Providers

**Owner:** @dev.mdc

**File:** `lib/features/auth/presentation/providers/auth_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/config/supabase_config.dart';
import '../../data/datasources/firebase_auth_remote_datasource.dart';
import '../../data/datasources/customer_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/is_authenticated_usecase.dart';
import '../../domain/usecases/sign_in_with_phone_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

// Data Sources
final firebaseAuthRemoteDataSourceProvider = Provider<FirebaseAuthRemoteDataSource>((ref) {
  return FirebaseAuthRemoteDataSourceImpl(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
  );
});

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((ref) {
  return CustomerRemoteDataSourceImpl(
    supabase: SupabaseConfig.instance,
  );
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseDataSource: ref.watch(firebaseAuthRemoteDataSourceProvider),
    customerDataSource: ref.watch(customerRemoteDataSourceProvider),
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
final authStateChangesProvider = StreamProvider<CustomerEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

// Current User
final currentUserProvider = FutureProvider<CustomerEntity?>((ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => null,
    (customer) => customer,
  );
});

// Verification ID state (for OTP flow)
final verificationIdProvider = StateProvider<String?>((ref) => null);
```

---

### Step 3.8: Update UI (Login & OTP Pages)

**Owner:** @dev.mdc

**File:** `lib/features/auth/presentation/pages/login_page.dart`

```dart
// Update the login button handler:

Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final phoneNumber = _phoneController.text.trim();

  // Call sign in use case
  final result = await ref.read(signInWithPhoneUseCaseProvider).call(phoneNumber);

  result.fold(
    (failure) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    },
    (verificationId) {
      setState(() => _isLoading = false);

      // Store verification ID for OTP page
      ref.read(verificationIdProvider.notifier).state = verificationId;

      // Navigate to OTP page
      context.go('/otp', extra: {
        'phoneNumber': phoneNumber,
        'verificationId': verificationId,
      });
    },
  );
}
```

**File:** `lib/features/auth/presentation/pages/otp_page.dart`

```dart
// Update the verify OTP handler:

Future<void> _handleVerifyOTP() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final otpCode = _otpController.text.trim();
  final verificationId = ref.read(verificationIdProvider);

  if (verificationId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification ID not found. Please try again.')),
    );
    setState(() => _isLoading = false);
    return;
  }

  // Call verify OTP use case
  final result = await ref.read(verifyOTPUseCaseProvider).call(
    verificationId: verificationId!,
    otpCode: otpCode,
    phoneNumber: widget.phoneNumber,
  );

  result.fold(
    (failure) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
    },
    (customer) {
      setState(() => _isLoading = false);

      // Check if user needs to complete profile
      if (!customer.hasCompletedProfile) {
        // Navigate to profile setup
        context.go('/profile-setup');
      } else {
        // Navigate to dashboard
        context.go('/dashboard');
      }
    },
  );
}
```

---

## Phase 4: Testing & Validation (2-3 hours)

### Step 4.1: Unit Tests

**Owner:** @dev.mdc

**File:** `test/features/auth/data/datasources/firebase_auth_remote_datasource_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

@GenerateMocks([firebase_auth.FirebaseAuth])
void main() {
  late FirebaseAuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    dataSource = FirebaseAuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
    );
  });

  group('signInWithPhone', () {
    test('should return verification ID when OTP is sent successfully', () async {
      // Arrange
      const phoneNumber = '+6281234567890';
      const verificationId = 'test_verification_id_123';

      when(mockFirebaseAuth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        timeout: anyNamed('timeout'),
      )).thenAnswer((invocation) async {
        final codeSent = invocation.namedArguments[Symbol('codeSent')]
            as void Function(String, int?);
        codeSent(verificationId, null);
      });

      // Act
      final result = await dataSource.signInWithPhone(phoneNumber);

      // Assert
      expect(result, verificationId);
      verify(mockFirebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeSent: anyNamed('codeSent'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        timeout: anyNamed('timeout'),
      )).called(1);
    });
  });

  group('verifyOTP', () {
    test('should return Firebase user when OTP is verified successfully', () async {
      // Arrange
      const verificationId = 'test_verification_id_123';
      const otpCode = '123456';
      final mockUser = MockUser();
      final mockUserCredential = MockUserCredential();

      when(mockUser.uid).thenReturn('firebase_uid_abc123');
      when(mockUser.phoneNumber).thenReturn('+6281234567890');
      when(mockUserCredential.user).thenReturn(mockUser);

      when(mockFirebaseAuth.signInWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final result = await dataSource.verifyOTP(verificationId, otpCode);

      // Assert
      expect(result.uid, 'firebase_uid_abc123');
      expect(result.phoneNumber, '+6281234567890');
    });
  });
}
```

---

### Step 4.2: Integration Tests

**Owner:** @dev.mdc, @analyst.mdc

**Test Scenarios:**

```dart
// Scenario 1: New user registration
test('New user can register with Firebase phone auth', () async {
  // 1. Enter phone number: +6281234567890
  // 2. Receive OTP from Firebase
  // 3. Enter valid OTP: 123456
  // 4. Verify customer is created in Supabase with:
  //    - auth_id = Firebase UID
  //    - auth_provider = 'FIREBASE_SMS'
  //    - name = null
  // 5. Navigate to profile setup page
});

// Scenario 2: Existing Supabase user migrates to Firebase
test('Existing Supabase user can login with Firebase', () async {
  // 1. User with existing Supabase auth tries Firebase login
  // 2. Enter same phone number
  // 3. Enter Firebase OTP
  // 4. Verify customer record is updated:
  //    - auth_id updated to Firebase UID
  //    - auth_provider updated to 'FIREBASE_SMS'
  // 5. Navigate to dashboard (profile already complete)
});

// Scenario 3: Invalid OTP
test('Invalid OTP shows error message', () async {
  // 1. Enter phone number
  // 2. Receive OTP
  // 3. Enter wrong OTP: 000000
  // 4. Verify error message: "Invalid OTP code"
});

// Scenario 4: Expired OTP
test('Expired OTP shows error message', () async {
  // 1. Enter phone number
  // 2. Wait for OTP to expire (60 seconds)
  // 3. Enter OTP after expiration
  // 4. Verify error message: "OTP has expired"
});

// Scenario 5: Resend OTP
test('User can resend OTP', () async {
  // 1. Enter phone number
  // 2. Don't receive OTP (network issue)
  // 3. Click "Resend OTP" button
  // 4. Receive new verification ID
  // 5. Enter new OTP
  // 6. Verify successfully
});
```

---

### Step 4.3: Manual Testing Checklist

**Owner:** @analyst.mdc, @dev.mdc

**Android Testing:**

- [ ] Install app on Android device
- [ ] Enable phone number verification in Firebase Console
- [ ] Test new user registration flow
- [ ] Verify SMS received from Firebase (not Supabase)
- [ ] Check customer record created in Supabase
- [ ] Test auto-verification on Android (SMS auto-read)
- [ ] Test offline scenario (no internet)
- [ ] Test airplane mode → back online

**iOS Testing:**

- [ ] Install app on iOS device
- [ ] Configure APNs in Firebase Console
- [ ] Test new user registration flow
- [ ] Verify SMS received from Firebase
- [ ] Check customer record created in Supabase
- [ ] Test notification permissions
- [ ] Test offline scenario

**Edge Cases:**

- [ ] Phone number in different formats: 081234567890, +6281234567890, 6281234567890
- [ ] Invalid phone number: 0123 (too short)
- [ ] Rapid OTP requests (rate limiting)
- [ ] Multiple devices with same phone number
- [ ] Account deletion → re-registration

---

## Phase 5: Deployment & Monitoring (1-2 hours)

### Step 5.1: Feature Flag Setup

**Owner:** @architect.mdc, @dev.mdc

**Add feature flag in Supabase:**

```sql
CREATE TABLE IF NOT EXISTS feature_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_name TEXT NOT NULL UNIQUE,
    is_enabled BOOLEAN NOT NULL DEFAULT false,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Add Firebase auth flag
INSERT INTO feature_flags (feature_name, is_enabled, description)
VALUES (
    'firebase_phone_auth',
    true, -- Set to false initially, enable after testing
    'Enable Firebase Phone Authentication instead of Supabase OTP'
);
```

**Check flag in app:**

```dart
final featureFlagProvider = FutureProvider<bool>((ref) async {
  final supabase = SupabaseConfig.instance;

  final result = await supabase
      .from('feature_flags')
      .select('is_enabled')
      .eq('feature_name', 'firebase_phone_auth')
      .single();

  return result['is_enabled'] as bool;
});

// In login page, choose auth method based on flag
final useFirebaseAuth = await ref.read(featureFlagProvider.future);
if (useFirebaseAuth) {
  // Use Firebase auth
} else {
  // Use Supabase auth (fallback)
}
```

---

### Step 5.2: Gradual Rollout Strategy

**Owner:** @pm.mdc, @dev.mdc

**Week 1: Internal Testing**

- Enable Firebase auth for internal testers only (10 users)
- Monitor error rates, OTP delivery success
- Verify customer creation in Supabase

**Week 2: Beta Users (10%)**

- Enable for 10% of users (feature flag)
- Monitor metrics:
  - OTP delivery time (<5 seconds)
  - OTP success rate (>95%)
  - Customer creation errors (<1%)

**Week 3: Expand to 50%**

- If Week 2 metrics are good, enable for 50% of users
- Monitor cost savings (Supabase OTP usage down)

**Week 4: Full Rollout (100%)**

- Enable for all users
- Disable Supabase OTP completely
- Archive old Supabase auth code

---

### Step 5.3: Monitoring & Alerts

**Owner:** @architect.mdc, @dev.mdc

**Key Metrics to Monitor:**

1. **OTP Delivery Success Rate**

   - Target: >95%
   - Alert if <90%

2. **OTP Verification Success Rate**

   - Target: >80% (accounting for user errors)
   - Alert if <70%

3. **Customer Creation Errors**

   - Target: <1%
   - Alert if >5%

4. **Average OTP Delivery Time**

   - Target: <5 seconds
   - Alert if >10 seconds

5. **Firebase Quota Usage**
   - Monitor daily OTP count
   - Alert if approaching 10,000/month (free tier limit)

**Set up Sentry Error Tracking:**

```dart
// In main.dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_SENTRY_DSN';
    options.tracesSampleRate = 1.0;
    options.beforeSend = (event, hint) {
      // Filter out Firebase auth errors we want to track
      if (event.exceptions?.any((e) => e.type == 'FirebaseAuthException') ?? false) {
        return event;
      }
      return event;
    };
  },
  appRunner: () => runApp(const MyApp()),
);
```

---

## Phase 6: Documentation & Knowledge Transfer (1 hour)

### Step 6.1: Update Technical Documentation

**Owner:** @pm.mdc, @dev.mdc

**Update README.md:**

````markdown
## Authentication

Allnimall QR uses **Firebase Phone Authentication** for user login:

- OTP sent via Firebase (free, unlimited)
- Customer data stored in Supabase
- Dual auth provider support: `FIREBASE_SMS` and `SUPABASE` (legacy)

### Setup Firebase

1. Create Firebase project
2. Enable Phone Authentication
3. Add Android/iOS apps
4. Download config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
5. Run `flutterfire configure`

### Environment Variables

```env
FIREBASE_PROJECT_ID=allnimall-qr-prod
```
````

````

---

### Step 6.2: Create Migration Runbook

**Owner:** @architect.mdc

**File:** `docs/firebase-auth-runbook.md`

```markdown
# Firebase Auth Migration Runbook

## Pre-Migration Checklist

- [ ] Database backup completed
- [ ] Migration SQL tested on staging
- [ ] Firebase project created and configured
- [ ] APNs certificates uploaded
- [ ] Feature flag table created

## Migration Steps

1. Run database migration (005_firebase_auth_migration.sql)
2. Verify migration with test queries
3. Deploy app with Firebase auth code
4. Enable feature flag for 10% of users
5. Monitor metrics for 24 hours
6. Gradually increase to 100%

## Rollback Plan

If critical issues found:

1. Set feature flag `firebase_phone_auth` = false
2. App falls back to Supabase auth
3. Investigate issues
4. Fix and retry

## Support Contacts

- Firebase issues: @dev.mdc
- Database issues: @architect.mdc
- User issues: @analyst.mdc
````

---

## 📊 Success Metrics

**Technical Metrics:**

| Metric                 | Baseline (Supabase) | Target (Firebase) | Status |
| ---------------------- | ------------------- | ----------------- | ------ |
| OTP Delivery Time      | ~8 seconds          | <5 seconds        | ⏳     |
| OTP Success Rate       | 92%                 | >95%              | ⏳     |
| Monthly Cost (OTP)     | $50-100             | $0 (free)         | ⏳     |
| Customer Creation Time | ~2 seconds          | <1 second         | ⏳     |
| Error Rate             | <2%                 | <1%               | ⏳     |

**Business Metrics:**

| Metric                  | Target            | Status |
| ----------------------- | ----------------- | ------ |
| Cost Savings            | $600-1200/year    | ⏳     |
| User Registration Rate  | +10% (faster OTP) | ⏳     |
| Authentication Failures | -20%              | ⏳     |

---

## 🚨 Risks & Mitigation

| Risk                            | Impact | Probability | Mitigation                           |
| ------------------------------- | ------ | ----------- | ------------------------------------ |
| Firebase service outage         | High   | Low         | Feature flag rollback to Supabase    |
| SMS quota exceeded              | Medium | Low         | Monitor usage, upgrade if needed     |
| Migration breaks existing users | High   | Medium      | Dual auth support, gradual rollout   |
| Customer creation fails         | High   | Low         | Extensive testing, error logging     |
| APNs certificate issues         | Medium | Medium      | Test thoroughly on iOS before launch |

---

## 📅 Timeline Summary

| Phase                            | Duration                  | Owner                    | Status          |
| -------------------------------- | ------------------------- | ------------------------ | --------------- |
| Phase 1: Database Migration      | ~~1-2 hours~~             | @architect.mdc, @dev.mdc | ✅ **DONE**     |
| Phase 2: Firebase Setup          | 2-3 hours                 | @dev.mdc                 | 🔄 **NEXT**     |
| Phase 3: Code Implementation     | 4-6 hours                 | @dev.mdc                 | ⏳ Pending      |
| Phase 4: Testing & Validation    | 2-3 hours                 | @dev.mdc, @analyst.mdc   | ⏳ Pending      |
| Phase 5: Deployment & Monitoring | 1-2 hours                 | @pm.mdc, @dev.mdc        | ⏳ Pending      |
| Phase 6: Documentation           | 1 hour                    | @pm.mdc, @dev.mdc        | ⏳ Pending      |
| **TOTAL**                        | **10-15 hours** (~2 days) | All                      | **30% Done** ✅ |

**Gradual Rollout:**

- Week 1: Internal testing (10 users)
- Week 2: 10% rollout
- Week 3: 50% rollout
- Week 4: 100% rollout

---

## ✅ Acceptance Criteria

**Must Have:**

- [x] ✅ Database migration completed without data loss
- [ ] 🔄 Firebase project configured for Android and iOS
- [ ] ⏳ New users can register with Firebase OTP
- [ ] ⏳ Existing users can login (auth migrated)
- [ ] ⏳ Customer records created with correct auth_provider
- [ ] ⏳ OTP delivery time <5 seconds
- [ ] ⏳ Zero cost for OTP delivery

**Nice to Have:**

- [ ] Auto-verification on Android (SMS auto-read)
- [ ] Resend OTP functionality
- [ ] Rate limiting for OTP requests
- [ ] Multi-factor authentication support

---

## 📞 Support & Escalation

**For Issues:**

1. **Technical Issues:** @dev.mdc
2. **Database Issues:** @architect.mdc
3. **Firebase Console:** @dev.mdc
4. **User Experience:** @analyst.mdc
5. **Project Decisions:** @pm.mdc

**Escalation Path:**

1. Check error logs in Sentry
2. Review Firebase Console → Authentication → Phone
3. Check Supabase logs for customer creation
4. If critical: disable feature flag immediately
5. Notify all stakeholders in #allnimall-dev Slack channel

---

**END OF MIGRATION PLAN**

**Status:** ✅ Ready for implementation  
**Next Steps:** Review with team → Execute Phase 1

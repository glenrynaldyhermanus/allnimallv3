import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/error/exceptions.dart' as exceptions;
import '../../../../core/utils/logger.dart';

/// Firebase Authentication Data Source
/// Handles Firebase Phone Authentication (OTP)
abstract class FirebaseAuthDataSource {
  /// Send OTP to phone number via Firebase
  /// Returns verification ID for OTP verification
  Future<String> sendOTP(String phoneNumber);

  /// Verify OTP code with Firebase
  /// Returns Firebase User with UID
  Future<User> verifyOTP(String verificationId, String otpCode);

  /// Get current Firebase user
  Future<User?> getCurrentFirebaseUser();

  /// Sign out from Firebase
  Future<void> signOut();

  /// Stream of Firebase auth state changes
  Stream<User?> get authStateChanges;
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSourceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    // Configure invisible reCAPTCHA for web
    if (kIsWeb) {
      _configureInvisibleRecaptcha();
    }
  }

  /// Configure invisible reCAPTCHA for better UX
  void _configureInvisibleRecaptcha() {
    try {
      _firebaseAuth.setSettings(
        appVerificationDisabledForTesting: false,
        // Firebase will automatically use invisible reCAPTCHA
        // when available (Blaze Plan with reCAPTCHA Enterprise)
        // The reCAPTCHA will render in the #recaptcha-container div
      );
      AppLogger.info('✅ Invisible reCAPTCHA configured for web');
      AppLogger.info('🔐 Using reCAPTCHA container: #recaptcha-container');
    } catch (e) {
      AppLogger.warning('Could not configure reCAPTCHA settings: $e');
    }
  }

  @override
  Future<String> sendOTP(String phoneNumber) async {
    try {
      AppLogger.info('Sending OTP via Firebase to: $phoneNumber');

      // Normalize phone number to E.164 format (+62xxx)
      final normalizedPhone = _normalizePhoneNumber(phoneNumber);
      AppLogger.debug('Normalized phone: $normalizedPhone');

      final completer = Completer<String>();

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        timeout: const Duration(seconds: 120),

        // Called when Firebase auto-verifies (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          AppLogger.info('Auto-verification completed (Android)');
          // We don't auto-sign in here, user must manually enter OTP
        },

        // Called when verification fails
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.error(
            'Firebase verification failed: ${e.code} - ${e.message}',
            e,
          );
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },

        // Called when OTP is sent successfully
        codeSent: (String verId, int? resendToken) {
          AppLogger.info('OTP sent successfully. Verification ID: $verId');
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },

        // Called when auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verId) {
          AppLogger.debug('Auto-retrieval timeout. Verification ID: $verId');
          if (!completer.isCompleted) {
            completer.complete(verId);
          }
        },
      );

      // Wait for callback to complete (with timeout)
      final verificationId = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw exceptions.ServerException(
            'Phone verification timeout - no response from Firebase',
          );
        },
      );

      AppLogger.info('OTP sent successfully via Firebase (FREE!)');
      return verificationId;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase Auth error during OTP send', e);

      // Map Firebase errors to our custom exceptions
      if (e.code == 'invalid-phone-number') {
        throw exceptions.AuthException(
          'Invalid phone number format',
          'INVALID_PHONE',
        );
      } else if (e.code == 'too-many-requests') {
        throw exceptions.AuthException(
          'Too many requests. Please try again later.',
          'TOO_MANY_REQUESTS',
        );
      } else if (e.code == 'quota-exceeded') {
        throw exceptions.AuthException(
          'SMS quota exceeded. Please try again later.',
          'QUOTA_EXCEEDED',
        );
      }

      throw exceptions.AuthException(e.message ?? 'Failed to send OTP', e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during OTP send', e, stackTrace);
      throw exceptions.ServerException('Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<User> verifyOTP(String verificationId, String otpCode) async {
    try {
      AppLogger.info('Verifying OTP with Firebase');
      AppLogger.debug('Verification ID: $verificationId, OTP: $otpCode');

      // Create credential with verification ID and OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      // Sign in with credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw exceptions.AuthException(
          'OTP verification failed: No user returned',
        );
      }

      final firebaseUser = userCredential.user!;
      AppLogger.info('OTP verified successfully via Firebase');
      AppLogger.info('Firebase UID: ${firebaseUser.uid}');
      AppLogger.info('Phone: ${firebaseUser.phoneNumber}');

      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase Auth error during OTP verification', e);

      // Map Firebase errors to our custom exceptions
      if (e.code == 'invalid-verification-code') {
        throw exceptions.InvalidOTPException(
          'Invalid OTP code. Please check and try again.',
        );
      } else if (e.code == 'session-expired') {
        throw exceptions.AuthException(
          'OTP expired. Please request a new code.',
          'OTP_EXPIRED',
        );
      } else if (e.code == 'invalid-verification-id') {
        throw exceptions.AuthException(
          'Invalid verification session. Please try again.',
          'INVALID_SESSION',
        );
      }

      throw exceptions.AuthException(
        e.message ?? 'Failed to verify OTP',
        e.code,
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during OTP verification',
        e,
        stackTrace,
      );
      throw exceptions.ServerException('Failed to verify OTP: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentFirebaseUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        AppLogger.debug('Current Firebase user: ${user.uid}');
      } else {
        AppLogger.debug('No Firebase user signed in');
      }
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting current Firebase user', e, stackTrace);
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out from Firebase');
      await _firebaseAuth.signOut();
      AppLogger.info('Signed out from Firebase successfully');
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Firebase error during sign out', e);
      throw exceptions.AuthException(e.message ?? 'Failed to sign out', e.code);
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error during Firebase sign out',
        e,
        stackTrace,
      );
      throw exceptions.ServerException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  /// Normalize phone number to E.164 format (+62xxx)
  String _normalizePhoneNumber(String phone) {
    // Remove all whitespace and non-digit characters except +
    String normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If starts with 0, replace with +62
    if (normalized.startsWith('0')) {
      normalized = '+62${normalized.substring(1)}';
    }
    // If starts with 62, add +
    else if (normalized.startsWith('62')) {
      normalized = '+$normalized';
    }
    // If doesn't start with +, assume it needs +62
    else if (!normalized.startsWith('+')) {
      normalized = '+62$normalized';
    }

    return normalized;
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service for managing local storage using SharedPreferences
class LocalStorageService {
  static const String _phoneNumberKey = 'user_phone_number';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  /// Store phone number
  static Future<void> storePhoneNumber(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_phoneNumberKey, phoneNumber);
      AppLogger.info('Phone number stored: $phoneNumber');
    } catch (e) {
      AppLogger.error('Failed to store phone number', e);
    }
  }

  /// Get stored phone number
  static Future<String?> getPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString(_phoneNumberKey);
      AppLogger.info('Retrieved phone number: $phoneNumber');
      return phoneNumber;
    } catch (e) {
      AppLogger.error('Failed to get phone number', e);
      return null;
    }
  }

  /// Store user ID
  static Future<void> storeUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      AppLogger.info('User ID stored: $userId');
    } catch (e) {
      AppLogger.error('Failed to store user ID', e);
    }
  }

  /// Get stored user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      AppLogger.info('Retrieved user ID: $userId');
      return userId;
    } catch (e) {
      AppLogger.error('Failed to get user ID', e);
      return null;
    }
  }

  /// Store user email
  static Future<void> storeUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
      AppLogger.info('User email stored: $email');
    } catch (e) {
      AppLogger.error('Failed to store user email', e);
    }
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_userEmailKey);
      AppLogger.info('Retrieved user email: $email');
      return email;
    } catch (e) {
      AppLogger.error('Failed to get user email', e);
      return null;
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_phoneNumberKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      AppLogger.info('All local storage data cleared');
    } catch (e) {
      AppLogger.error('Failed to clear local storage', e);
    }
  }
}

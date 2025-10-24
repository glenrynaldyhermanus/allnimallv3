import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static late final SupabaseClient client;

  // Production credentials (hardcoded for web deployment)
  static const String _prodUrl = 'https://kljlohqhwirumrdqrolw.supabase.co';
  static const String _prodAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsamxvaHFod2lydW1yZHFyb2x3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk2MzM2NDIsImV4cCI6MjA1NTIwOTY0Mn0.RBQwRKJ_89R42Pi741vb82onmxW3nPmcJH11thfsyoI';

  static String get supabaseUrl {
    // For web, always use production credentials (no .env file in deployed web)
    if (kIsWeb) return _prodUrl;
    // For mobile/desktop, try .env file first, fallback to production
    return dotenv.env['SUPABASE_URL'] ?? _prodUrl;
  }

  static String get supabaseAnonKey {
    // For web, always use production credentials (no .env file in deployed web)
    if (kIsWeb) return _prodAnonKey;
    // For mobile/desktop, try .env file first, fallback to production
    return dotenv.env['SUPABASE_ANON_KEY'] ?? _prodAnonKey;
  }

  static Future<void> initialize() async {
    try {
      AppLogger.info('Initializing Supabase...');

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception('Supabase credentials not found in .env file');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        storageOptions: const StorageClientOptions(retryAttempts: 3),
      );

      client = Supabase.instance.client;

      AppLogger.info('Supabase initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Supabase', e, stackTrace);
      rethrow;
    }
  }

  static SupabaseClient get instance => client;

  static GoTrueClient get auth => client.auth;

  static SupabaseStorageClient get storage => client.storage;

  static RealtimeClient get realtime => client.realtime;
}

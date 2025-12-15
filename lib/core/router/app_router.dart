import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/story_onboarding_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
// import '../../features/pet/presentation/pages/pet_profile_page.dart'; // Using card version now
import '../../features/pet/presentation/pages/pet_profile_page.dart';
import '../../features/pet/presentation/pages/pet_registration_page.dart';
import '../../features/pet/presentation/pages/pet_edit_page.dart';
import '../../features/pet/presentation/pages/scan_history_page.dart';

/// App routes constants
class AppRoutes {
  AppRoutes._();

  // Public routes
  static const pet =
      '/pet/:petId'; // 🔥 Unified pet profile (public + owner view)

  // Auth routes
  static const login = '/login';
  static const register = '/register';
  static const verifyOtp = '/verify-otp';

  // Onboarding routes
  static const userNew = '/user/new';
  static const petNew = '/pet/new';

  // Protected routes
  static const dashboard = '/dashboard';
  static const petEdit = '/pet/:petId/edit';
  static const scanHistory = '/pet/:petId/scans';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.dashboard,
    routerNeglect: false,
    redirect: (context, state) {
      // 🔥 FIX: Check if auth state is still loading (important after hard reload!)
      final isAuthenticated = authState.value != null;

      final isAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/verify-otp');
      final isOnboardingRoute =
          state.matchedLocation.startsWith('/user/new') ||
          state.matchedLocation.startsWith('/pet/new');
      final isPublicRoute =
          state.matchedLocation.startsWith('/pet/') &&
              !state.matchedLocation.contains('/edit') ||
          state.matchedLocation == '/';
      // Allow dashboard/onboarding right after OTP verification (authState might not have updated yet)
      final fromVerifyOtp = state.uri.queryParameters['from'] == 'verify-otp';
      final isDashboardFromVerifyOtp =
          state.matchedLocation.startsWith('/dashboard') && fromVerifyOtp;
      final isUserNewFromVerifyOtp =
          state.matchedLocation.startsWith('/user/new') && fromVerifyOtp;

      // Allow public routes without authentication
      if (isPublicRoute) {
        return null;
      }

      // Allow onboarding routes (user just logged in but hasn't completed profile)
      if (isOnboardingRoute) {
        return null;
      }

      // Allow navigation from OTP verification (bypass auth check due to race condition)
      if (isDashboardFromVerifyOtp || isUserNewFromVerifyOtp) {
        return null;
      }

      // Redirect to login if not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Redirect to dashboard if authenticated and on auth route
      // BUT: Don't redirect from /verify-otp - let it handle its own navigation
      if (isAuthenticated &&
          isAuthRoute &&
          !state.matchedLocation.startsWith('/verify-otp')) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      GoRoute(
        path: AppRoutes.verifyOtp,
        name: 'verify-otp',
        builder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
      ),

      // Onboarding Routes
      GoRoute(
        path: AppRoutes.userNew,
        name: 'user-new',
        builder: (context, state) {
          return const StoryOnboardingPage();
        },
      ),

      // 🔥 IMPORTANT: /pet/new MUST come BEFORE /pet/:petId
      // Otherwise "new" will be treated as a petId parameter
      GoRoute(
        path: AppRoutes.petNew,
        name: 'pet-new',
        builder: (context, state) {
          final petId = state.uri.queryParameters['petId'] ?? '';
          final qrId = state.uri.queryParameters['qrId'] ?? '';
          return PetRegistrationPage(petId: petId, qrId: qrId);
        },
      ),

      // 🔥 Unified Pet Profile (public + owner view)
      // This MUST come AFTER /pet/new to avoid matching "new" as :petId
      GoRoute(
        path: AppRoutes.pet,
        name: 'pet',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return PetProfilePage(petId: petId);
        },
      ),

      // Protected Routes
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      GoRoute(
        path: AppRoutes.petEdit,
        name: 'pet-edit',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return PetEditPage(petId: petId);
        },
      ),

      GoRoute(
        path: AppRoutes.scanHistory,
        name: 'scan-history',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return ScanHistoryPage(petId: petId);
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
});

// All page implementations are now in their respective feature folders

// PetProfilePage is now in its own file

// All page implementations are now in their respective feature folders

// All page implementations are in their respective feature folders

class ErrorPage extends StatelessWidget {
  final Exception? error;
  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Error: ${error?.toString() ?? 'Unknown error'}'),
      ),
    );
  }
}

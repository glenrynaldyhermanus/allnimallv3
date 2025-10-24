import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';
import '../providers/otp_state_provider.dart';
import '../../../../core/services/local_storage_service.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _handleVerifyOtp() async {
    final otpCode = _getOtpCode();

    if (otpCode.length != 6) {
      _showError('Kode OTP harus 6 digit');
      return;
    }

    ref.read(otpStateProvider.notifier).setLoading(true);

    final useCase = ref.read(verifyOTPUseCaseProvider);
    final result = await useCase(widget.phoneNumber, otpCode);

    if (!mounted) return;

    ref.read(otpStateProvider.notifier).setLoading(false);

    result.fold(
      (failure) {
        _showError(failure.message);
        // Clear OTP fields on error
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _otpFocusNodes[0].requestFocus();
      },
      (user) async {
        print('🎉 OTP verification successful!');
        print('👤 User ID: ${user.id}');
        print('📱 User phone: ${user.phone}');
        print('👤 User name: ${user.name ?? "(not set)"}');

        // Store user data in local storage
        if (user.phone != null) {
          await LocalStorageService.storePhoneNumber(user.phone!);
        }
        if (user.email != null) {
          await LocalStorageService.storeUserEmail(user.email!);
        }
        await LocalStorageService.storeUserId(user.id);

        print('💾 User data stored in local storage');

        // Always go to dashboard - it will redirect to /user/new if name is empty
        if (mounted) {
          print('➡️ Navigating to dashboard...');
          context.go('${AppRoutes.dashboard}?from=verify-otp');
        }
      },
    );
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;

    ref.read(otpStateProvider.notifier).setLoading(true);

    final useCase = ref.read(signInWithPhoneUseCaseProvider);
    final result = await useCase(widget.phoneNumber);

    if (!mounted) return;

    ref.read(otpStateProvider.notifier).setLoading(false);

    result.fold((failure) => _showError(failure.message), (_) {
      _showSuccess('Kode OTP berhasil dikirim ulang');
      _startResendTimer();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpStateProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: LoadingOverlay(
        isLoading: otpState.isLoading,
        message: 'Memverifikasi...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    AppStrings.otpVerification,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceSm),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'Kode OTP telah dikirim ke\n'),
                        TextSpan(
                          text: widget.phoneNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceXl),

                  // OTP Input
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 48,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.grey,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.grey,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              _otpFocusNodes[index + 1].requestFocus();
                            }
                            if (value.isEmpty && index > 0) {
                              _otpFocusNodes[index - 1].requestFocus();
                            }

                            // Auto-submit when all fields filled
                            if (index == 5 && value.isNotEmpty) {
                              _handleVerifyOtp();
                            }
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: AppDimensions.spaceXl),

                  // Verify Button
                  AppButton.primary(
                    text: AppStrings.verifyOTP,
                    onPressed: _handleVerifyOtp,
                    isLoading: otpState.isLoading,
                    icon: Icons.check_circle,
                  ),

                  const SizedBox(height: AppDimensions.spaceLg),

                  // Resend OTP
                  Center(
                    child: _resendCountdown > 0
                        ? Text(
                            'Kirim ulang dalam $_resendCountdown detik',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : TextButton(
                            onPressed: _handleResendOtp,
                            child: Text(
                              AppStrings.resendOTP,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: AppDimensions.spaceLg),

                  // Tips
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMd),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.tips_and_updates,
                              color: AppColors.info,
                              size: 20,
                            ),
                            const SizedBox(width: AppDimensions.spaceSm),
                            Text(
                              'Tips',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spaceXs),
                        Text(
                          '• Periksa SMS atau WhatsApp Anda\n'
                          '• Kode OTP berlaku selama 5 menit\n'
                          '• Jangan bagikan kode ke siapapun',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

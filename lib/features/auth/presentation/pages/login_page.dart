import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';
import '../providers/login_state_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();

    // Update loading state
    ref.read(loginStateProvider.notifier).setLoading(true);

    final useCase = ref.read(signInWithPhoneUseCaseProvider);
    final result = await useCase(phone);

    if (!mounted) return;

    ref.read(loginStateProvider.notifier).setLoading(false);

    result.fold(
      (failure) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {
        // Navigate to OTP verification
        context.push('${AppRoutes.verifyOtp}?phone=$phone');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginStateProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: loginState.isLoading,
          message: 'Mengirim OTP...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: SizedBox(
              height: size.height - MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.spaceXl),

                  // Logo & Welcome
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 240,
                            height: 100,
                            child: Image.asset(
                              'assets/images/ic_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          Text(
                            AppStrings.welcome,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceXxl),

                  // Form
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Masukkan Nomor Telepon',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceXs),
                            Text(
                              'Kami akan mengirimkan kode OTP untuk verifikasi',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceLg),

                            AppTextField(
                              controller: _phoneController,
                              label: AppStrings.phoneNumber,
                              hint: '08xxxxxxxxxx',
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone,
                              textInputAction: TextInputAction.done,
                              validator: Validators.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+]'),
                                ),
                              ],
                              onSubmitted: (_) => _handleLogin(),
                            ),

                            const SizedBox(height: AppDimensions.spaceLg),

                            AppButton.primary(
                              text: 'Kirim OTP',
                              onPressed: _handleLogin,
                              isLoading: loginState.isLoading,
                              icon: Icons.send,
                            ),

                            const SizedBox(height: AppDimensions.spaceLg),

                            // Info
                            Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingMd,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppDimensions.spaceSm),
                                  Expanded(
                                    child: Text(
                                      'Pastikan nomor telepon aktif untuk menerima kode OTP',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

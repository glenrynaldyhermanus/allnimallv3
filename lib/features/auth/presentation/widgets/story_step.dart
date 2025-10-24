import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class StoryStep extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final Widget? action;
  final bool showSkipButton;
  final VoidCallback? onSkip;
  final String? skipText;

  const StoryStep({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    this.action,
    this.showSkipButton = false,
    this.onSkip,
    this.skipText = 'Skip for now',
  });

  @override
  State<StoryStep> createState() => _StoryStepState();
}

class _StoryStepState extends State<StoryStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.title,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // Subtitle
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: AppDimensions.spaceSm),
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimensions.spaceXl),

                  // Content
                  widget.content,

                  const SizedBox(height: AppDimensions.spaceXl),

                  // Action button
                  if (widget.action != null) widget.action!,

                  // Skip button
                  if (widget.showSkipButton) ...[
                    const SizedBox(height: AppDimensions.spaceLg),
                    Center(
                      child: TextButton(
                        onPressed: widget.onSkip,
                        child: Text(
                          widget.skipText!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

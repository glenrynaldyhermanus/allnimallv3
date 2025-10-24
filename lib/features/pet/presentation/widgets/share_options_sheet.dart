import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/pet_providers.dart';

class ShareOptionsSheet extends ConsumerWidget {
  final String photoId;
  final String photoUrl;

  const ShareOptionsSheet({
    super.key,
    required this.photoId,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you\'d like to share this photo:',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                _buildShareOption(
                  context,
                  ref,
                  icon: LucideIcons.instagram,
                  label: 'Instagram',
                  platform: 'instagram',
                  color: const Color(0xFFE4405F),
                ),
                _buildShareOption(
                  context,
                  ref,
                  icon: LucideIcons.facebook,
                  label: 'Facebook',
                  platform: 'facebook',
                  color: const Color(0xFF1877F2),
                ),
                _buildShareOption(
                  context,
                  ref,
                  icon: LucideIcons.messageCircle,
                  label: 'WhatsApp',
                  platform: 'whatsapp',
                  color: const Color(0xFF25D366),
                ),
                _buildShareOption(
                  context,
                  ref,
                  icon: LucideIcons.link,
                  label: 'Copy Link',
                  platform: 'link',
                  color: AppColors.tertiary,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String platform,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),
      onTap: () async {
        Navigator.pop(context);
        await _handleShare(context, ref, platform);
      },
    );
  }

  Future<void> _handleShare(
    BuildContext context,
    WidgetRef ref,
    String platform,
  ) async {
    HapticFeedback.selectionClick();

    // Record share
    final useCase = ref.read(sharePhotoUseCaseProvider);
    await useCase(
      photoId: photoId,
      platform: platform,
      ip: 'demo-ip', // In production, get actual IP
    );

    // Handle platform-specific sharing
    if (platform == 'link') {
      await Clipboard.setData(ClipboardData(text: photoUrl));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Link copied to clipboard',
              style: GoogleFonts.nunito(color: AppColors.white),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Use share_plus for native sharing
      await Share.share(photoUrl, subject: 'Check out this pet photo!');
    }
  }
}

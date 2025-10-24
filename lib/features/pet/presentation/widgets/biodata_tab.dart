import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
// import '../../../auth/presentation/providers/auth_providers.dart'; // DEBUG MODE
import '../../../pet/domain/entities/pet_entity.dart';

class BiodataTab extends ConsumerWidget {
  final PetEntity pet;

  const BiodataTab({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final currentUserAsync = ref.watch(currentUserProvider); // DEBUG MODE
    // final currentUser = currentUserAsync.value; // DEBUG MODE
    // final isOwner = currentUser != null && currentUser.id == pet.ownerId; // DEBUG MODE
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      children: [
        _buildInfoSection(
          title: 'Informasi Dasar',
          children: [
            _buildInfoRow(
              icon: Icons.badge,
              label: AppStrings.petName,
              value: pet.name,
            ),
            if (pet.breed != null)
              _buildInfoRow(
                icon: Icons.category,
                label: AppStrings.breed,
                value: pet.breed!,
              ),
            if (pet.birthDate != null)
              _buildInfoRow(
                icon: Icons.cake,
                label: AppStrings.birthDate,
                value: DateFormat('dd MMMM yyyy').format(pet.birthDate!),
              ),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Usia',
              value: pet.ageDisplay,
            ),
            if (pet.gender != null)
              _buildInfoRow(
                icon: pet.gender == 'male' ? Icons.male : Icons.female,
                label: AppStrings.gender,
                value: pet.gender == 'male'
                    ? AppStrings.male
                    : pet.gender == 'female'
                    ? AppStrings.female
                    : pet.gender!,
              ),
            if (pet.color != null)
              _buildInfoRow(
                icon: Icons.palette,
                label: AppStrings.color,
                value: pet.color!,
              ),
            if (pet.weight != null)
              _buildInfoRow(
                icon: Icons.monitor_weight,
                label: AppStrings.weight,
                value: '${pet.weight} kg',
              ),
          ],
        ),

        const SizedBox(height: AppDimensions.spaceLg),

        if (pet.microchipId != null || pet.sterilizationStatus != null) ...[
          _buildInfoSection(
            title: 'Informasi Medis',
            children: [
              if (pet.microchipId != null)
                _buildInfoRow(
                  icon: Icons.qr_code,
                  label: AppStrings.microchipId,
                  value: pet.microchipId!,
                ),
              if (pet.sterilizationStatus != null)
                _buildInfoRow(
                  icon: Icons.medical_services,
                  label: 'Status Sterilisasi',
                  value: pet.sterilizationStatus!,
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLg),
        ],

        if (pet.story != null && pet.story!.isNotEmpty) ...[
          _buildInfoSection(
            title: AppStrings.notes,
            children: [
              Text(
                pet.story!,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],

        // Contact Owner Section for non-owners
        // 🔥 DEBUG MODE: Always show contact section for testing
        const SizedBox(height: AppDimensions.spaceLg),
        _buildContactSection(context),

        // 🔄 PRODUCTION MODE: Uncomment this for real owner/non-owner logic
        /*
        if (!isOwner) ...[
          const SizedBox(height: AppDimensions.spaceLg),
          _buildContactSection(context),
        ],
        */
      ],
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: const Icon(
                  Icons.phone,
                  size: 20,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Owner',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Found this pet? Contact the owner immediately',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                _showContactOptions(context);
              },
              icon: const Icon(Icons.phone, color: AppColors.white),
              label: Text(
                'Contact Owner Now',
                style: GoogleFonts.poppins(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
          if (pet.isLost) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSm),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.emergency,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: AppDimensions.spaceXs),
                  Expanded(
                    child: Text(
                      'URGENT: This pet is marked as LOST!',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                    'Contact Pet Owner',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you\'d like to contact ${pet.name}\'s owner:',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Call Owner',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Call directly',
                      style: GoogleFonts.nunito(color: AppColors.grey),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showNotImplemented(context, 'Phone call');
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.message,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Send SMS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Text message',
                      style: GoogleFonts.nunito(color: AppColors.grey),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showNotImplemented(context, 'SMS');
                    },
                  ),
                  if (pet.isLost)
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: AppColors.warning,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        'Emergency Contact',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                      subtitle: Text(
                        'This pet is lost - urgent!',
                        style: GoogleFonts.nunito(color: AppColors.grey),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showNotImplemented(context, 'Emergency contact');
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotImplemented(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon!',
          style: GoogleFonts.nunito(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

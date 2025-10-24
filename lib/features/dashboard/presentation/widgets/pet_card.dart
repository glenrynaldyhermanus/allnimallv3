import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../pet/domain/entities/pet_entity.dart';

class PetCard extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback? onTap;

  const PetCard({super.key, required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMd),
      child: Row(
        children: [
          // Pet Photo
          Hero(
            tag: 'pet-${pet.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: pet.pictureUrl != null
                  ? CachedNetworkImage(
                      imageUrl: pet.pictureUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.greyLight,
                        child: const Icon(Icons.pets, color: AppColors.grey),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: AppColors.greyLight,
                        child: const Icon(Icons.pets, color: AppColors.grey),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: AppColors.greyLight,
                      child: const Icon(
                        Icons.pets,
                        color: AppColors.grey,
                        size: 40,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: AppDimensions.spaceMd),

          // Pet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pet.name,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (pet.isLost)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSm,
                          vertical: AppDimensions.paddingXs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lostPetBanner,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        child: Text(
                          'HILANG',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceXs),

                if (pet.breed != null)
                  Text(
                    pet.breed!,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: AppDimensions.spaceXs),

                Row(
                  children: [
                    Icon(
                      pet.gender == 'male'
                          ? Icons.male
                          : pet.gender == 'female'
                          ? Icons.female
                          : Icons.pets,
                      size: 16,
                      color: AppColors.grey,
                    ),
                    const SizedBox(width: AppDimensions.spaceXs),
                    Text(
                      pet.ageDisplay,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (pet.weight != null) ...[
                      const SizedBox(width: AppDimensions.spaceSm),
                      const Text('•'),
                      const SizedBox(width: AppDimensions.spaceSm),
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 16,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: AppDimensions.spaceXs),
                      Text(
                        '${pet.weight} kg',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Chevron
          const Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }
}

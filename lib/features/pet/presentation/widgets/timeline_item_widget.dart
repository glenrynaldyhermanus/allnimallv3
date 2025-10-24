import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/pet_timeline_entity.dart';

class TimelineItemWidget extends StatelessWidget {
  final PetTimelineEntity timeline;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TimelineItemWidget({
    super.key,
    required this.timeline,
    this.onTap,
    this.onDelete,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'birthday':
        return LucideIcons.cake;
      case 'welcome':
        return LucideIcons.sparkles;
      case 'schedule':
        return LucideIcons.calendar;
      case 'activity':
        return LucideIcons.activity;
      case 'media':
        return LucideIcons.image;
      case 'weight_update':
        return LucideIcons.weight;
      default:
        return LucideIcons.circle;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'birthday':
        return AppColors.secondary;
      case 'welcome':
        return AppColors.primary;
      case 'schedule':
        return AppColors.tertiary;
      case 'activity':
        return AppColors.quaternary;
      case 'media':
        return AppColors.primary;
      case 'weight_update':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType(timeline.timelineType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.greyLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForType(timeline.timelineType),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                timeline.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            // Visibility indicator
                            Icon(
                              timeline.visibility == 'public'
                                  ? LucideIcons.globe
                                  : LucideIcons.lock,
                              size: 14,
                              color: AppColors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy · HH:mm',
                          ).format(timeline.eventDate),
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Delete button
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 18,
                        color: AppColors.error,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
            // Caption
            if (timeline.caption != null && timeline.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: Text(
                  timeline.caption!,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            // Media
            if (timeline.mediaUrl != null && timeline.mediaUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: timeline.mediaType == 'video'
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          CachedNetworkImage(
                            imageUrl: timeline.mediaUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.play,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      )
                    : CachedNetworkImage(
                        imageUrl: timeline.mediaUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: AppColors.greyLight,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 200,
                          color: AppColors.greyLight,
                          child: const Center(
                            child: Icon(
                              LucideIcons.image,
                              size: 32,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

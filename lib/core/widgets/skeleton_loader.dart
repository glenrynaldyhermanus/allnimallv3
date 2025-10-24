import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.greyLight,
        highlightColor: AppColors.greyLight.withValues(alpha: 0.3),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class PetProfileSkeleton extends StatelessWidget {
  const PetProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Hero Section Skeleton
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppColors.greyLight,
              child: Shimmer.fromColors(
                baseColor: AppColors.greyLight,
                highlightColor: AppColors.greyLight.withValues(alpha: 0.3),
                child: Container(
                  decoration: const BoxDecoration(color: AppColors.white),
                  child: Stack(
                    children: [
                      // Pet name skeleton
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonLoader(
                              width: 200,
                              height: 32,
                              borderRadius: 4,
                            ),
                            const SizedBox(height: 8),
                            SkeletonLoader(
                              width: 150,
                              height: 16,
                              borderRadius: 4,
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
        ),

        // Tab Bar Skeleton
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarSkeletonDelegate(),
        ),

        // Content Skeleton
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonLoader(
                  width: double.infinity,
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                SkeletonLoader(
                  width: double.infinity,
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
                SkeletonLoader(width: double.infinity, height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SliverTabBarSkeletonDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: SkeletonLoader(
                width: double.infinity,
                height: 20,
                margin: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: SkeletonLoader(
                width: double.infinity,
                height: 20,
                margin: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: SkeletonLoader(
                width: double.infinity,
                height: 20,
                margin: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarSkeletonDelegate oldDelegate) => false;
}

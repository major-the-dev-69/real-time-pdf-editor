import 'package:flutter/material.dart';

import '../../../../widgets/custom_shimmers.dart';

class DashboardSkeletonWidget extends StatelessWidget {
  const DashboardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Card Skeleton
            ShimmerBox(
              height: 220,
              width: double.infinity,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 20),

            // 2. Quick Actions Title Skeleton
            const ShimmerBox(height: 18, width: 120),
            const SizedBox(height: 10),

            // Quick Actions Grid Skeleton (6 items)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.25,
              children: List.generate(
                6,
                (index) => ShimmerBox(
                  height: 70,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Stats Section Title Skeleton
            const ShimmerBox(height: 18, width: 160),
            const SizedBox(height: 10),

            // Highlights Row Skeleton
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(
                    height: 75,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ShimmerBox(
                    height: 75,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Business Details Grid Skeleton
            const ShimmerBox(height: 16, width: 140),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: List.generate(
                4,
                (index) => ShimmerBox(
                  height: 65,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Income Breakdown Grid Skeleton
            const ShimmerBox(height: 16, width: 140),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
              children: List.generate(
                6,
                (index) => ShimmerBox(
                  height: 65,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

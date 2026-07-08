import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme.dart';

class DealCardSkeleton extends StatelessWidget {
  const DealCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF16213E) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF263255) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        height: 140, // Height matching approximately a real deal card
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Side Image Skeleton
            Container(
              width: 120,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Right Side Content Skeleton
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row (Store + Affiliate)
                    Row(
                      children: [
                        Container(width: 20, height: 20, color: Colors.white),
                        const SizedBox(width: 6),
                        Container(width: 60, height: 10, color: Colors.white),
                        const Spacer(),
                        Container(width: 40, height: 10, color: Colors.white),
                        const SizedBox(width: 4),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Title Lines
                    Container(width: double.infinity, height: 14, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 120, height: 14, color: Colors.white),
                    const Spacer(),
                    // Price lines
                    Container(width: 60, height: 10, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(width: 80, height: 20, color: Colors.white),
                    const Spacer(),
                    // Footer Buttons
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 40,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 70,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

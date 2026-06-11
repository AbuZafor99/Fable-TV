import 'package:flutter/material.dart';

import '../common/widgets/shimmer_loading.dart';

/// Shimmer placeholder mimicking the home screen's category sections;
/// shown only on first launch when the cache is empty.
class SkeletonLoader extends StatelessWidget {
  final int count;

  const SkeletonLoader({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(count, (_) => const _SectionSkeleton()),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerLoading(width: 120, height: 18, borderRadius: 6),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) =>
                  const ShimmerLoading(width: 140, height: 180, borderRadius: 14),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../Theme/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Color? dotColor;

  const CategoryChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? TColors.primary.withValues(alpha: 0.16)
              : TColors.bgCard,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isActive
                ? TColors.primary.withValues(alpha: 0.4)
                : TColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : TColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

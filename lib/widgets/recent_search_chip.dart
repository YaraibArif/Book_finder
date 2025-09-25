import 'package:flutter/material.dart';
import '../theme/theme.dart'; // 👈 AppColors import

class RecentSearchChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const RecentSearchChip({
    super.key,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ActionChip(
        label: Text(
          query,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMain, // 👈 readable text
          ),
        ),
        backgroundColor: AppColors.card, // 👈 chip background (dark surface)
        side: BorderSide(color: AppColors.primary.withOpacity(0.4)), // subtle border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // rounded corners
        ),


      ),
    );
  }
}

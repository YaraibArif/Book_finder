import 'package:flutter/material.dart';
import '../theme/theme.dart'; // 👈 AppColors import

class AuthorWorkCard extends StatelessWidget {
  final String title;
  final String? coverUrl;
  final String? firstPublishYear;
  final VoidCallback onTap;

  const AuthorWorkCard({
    super.key,
    required this.title,
    this.coverUrl,
    this.firstPublishYear,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        color: AppColors.card, // 👈 theme card color
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📚 Book Cover
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                coverUrl ??
                    "https://via.placeholder.com/80x120.png?text=No+Cover",
                width: 80,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 120,
                  color: AppColors.background,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 40,
                    color: AppColors.primary, // 👈 fallback icon theme accent
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 📖 Title + Year
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Publish Year
                    if (firstPublishYear != null &&
                        firstPublishYear!.trim().isNotEmpty)
                      Text(
                        "First published: $firstPublishYear",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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

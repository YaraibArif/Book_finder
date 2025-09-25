import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/settings_manager.dart';

class EditionCard extends StatelessWidget {
  final String title;
  final String? publishDate;
  final String? publisher;
  final int? pages;
  final int? coverId;
  final VoidCallback? onTap;

  const EditionCard({
    super.key,
    required this.title,
    this.publishDate,
    this.publisher,
    this.pages,
    this.coverId,
    this.onTap,
  });

  Future<String> _getCoverUrl() async {
    final size = await SettingsManager.getCoverSize(); // "S", "M", "L"
    if (coverId != null) {
      return "https://covers.openlibrary.org/b/id/$coverId-$size.jpg";
    } else {
      return "https://via.placeholder.com/80x120.png?text=No+Cover";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        color: AppColors.card, // 👈 theme color
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 📚 Cover
            ClipRRect(
              borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(12)),
              child: FutureBuilder<String>(
                future: _getCoverUrl(),
                builder: (context, snapshot) {
                  final url = snapshot.data ??
                      "https://via.placeholder.com/80x120.png?text=Loading...";
                  return Image.network(
                    url,
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
                        color: AppColors.primary, // 👈 fallback
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // 📖 Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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

                    // Publish date + publisher
                    if (publishDate != null || publisher != null)
                      Text(
                        "${publishDate ?? "Unknown"} • ${publisher ?? "Unknown Publisher"}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Pages
                    if (pages != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "$pages pages",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
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

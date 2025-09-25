import 'package:flutter/material.dart';

class SubjectBookCard extends StatelessWidget {
  final String title;
  final List<String>? authors; // ✅ multiple authors support
  final int? coverId; // ✅ OpenLibrary cover ID
  final String? coverUrl; // ✅ direct URL (optional fallback)
  final VoidCallback onTap;

  const SubjectBookCard({
    super.key,
    required this.title,
    this.authors,
    this.coverId,
    this.coverUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Build cover image
    String finalCoverUrl;
    if (coverId != null) {
      finalCoverUrl =
      "https://covers.openlibrary.org/b/id/$coverId-M.jpg"; // M = Medium size
    } else if (coverUrl != null && coverUrl!.isNotEmpty) {
      finalCoverUrl = coverUrl!;
    } else {
      finalCoverUrl =
      "https://via.placeholder.com/80x120.png?text=No+Cover"; // fallback
    }

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Book Cover
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              child: Image.network(
                finalCoverUrl,
                width: 80,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // ✅ Title + Authors
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Authors
                    if (authors != null && authors!.isNotEmpty)
                      Text(
                        "by ${authors!.join(', ')}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

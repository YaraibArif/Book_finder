import 'package:flutter/material.dart';
import '../providers/search_provider.dart';
import '../screens/work_detail_screen.dart';
import '../utils/settings_manager.dart';

class BookCard extends StatefulWidget {
  final BookSummary book;
  const BookCard({super.key, required this.book});

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  String _coverSize = "M"; // default medium

  @override
  void initState() {
    super.initState();
    _loadCoverSize();
  }

  Future<void> _loadCoverSize() async {
    final size = await SettingsManager.getCoverSize();
    if (mounted) {
      setState(() => _coverSize = size);
    }
  }

  @override
  Widget build(BuildContext context) {
    String coverUrl = widget.book.coverId != null
        ? "https://covers.openlibrary.org/b/id/${widget.book.coverId}-$_coverSize.jpg"
        : "https://via.placeholder.com/100x150.png?text=No+Cover";

    return Card(
      clipBehavior: Clip.antiAlias, // ✅ rounded corners respected
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkDetailScreen(workKey: widget.book.key),
            ),
          );
        },
        child: Row(
          children: [
            // ✅ Cover Image
            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // ✅ Book Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.book.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Author
                    Text(
                      widget.book.authors.isNotEmpty
                          ? widget.book.authors.join(", ")
                          : "Unknown Author",
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // First publish year
                    Text(
                      widget.book.firstPublishYear?.toString() ?? "—",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[600]),
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

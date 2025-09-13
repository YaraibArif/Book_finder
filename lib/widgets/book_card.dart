import 'package:flutter/material.dart';
import '../providers/search_provider.dart';
import '../screens/work_detail_screen.dart';

class BookCard extends StatelessWidget {
  final BookSummary book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    String coverUrl = book.coverId != null
        ? "https://covers.openlibrary.org/b/id/${book.coverId}-M.jpg"
        : "https://via.placeholder.com/100x150.png?text=No+Cover";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: Image.network(coverUrl, width: 50, fit: BoxFit.cover),
        title: Text(book.title),
        subtitle: Text(
          book.authors.isNotEmpty ? book.authors.join(", ") : "Unknown Author",
        ),
        trailing: Text(book.firstPublishYear?.toString() ?? ""),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkDetailScreen(workKey: book.key),
            ),
          );
        },
      ),
    );
  }
}

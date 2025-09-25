import 'package:flutter/material.dart';
import '../../providers/favorites_provider.dart';
import '../models/book.dart';

class FavoriteCard extends StatelessWidget {
  final FavoriteBook book;
  final FavoritesProvider favoritesProvider;

  const FavoriteCard({
    super.key,
    required this.book,
    required this.favoritesProvider,
  });

  @override
  Widget build(BuildContext context) {
    final coverUrl = book.coverUrl ??
        "https://via.placeholder.com/120x180.png?text=No+Cover";

    return Card(
      clipBehavior: Clip.antiAlias, // ✅ rounded corners respected
      child: InkWell(
        onTap: () {
          // 👇 future: detail screen par navigate kar sakte ho
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ Book Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  coverUrl,
                  height: 140,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => const Icon(
                    Icons.book,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ✅ Book Title
              Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // ✅ Delete Button
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () {
                  favoritesProvider.removeFavorite(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${book.title} removed"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

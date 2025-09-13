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
        "https://via.placeholder.com/80x120.png?text=No+Cover";

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            coverUrl,
            height: 120,
            width: 80,
            fit: BoxFit.cover,
            errorBuilder: (ctx, _, __) =>
            const Icon(Icons.book, size: 50),
          ),
          const SizedBox(height: 4),
          Text(
            book.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              favoritesProvider.removeFavorite(book.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${book.title} removed ❌")),
              );
            },
          ),
        ],
      ),
    );
  }
}

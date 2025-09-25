import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import 'work_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        actions: [
          Consumer<FavoritesProvider?>(
            builder: (context, provider, _) {
              if (provider == null) return const SizedBox.shrink();
              return IconButton(
                icon: provider.isRefreshing
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.refresh),
                onPressed: provider.isRefreshing
                    ? null
                    : () {
                  provider.refreshFavorites();
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider?>(
        builder: (context, favoritesProvider, _) {
          if (favoritesProvider == null) {
            return const Center(
              child: Text("Please sign in to view favorites"),
            );
          }

          return StreamBuilder<List<dynamic>>(
            stream: favoritesProvider.favoritesStream,
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}"),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final favorites = snapshot.data!;
              if (favorites.isEmpty) {
                return const Center(child: Text("No favorites yet"));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: favorites.length,
                itemBuilder: (ctx, i) {
                  final book = favorites[i];

                  final coverUrl = book.coverUrl ??
                      "https://via.placeholder.com/150x220.png?text=No+Cover";

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WorkDetailScreen(workKey: book.id),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.authors.isNotEmpty
                                      ? book.authors.join(", ")
                                      : "Unknown Author",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

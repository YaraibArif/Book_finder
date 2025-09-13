import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../widgets/favorite_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Favorites")),
      body: Consumer<FavoritesProvider?>(
        builder: (context, favoritesProvider, _) {
          if (favoritesProvider == null) {
            return const Center(
                child: Text("Please sign in to view favorites"));
          }

          return StreamBuilder(
            stream: favoritesProvider.favoritesStream,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No favorites yet"));
              }
              final favorites = snapshot.data!;
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: favorites.length,
                itemBuilder: (ctx, i) {
                  final book = favorites[i];
                  return FavoriteCard(
                    book: book,
                    favoritesProvider: favoritesProvider,
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

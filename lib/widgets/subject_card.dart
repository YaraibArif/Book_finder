import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';

class SubjectCard extends StatelessWidget {
  final String slug;
  final String name;
  final List<String> covers;

  const SubjectCard({
    super.key,
    required this.slug,
    required this.name,
    required this.covers,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        width: screenWidth * 0.35,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: covers
                    .take(1)
                    .map(
                      (coverUrl) => Image.network(
                    coverUrl,
                    height: screenWidth * 0.22,
                    width: screenWidth * 0.15,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.book, size: 40),
                  ),
                )
                    .toList(),
              ),
            ),
            if (authProvider.isSignedIn) ...[
              Consumer<FavoritesProvider>(
                builder: (context, favProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      await favProvider.addFavorite(
                        workKey: slug,
                        title: name,
                        authors: const [], // Subjects pe authors nahi hote
                        coverUrl: covers.isNotEmpty ? covers.first : null,
                        firstPublishYear: null,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("$name added to favorites ✅")),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text("Add to Favorites"),
                  );
                },
              )

            ],
          ],
        ),
      ),
    );
  }
}

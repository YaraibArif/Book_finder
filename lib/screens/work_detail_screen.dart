import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import 'editions_screen.dart';
import 'favourites_screen.dart';

class WorkDetailScreen extends StatefulWidget {
  final String workKey;

  const WorkDetailScreen({super.key, required this.workKey});

  @override
  State<WorkDetailScreen> createState() => _WorkDetailScreenState();
}

class _WorkDetailScreenState extends State<WorkDetailScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchWorkDetails();
  }

  Future<void> _fetchWorkDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final url = "https://openlibrary.org${widget.workKey}.json";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Server error: ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load details. Check your connection.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Book Details")),
        body: Center(child: Text(_error!)),
      );
    }

    final title = _data?['title'] ?? "Unknown";
    final description = _data?['description'];
    final firstPublishYear = _data?['first_publish_date'] ?? "";
    final covers = _data?['covers'] as List?;
    final coverUrl = (covers != null && covers.isNotEmpty)
        ? "https://covers.openlibrary.org/b/id/${covers.first}-L.jpg"
        : "https://via.placeholder.com/200x300.png?text=No+Cover";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Book Cover
            Center(
              child: Image.network(
                coverUrl,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            /// Title
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            /// First Publish Year
            const SizedBox(height: 8),
            if (firstPublishYear.isNotEmpty)
              Text("First Published: $firstPublishYear",
                  style: const TextStyle(color: Colors.grey)),

            /// Description
            const SizedBox(height: 16),
            Text(
              description is String
                  ? description
                  : (description?['value'] ?? "No description available"),
              style: const TextStyle(fontSize: 16),
            ),

            /// See Editions Button
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        EditionsScreen(workKey: widget.workKey, title: title),
                  ),
                );
              },
              child: const Text("See Editions"),
            ),

            /// Favorites Toggle
            const SizedBox(height: 16),
            Consumer<FavoritesProvider?>(
              builder: (context, favoritesProvider, _) {
                final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
                final isSignedIn = authProvider.isSignedIn;
                final workKey = widget.workKey;
                final title = _data?['title'] ?? "Unknown";

                final authors = (_data?['authors'] as List?)
                    ?.map((a) => a['name']?.toString() ?? "")
                    .where((a) => a.isNotEmpty)
                    .toList() ??
                    [];

                final coverList = _data?['covers'] as List?;
                final coverId = (coverList != null && coverList.isNotEmpty)
                    ? coverList.first
                    : null;

                final coverUrl = coverId != null
                    ? "https://covers.openlibrary.org/b/id/$coverId-M.jpg"
                    : null;

                final isFavorite =
                    favoritesProvider?.isFavorite(workKey) ?? false;

                if (!isSignedIn || favoritesProvider == null) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please sign in to save favorites.")),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Save to Favorites"),
                  );
                }

                return ElevatedButton.icon(
                  onPressed: () async {
                    if (isFavorite) {
                      await favoritesProvider.removeFavorite(workKey);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Removed from favorites ❌")),
                      );
                    } else {
                      await favoritesProvider.addFavorite(
                        workKey: workKey,
                        title: title,
                        authors: authors,
                        coverUrl: coverUrl,
                        firstPublishYear: _data?['first_publish_date'],
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Saved to favorites ✅")),
                      );
                    }

                    // in case Save 0r Remove navigate
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    );
                  },
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  label: Text(
                    isFavorite ? "Remove from Favorites" : "Save to Favorites",
                  ),
                );

              },
            ),
          ],
        ),
      ),
    );
  }
}

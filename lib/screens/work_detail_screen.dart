import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../respositories/author_repository.dart';
import '../respositories/book_repository.dart';
import '../respositories/cover_repository.dart';
import 'editions_screen.dart';
import 'author_screen.dart';
import 'favourites_screen.dart';
import 'subject_books_screen.dart';

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
  List<Map<String, String>> _authors = [];

  final _bookRepository = BookRepository();
  final _authorRepository = AuthorRepository();
  final _coverRepository = CoverRepository();

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
      final data = await _bookRepository.getWork(widget.workKey);
      setState(() {
        _data = data;
        _loading = false;
      });
      _loadAuthors(data['authors']);
    } catch (e) {
      setState(() {
        _error = "Failed to load details: $e";
        _loading = false;
      });
    }
  }

  Future<void> _loadAuthors(List<dynamic>? authorsData) async {
    if (authorsData == null) return;
    List<Map<String, String>> temp = [];

    for (var a in authorsData) {
      final key = a['author']?['key'];
      if (key != null) {
        try {
          final authorData = await _authorRepository.getAuthor(key);
          final name = authorData['name'] ?? "Unknown Author";
          temp.add({"id": key, "name": name});
        } catch (_) {
          temp.add({"id": key, "name": "Unknown Author"});
        }
      }
    }

    setState(() {
      _authors = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Book Details")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchWorkDetails,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final title = _data?['title'] ?? "Unknown";
    final description = _data?['description'];
    final firstPublishYear = _data?['first_publish_date'] ?? "";
    final covers = _data?['covers'] as List?;
    final coverUrl = _coverRepository.getCoverUrl(
      (covers != null && covers.isNotEmpty) ? covers.first : null,
      size: "L",
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(coverUrl, height: 250, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (firstPublishYear.isNotEmpty)
              Text(
                "First Published: $firstPublishYear",
                style: const TextStyle(color: Colors.grey),
              ),

            /// Authors
            if (_authors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _authors
                    .map(
                      (a) => ActionChip(
                        label: Text(a['name'] ?? "Unknown"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AuthorScreen(authorId: a['id']!),
                            ),
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ],

            /// Subjects
            if (_data?['subjects'] != null) ...[
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (_data?['subjects'] as List)
                      .map<Widget>(
                        (s) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(s.toString()),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SubjectBooksScreen(subject: s),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 16),
            Text(
              description is String
                  ? description
                  : (description?['value'] ?? "No description available"),
              style: const TextStyle(fontSize: 16),
            ),

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
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                final isSignedIn = authProvider.isSignedIn;
                final workKey = widget.workKey.replaceAll("/", "_"); // safe ID
                final title = _data?['title'] ?? "Unknown";
                final authors = _authors.map((a) => a['name']!).toList();

                final coverList = _data?['covers'] as List?;
                final coverId = (coverList != null && coverList.isNotEmpty)
                    ? coverList.first
                    : null;
                final coverUrl = _coverRepository.getCoverUrl(coverId);

                if (!isSignedIn || favoritesProvider == null) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please sign in to save favorites."),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text("Save to Favorites"),
                  );
                }

                final isFavorite = favoritesProvider.isFavorite(workKey);

                return ElevatedButton.icon(
                  onPressed: () async {
                    if (isFavorite) {
                      await favoritesProvider.removeFavorite(workKey);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Removed from favorites ❌"),
                        ),
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
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
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

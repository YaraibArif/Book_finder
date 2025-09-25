import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'work_detail_screen.dart';
import '../widgets/author_work_card.dart';

class AuthorScreen extends StatefulWidget {
  final String authorId;

  const AuthorScreen({super.key, required this.authorId});

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  Map<String, dynamic>? _authorData;
  final List<Map<String, dynamic>> _works = [];
  bool _loadingAuthor = true;
  bool _loadingWorks = true;
  bool _loadingMore = false;
  String? _errorAuthorMessage;
  String? _errorWorksMessage;

  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchAuthorDetails();
    _fetchWorks();
  }

  /// Normalize various accepted authorId forms:
  /// - "/authors/OL12345A"
  /// - "authors/OL12345A"
  /// - "OL12345A"
  /// Returns path like "/authors/OL12345A"
  String _authorPath(String id) {
    if (id.startsWith('/')) {
      // already "/authors/OL..."
      return id;
    }
    if (id.startsWith('authors/')) {
      return '/$id';
    }
    // just id like "OL12345A"
    return '/authors/$id';
  }

  Future<void> _fetchAuthorDetails() async {
    setState(() {
      _loadingAuthor = true;
      _errorAuthorMessage = null;
    });

    final path = _authorPath(widget.authorId);
    final url = 'https://openlibrary.org$path.json';

    try {
      debugPrint('AuthorScreen: fetching author details -> $url');
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      debugPrint('AuthorScreen: status ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _authorData = data;
          _loadingAuthor = false;
        });
      } else {
        // include response body for debug
        debugPrint('AuthorScreen: response body: ${res.body}');
        setState(() {
          _errorAuthorMessage = 'Server returned ${res.statusCode}';
          _loadingAuthor = false;
        });
      }
    } catch (e) {
      debugPrint('AuthorScreen: fetch author error: $e');
      setState(() {
        _errorAuthorMessage = 'Failed to load author details. (${e.toString()})';
        _loadingAuthor = false;
      });
    }
  }

  Future<void> _fetchWorks({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loadingWorks = true;
        _errorWorksMessage = null;
      });
    }

    final path = _authorPath(widget.authorId);
    final url = 'https://openlibrary.org$path/works.json?limit=$_limit&offset=$_offset';

    try {
      debugPrint('AuthorScreen: fetching works -> $url');
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      debugPrint('AuthorScreen: works status ${res.statusCode}');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final entries = List<Map<String, dynamic>>.from(data['entries'] ?? []);
        if (entries.isNotEmpty) {
          setState(() {
            _works.addAll(entries);
            _offset += _limit;
            _loadingWorks = false;
          });
        } else {
          setState(() {
            _hasMore = false;
            _loadingWorks = false;
          });
        }
      } else {
        debugPrint('AuthorScreen: works body: ${res.body}');
        setState(() {
          _errorWorksMessage = 'Server returned ${res.statusCode}';
          _loadingWorks = false;
        });
      }
    } catch (e) {
      debugPrint('AuthorScreen: fetch works error: $e');
      setState(() {
        _errorWorksMessage = 'Failed to load works. (${e.toString()})';
        _loadingWorks = false;
      });
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Author loading / error UI
    if (_loadingAuthor) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorAuthorMessage != null || _authorData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Author Details")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorAuthorMessage ?? 'Failed to load author details'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _fetchAuthorDetails,
                    child: const Text("Retry"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text("Back"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Author data present
    final name = _authorData?['name'] ?? "Unknown Author";
    final bio = _authorData?['bio'];
    final birthDate = _authorData?['birth_date'] ?? "";
    final deathDate = _authorData?['death_date'] ?? "";
    final lifespan = (birthDate.isNotEmpty || deathDate.isNotEmpty)
        ? "$birthDate - $deathDate"
        : "";

    final photoUrl = "https://covers.openlibrary.org/a/olid/${widget.authorId}-M.jpg";

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    photoUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(Icons.person, size: 48),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      if (lifespan.isNotEmpty)
                        Text(lifespan, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Bio
          if (bio != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(bio is String ? bio : (bio['value'] ?? "")),
            ),
            const SizedBox(height: 12),
          ],

          // Works list (separate error handling)
          Expanded(
            child: _loadingWorks && _works.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : (_errorWorksMessage != null && _works.isEmpty)
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorWorksMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _fetchWorks(),
                    child: const Text("Retry works"),
                  ),
                ],
              ),
            )
                : NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (!_loadingMore &&
                    _hasMore &&
                    scroll.metrics.pixels >=
                        scroll.metrics.maxScrollExtent - 200) {
                  _fetchWorks(loadMore: true);
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _works.length + (_loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _works.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final work = _works[index];
                  final workTitle = work['title'] ?? "Untitled";
                  final workKey = work['key'];
                  final coverId = work['covers'] != null &&
                      (work['covers'] as List).isNotEmpty
                      ? work['covers'][0]
                      : null;
                  final coverUrl = coverId != null
                      ? "https://covers.openlibrary.org/b/id/$coverId-M.jpg"
                      : null;

                  return AuthorWorkCard(
                    title: workTitle,
                    coverUrl: coverUrl,
                    firstPublishYear: work['first_publish_date'],
                    onTap: () {
                      if (workKey != null) {
                        // workKey often comes like "/works/OL...W" — pass it as-is
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkDetailScreen(workKey: workKey.toString()),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

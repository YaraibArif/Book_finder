import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditionsScreen extends StatefulWidget {
  final String workKey; // Example: "/works/OL12345W"
  final String title;

  const EditionsScreen({super.key, required this.workKey, required this.title});

  @override
  State<EditionsScreen> createState() => _EditionsScreenState();
}

class _EditionsScreenState extends State<EditionsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _editions = [];
  int _offset = 0;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchEditions();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchEditions({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final url =
          "https://openlibrary.org${widget.workKey}/editions.json?limit=$_limit&offset=$_offset";
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List docs = data['entries'] ?? [];

        setState(() {
          if (loadMore) {
            _editions.addAll(docs);
            _loadingMore = false;
          } else {
            _editions = docs;
            _loading = false;
          }
        });
      } else {
        setState(() {
          _error = "Server error: ${response.statusCode}";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Failed to load editions. Check your connection.";
        _loading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_loadingMore) {
        _offset += _limit;
        _fetchEditions(loadMore: true);
      }
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
        appBar: AppBar(title: Text("All Editions of ${widget.title}")),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("All Editions of ${widget.title}")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _editions.length + (_loadingMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == _editions.length) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final edition = _editions[i];
          final title = edition['title'] ?? "Unknown Edition";
          final publishDate = edition['publish_date'] ?? "Unknown Date";
          final publishers =
              (edition['publishers'] as List?)?.join(", ") ?? "Unknown Publisher";
          final coverId = edition['covers'] != null && edition['covers'].isNotEmpty
              ? edition['covers'][0]
              : null;
          final coverUrl = coverId != null
              ? "https://covers.openlibrary.org/b/id/$coverId-M.jpg"
              : "https://via.placeholder.com/100x150.png?text=No+Cover";

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              leading: Image.network(coverUrl, width: 50, fit: BoxFit.cover),
              title: Text(title),
              subtitle: Text("Published: $publishDate\nPublisher: $publishers"),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/editions_card.dart';

class EditionsScreen extends StatefulWidget {
  final String workKey;
  final String title;

  const EditionsScreen({super.key, required this.workKey, required this.title});

  @override
  State<EditionsScreen> createState() => _EditionsScreenState();
}

class _EditionsScreenState extends State<EditionsScreen> {
  final List<Map<String, dynamic>> _allEditions = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _error = false;
  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  // filters
  String? _selectedLanguage;
  RangeValues? _yearRange;
  int _minYear = 9999, _maxYear = 0;

  //  store all unique languages
  final Set<String> _languages = {};

  @override
  void initState() {
    super.initState();
    _fetchEditions();
  }

  Future<void> _fetchEditions({bool loadMore = false}) async {
    if (loadMore) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = false;
      });
    }

    try {
      final url =
          "https://openlibrary.org${widget.workKey}/editions.json?limit=$_limit&offset=$_offset";
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final editions = List<Map<String, dynamic>>.from(data['entries'] ?? []);

        if (editions.isNotEmpty) {
          setState(() {
            _allEditions.addAll(editions);
            _offset += _limit;

            // Build global language index from all editions
            for (var e in editions) {
              final langs = e['languages'] as List?;
              if (langs != null) {
                for (var l in langs) {
                  final code =
                  l['key'].toString().replaceAll("/languages/", "");
                  _languages.add(code);
                }
              }
            }
            // default select first language if none chosen
            if (_selectedLanguage == null && _languages.isNotEmpty) {
              _selectedLanguage = _languages.first;
            }

            // Build year range
            for (var e in editions) {
              final year = int.tryParse(
                  (e['publish_date'] ?? "").toString().split(" ").last) ??
                  0;
              if (year > 0) {
                _minYear = year < _minYear ? year : _minYear;
                _maxYear = year > _maxYear ? year : _maxYear;
              }
            }
            if (_yearRange == null && _minYear <= _maxYear) {
              _yearRange = RangeValues(_minYear.toDouble(), _maxYear.toDouble());
            }
          });
        } else {
          setState(() => _hasMore = false);
        }
      } else {
        setState(() => _error = true);
      }
    } catch (e) {
      setState(() => _error = true);
    } finally {
      setState(() {
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredEditions {
    return _allEditions.where((e) {
      // filter by language
      if (_selectedLanguage != null &&
          (e['languages'] != null &&
              !(e['languages'] as List)
                  .any((l) =>
                  l['key'].toString().endsWith("/${_selectedLanguage!}")))) {
        return false;
      }

      // filter by year
      final year = int.tryParse(
          (e['publish_date'] ?? "").toString().split(" ").last) ??
          0;
      if (_yearRange != null &&
          (year < _yearRange!.start || year > _yearRange!.end)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _allEditions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error && _allEditions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("All editions of ${widget.title}")),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _fetchEditions(),
            child: const Text("Retry"),
          ),
        ),
      );
    }

    final editions = _filteredEditions;

    return Scaffold(
      appBar: AppBar(title: Text("All editions of ${widget.title}")),
      body: Column(
        children: [
          // Filters
          if (_yearRange != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _selectedLanguage,
                    hint: const Text("Select Language"),
                    items: _languages
                        .map((lang) => DropdownMenuItem(
                      value: lang,
                      child: Text(lang),
                    ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedLanguage = val);
                    },
                  ),
                  RangeSlider(
                    min: _minYear.toDouble(),
                    max: _maxYear.toDouble(),
                    values: _yearRange!,
                    divisions: (_maxYear - _minYear).clamp(1, 100),
                    labels: RangeLabels(
                      _yearRange!.start.round().toString(),
                      _yearRange!.end.round().toString(),
                    ),
                    onChanged: (val) {
                      setState(() => _yearRange = val);
                    },
                  ),
                ],
              ),
            ),
          ],

          // Editions List
          Expanded(
            child: editions.isEmpty
                ? const Center(child: Text("No editions match"))
                : NotificationListener<ScrollNotification>(
              onNotification: (scroll) {
                if (!_loadingMore &&
                    _hasMore &&
                    scroll.metrics.pixels >=
                        scroll.metrics.maxScrollExtent - 200) {
                  _fetchEditions(loadMore: true);
                }
                return false;
              },
              child: ListView.builder(
                itemCount: editions.length + (_loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == editions.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final edition = editions[index];
                  final coverId = edition['covers'] != null &&
                      (edition['covers'] as List).isNotEmpty
                      ? edition['covers'][0]
                      : null;
                  final coverUrl = coverId != null
                      ? "https://covers.openlibrary.org/b/id/$coverId-M.jpg"
                      : "https://via.placeholder.com/80x120.png?text=No+Cover";
                  return EditionCard(
                    title: edition['title'] ?? "Untitled",
                    publishDate: edition['publish_date'],
                    publisher: (edition['publishers'] != null &&
                        edition['publishers'].isNotEmpty)
                        ? edition['publishers'][0]
                        : null,
                    pages: edition['number_of_pages'],
                    coverId: coverId,
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

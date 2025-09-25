import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // for TimeoutException
import 'dart:convert';

enum SearchState { idle, loading, data, empty, error }

class BookSummary {
  final String key;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;

  BookSummary({
    required this.key,
    required this.title,
    required this.authors,
    this.firstPublishYear,
    this.coverId,
  });

  factory BookSummary.fromJson(Map<String, dynamic> json) {
    return BookSummary(
      key: json['key'] ?? "",
      title: json['title'] ?? "Unknown",
      authors: (json['author_name'] as List?)?.map((e) => e.toString()).toList() ?? [],
      firstPublishYear: json['first_publish_year'],
      coverId: json['cover_i'],
    );
  }
}

class SearchProvider extends ChangeNotifier {
  SearchState state = SearchState.idle;
  String? errorMessage;

  List<BookSummary> results = [];
  int _page = 1;
  String _query = "";
  String _filter = "All";

  final ScrollController scrollController = ScrollController();

  SearchProvider() {
    scrollController.addListener(_scrollListener);
  }

  Future<void> search({required String query, String filter = "All"}) async {
    _query = query;
    _filter = filter;
    _page = 1;
    results.clear();
    state = SearchState.loading;
    notifyListeners();

    try {
      final url = _buildUrl(query, filter, _page);

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List docs = data['docs'] ?? [];

        results = docs.map((d) => BookSummary.fromJson(d)).toList();

        if (results.isEmpty) {
          state = SearchState.empty;
          if (filter == "ISBN") {
            errorMessage = "No results found for this ISBN. Try Title or Author.";
          }
        } else {
          state = SearchState.data;
        }
      } else {
        state = SearchState.error;
        errorMessage = "Server error: ${response.statusCode}";
      }
    } on TimeoutException {
      state = SearchState.error;
      errorMessage = "Request timed out. Please check your connection.";
    } catch (e) {
      state = SearchState.error;
      errorMessage = "Network error. Please try again.";
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (state != SearchState.data) return;

    _page++;
    try {
      final url = _buildUrl(_query, _filter, _page);
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List docs = data['docs'] ?? [];
        results.addAll(docs.map((d) => BookSummary.fromJson(d)).toList());
        notifyListeners();
      }
    } catch (_) {
      // pagination errors ko silently ignore karte hain
    }
  }

  String _buildUrl(String query, String filter, int page) {
    String encodedQuery = Uri.encodeComponent(query.trim()); // 👈 encoding + trim

    String base = "https://openlibrary.org/search.json?";
    if (filter == "Title") {
      base += "title=$encodedQuery";
    } else if (filter == "Author") {
      base += "author=$encodedQuery";
    } else if (filter == "ISBN") {
      base += "isbn=$encodedQuery";
    } else {
      base += "q=$encodedQuery";
    }
    base += "&page=$page";

    print("📡 Requesting: $base"); // 👈 debugging ke liye print
    return base;
  }


  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  String get filter => _filter; // expose filter for UI messages
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Subject {
  final String slug;
  final String name;
  final List<String> covers;

  Subject({
    required this.slug,
    required this.name,
    required this.covers,
  });
}

class SubjectProvider with ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<Subject> subjects = [];
  List<String> recentSearches = [];

  final Dio _dio = Dio();
  static const String baseUrl = "https://openlibrary.org";

  /// 🔹 Fetch subjects from OpenLibrary API
  Future<void> fetchSubjects(List<String> subjectSlugs) async {
    isLoading = true;
    notifyListeners();

    try {
      List<Subject> fetched = [];

      for (var slug in subjectSlugs) {
        final url = "$baseUrl/subjects/$slug.json";
        try {
          final response = await _dio.get(
            url,
            queryParameters: {
              "limit": 10, // ✅ sirf limit rakhi
            },
            options: Options(
              responseType: ResponseType.json, // ✅ force JSON
              validateStatus: (status) => status != null && status < 500,
            ),
          );

          if (response.statusCode == 200 && response.data is Map) {
            final data = response.data as Map<String, dynamic>;
            final works = data["works"] as List<dynamic>? ?? [];

            final covers = works
                .map((w) => w["cover_id"] != null
                ? "https://covers.openlibrary.org/b/id/${w["cover_id"]}-M.jpg"
                : null)
                .whereType<String>()
                .take(5)
                .toList();

            fetched.add(Subject(
              slug: slug,
              name: slug.replaceAll("_", " ").toUpperCase(),
              covers: covers,
            ));
          } else {
            errorMessage =
            "Invalid response for $slug (status: ${response.statusCode})";
          }
        } catch (e) {
          errorMessage = "Error fetching $slug: $e";
        }
      }

      subjects = fetched;
      if (subjects.isEmpty && errorMessage == null) {
        errorMessage = "No subjects found.";
      }
    } catch (e) {
      errorMessage = "Unexpected error: $e";
    }

    isLoading = false;
    notifyListeners();
  }

  /// 🔹 Save recent search locally
  void addRecentSearch(String query) {
    if (!recentSearches.contains(query)) {
      recentSearches.insert(0, query);
      if (recentSearches.length > 5) {
        recentSearches.removeLast();
      }
      notifyListeners();
    }
  }
}

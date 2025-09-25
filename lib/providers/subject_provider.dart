import 'package:flutter/material.dart';
import '../respositories/subject_repository.dart';

class Subject {
  final String slug;
  final String name;
  final String? description;
  final List<String> covers;

  Subject({
    required this.slug,
    required this.name,
    this.description,
    required this.covers,
  });
}

class SubjectProvider with ChangeNotifier {
  final SubjectRepository _repository;

  SubjectProvider({required SubjectRepository repository})
      : _repository = repository;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  List<Subject> subjects = [];
  List<String> recentSearches = [];

  int _offset = 0;
  final int _limit = 25;
  bool _hasMore = true;

  /// 🔹 For single subject (See All screen)
  List<Map<String, dynamic>> works = [];
  Map<String, dynamic>? subjectMeta;

  /// 🔹 Fetch multiple subjects (for home carousel)
  Future<void> fetchSubjects(List<String> subjectSlugs,
      {bool loadMore = false}) async {
    if (isLoading || (isLoadingMore && loadMore)) return;

    if (loadMore) {
      isLoadingMore = true;
    } else {
      isLoading = true;
      errorMessage = null;
      subjects.clear();
      _offset = 0;
      _hasMore = true;
    }
    notifyListeners();

    try {
      final List<Subject> fetched = [];

      for (final slug in subjectSlugs) {
        try {
          final data = await _repository.getSubject(
            slug,
            limit: _limit,
            offset: _offset,
          );

          final works = data["works"] as List<dynamic>? ?? [];

          final covers = works
              .map((w) => w["cover_id"] != null
              ? "https://covers.openlibrary.org/b/id/${w["cover_id"]}-M.jpg"
              : null)
              .whereType<String>()
              .take(5)
              .toList();

          fetched.add(
            Subject(
              slug: slug,
              name: data["name"] ?? slug.replaceAll("_", " ").toUpperCase(),
              description: data["description"] is String
                  ? data["description"]
                  : (data["description"]?["value"] ?? ""),
              covers: covers,
            ),
          );

          if (works.isNotEmpty) {
            _offset += _limit;
          } else {
            _hasMore = false;
          }
        } catch (e) {
          errorMessage = "Error fetching $slug: $e";
        }
      }

      subjects.addAll(fetched);
      if (subjects.isEmpty && errorMessage == null) {
        errorMessage = "No subjects found.";
      }
    } catch (e) {
      errorMessage = "Unexpected error: $e";
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// 🔹 Fetch single subject (for See All button)
  Future<void> fetchSubject(String slug, {bool loadMore = false}) async {
    if (loadMore) {
      isLoadingMore = true;
    } else {
      isLoading = true;
      works.clear();
      subjectMeta = null;
      _offset = 0;
      _hasMore = true;
      errorMessage = null;
    }
    notifyListeners();

    try {
      final data = await _repository.getSubject(
        slug,
        limit: _limit,
        offset: _offset,
        details: true,
      );

      if (!loadMore) {
        subjectMeta = data;
      }

      final newWorks = List<Map<String, dynamic>>.from(data["works"] ?? []);
      if (newWorks.isNotEmpty) {
        works.addAll(newWorks);
        _offset += _limit;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      errorMessage = "Error fetching $slug: $e";
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  bool get hasMore => _hasMore;

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

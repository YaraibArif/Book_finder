import 'package:flutter/material.dart';
import '../models/book.dart';
import '../respositories/favorites_repository.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesRepository _repository;
  final String _userId;

  FavoritesProvider({
    required FavoritesRepository repository,
    required String userId,
  })  : _repository = repository,
        _userId = userId;

  String get userId => _userId;

  final List<FavoriteBook> _favorites = [];
  List<FavoriteBook> get favorites => List.unmodifiable(_favorites);

  ///  Stream favorites from Firestore
  Stream<List<FavoriteBook>> get favoritesStream {
    return _repository.streamFavorites(_userId).map((list) {
      _favorites
        ..clear()
        ..addAll(list);
      notifyListeners();
      return list;
    });
  }

  ///  Check if a book is favorite
  bool isFavorite(String bookId) {
    return _favorites.any((book) => book.id == bookId);
  }

  ///  Add favorite
  Future<void> addFavorite({
    required String workKey,
    required String title,
    required List<String> authors,
    String? coverUrl,
    String? firstPublishYear,
  }) async {
    final book = FavoriteBook(
      id: workKey,
      title: title,
      authors: authors,
      coverUrl: coverUrl,
      firstPublishYear: firstPublishYear,
      addedAt: DateTime.now(),
    );

    // Local update
    _favorites.insert(0, book);
    notifyListeners();

    // Firestore update
    await _repository.addFavorite(_userId, book);
  }

  /// 🔹 Remove favorite
  Future<void> removeFavorite(String bookId) async {
    _favorites.removeWhere((book) => book.id == bookId);
    notifyListeners();

    await _repository.removeFavorite(_userId, bookId);
  }

  /// Refresh (force reload from Firestore)
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Future<void> refreshFavorites() async {
    _isRefreshing = true;
    notifyListeners();

    final snapshotStream = _repository.streamFavorites(_userId);
    final list = await snapshotStream.first;

    _favorites
      ..clear()
      ..addAll(list);

    _isRefreshing = false;
    notifyListeners();
  }

}
